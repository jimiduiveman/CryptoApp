//
//  PortfolioViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 12-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase
import Charts

class PortfolioViewController: UIViewController, UITableViewDataSource {
   
    let ref = Database.database().reference(withPath: "trades")
    
    var userID = Auth.auth().currentUser?.uid
    var coins: [Coin] = []
    var portFolioDict: [String: NSDictionary] = [:]
    var ownedCoins: [Coin] = []
    
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var totalProfit: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    @IBOutlet weak var portfolioTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinController.shared.fetchCoins() { (coins) in
            if let coins = coins {
                self.updateUI(with: coins)
            }
        }
        
        portfolioTableView.dataSource = self
        portfolioTableView.rowHeight = 60
        portfolioTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        CoinController.shared.fetchCoins() { (coins) in
            if let coins = coins {
                self.updateUI(with: coins)
            }
        }
        
        portfolioTableView.dataSource = self
        portfolioTableView.rowHeight = 60
        portfolioTableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    
    func updateUI(with coins: [Coin]) {
        DispatchQueue.main.async {
            self.coins = coins
            self.getTrades()
        }
    }


    
    func getTrades() {
        ref.child(userID!).observe(.value, with: { snapshot in
            var newTrades: [Trade] = []
            
            for item in snapshot.children {
                let trade = Trade(snapshot: item as! DataSnapshot)
                newTrades.append(trade)
            }
            self.makePortfolioDict(trades: newTrades)
        })
    }
    
    func getPortfolioStats(portfolio: [String: NSDictionary]) {
        
        var totalBuyPrice = 0.0
        var tradeProfit = 0.0
        var totalWorthNow = 0.0
        for item in portfolio {
            tradeProfit += (item.value["tradeProfit"]!) as! Double
            totalBuyPrice += (item.value["totalPrice"]!) as! Double
            for coin in self.coins {
                if item.key == coin.symbol {
                    totalWorthNow += (Double(coin.price)! * ((item.value["amount"]!) as! Double))
                }
            }
        }
        totalValue.text = String(totalWorthNow.formattedWithSeparator)
        let profit = String(format: "%.2f", (((totalWorthNow+tradeProfit-totalBuyPrice)/totalBuyPrice)*100)) + "%   " + String((totalWorthNow - totalBuyPrice + tradeProfit).formattedWithSeparator)
        if profit.starts(with: "-") {
            totalProfit.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        else {
            totalProfit.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        totalProfit.text = profit
    }
    
    func makePortfolioDict(trades: [Trade]) {
        self.portFolioDict = [:]
        for trade in trades {
            var newTotalPrice: Double = 0.0
            var newTotalAmount: Double = 0.0
            
            if self.portFolioDict["\(trade.coinSymbol)"] == nil {
                
                if trade.type == "Buy" {
                    
                    self.portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": Double(trade.totalPrice)!, "amount": Double(trade.amountBought)!, "tradeProfit": 0.0 ]
                }
                else {

                    self.portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": 0.0, "amount": 0, "tradeProfit": (Double(("-\(trade.totalPrice)" as NSString).doubleValue)) ]
                }
            
            }
            else {
                
                if trade.type == "Buy" {
                    
                    newTotalPrice = ( (self.portFolioDict[trade.coinSymbol]!["totalPrice"]!) as! Double) + Double(trade.totalPrice)!
                    newTotalAmount = ( (self.portFolioDict[trade.coinSymbol]!["amount"]!) as! Double) + Double(trade.amountBought)!
                    
                    self.portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": newTotalPrice, "amount": newTotalAmount, "tradeProfit": (Double(("-\(trade.totalPrice)" as NSString).doubleValue))]
                    
                }
                else {
                    
                    newTotalPrice = ((self.portFolioDict[trade.coinSymbol]!["totalPrice"]!) as! Double)
                    newTotalAmount = ((self.portFolioDict[trade.coinSymbol]!["amount"]!) as! Double) - Double(trade.amountBought)!
                    
                    self.portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": newTotalPrice, "amount": newTotalAmount, "tradeProfit": ((portFolioDict[trade.coinSymbol]!["amount"]!) as! Double)+(Double(("\(trade.totalPrice)" as NSString).doubleValue)) ]
                    
                }
            
            }
        }
        getPortfolioStats(portfolio: self.portFolioDict)
        updateChartData(portfolio: self.portFolioDict)
        getOwnedCoins()
        portfolioTableView.reloadData()
        
    }
    
    func getOwnedCoins() {
        self.ownedCoins = []
        for item in self.portFolioDict {
            for coin in coins {
                if item.key == coin.symbol && (self.portFolioDict[coin.symbol]!["amount"]! as! Double) > 0.0 {
                    self.ownedCoins.append(coin)
                }
            }
        }
    }
    
    func updateChartData(portfolio: [String: NSDictionary])  {
        var allCoins = [String]()
        var allValues = [Double]()
        
        for item in portfolio {
            if (portfolio[item.key]!["amount"]! as! Double) > 0.0 {
                allCoins.append(item.key)
                
                for coin in self.coins {
                    if item.key == coin.symbol {
                        allValues.append( (Double(coin.price)! * (portfolio[item.key]!["amount"]! as! Double)) )
                    }
                }
            }
        
        }
        
        var entries = [PieChartDataEntry]()
        for (index, value) in allValues.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = allCoins[index]
            entries.append( entry)
        }

        let set = PieChartDataSet( values: entries, label: "")
        let colors: [UIColor] = [UIColor(red: CGFloat(46.0/255), green: CGFloat(204.0/255), blue: CGFloat(113.0/255), alpha: 1),
                                 UIColor(red: CGFloat(52.0/255), green: CGFloat(152.0/255), blue: CGFloat(219.0/255), alpha: 1),
                                 UIColor(red: CGFloat(155.0/255), green: CGFloat(89.0/255), blue: CGFloat(182.0/255), alpha: 1),
                                 UIColor(red: CGFloat(26.0/255), green: CGFloat(188.0/255), blue: CGFloat(156.0/255), alpha: 1),
                                 UIColor(red: CGFloat(241.0/255), green: CGFloat(196.0/255), blue: CGFloat(15.0/255), alpha: 1),
                                 UIColor(red: CGFloat(230.0/255), green: CGFloat(126.0/255), blue: CGFloat(34.0/255), alpha: 1),
                                 UIColor(red: CGFloat(155.0/255), green: CGFloat(89.0/255), blue: CGFloat(182.0/255), alpha: 1),
                                 UIColor(red: CGFloat(231.0/255), green: CGFloat(76.0/255), blue: CGFloat(60.0/255), alpha: 1),
                                 UIColor(red: CGFloat(149.0/255), green: CGFloat(165.0/255), blue: CGFloat(166.0/255), alpha: 1),
                                 UIColor(red: CGFloat(52.0/255), green: CGFloat(73.0/255), blue: CGFloat(94.0/255), alpha: 1)]
        
        set.colors = colors
        let data = PieChartData(dataSet: set)
        pieChartView.data = data
        pieChartView.noDataText = "No data available"
        
        pieChartView.isUserInteractionEnabled = true
        
        pieChartView.legend.enabled = false
        
        pieChartView.holeRadiusPercent = 0.5
        pieChartView.holeColor = UIColor.black
        pieChartView.transparentCircleRadiusPercent = 0.0
        pieChartView.usePercentValuesEnabled = true
        //pieChartView.legend.textColor = UIColor.white
        //pieChartView.legend.horizontalAlignment = .center
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        formatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
    }
    
    
    
    
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            // there is a user signed in
            do {
                try? Auth.auth().signOut()
                
                if Auth.auth().currentUser == nil {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ownedCoins.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioTableViewCell") as! PortfolioTableViewCell
        let coin = self.ownedCoins[indexPath.row]
        cell.nameLabel.text = coin.name
        cell.amountLabel.text = String(self.portFolioDict[coin.symbol]!["amount"]! as! Double)
        if coin.twentyfourhr_change.starts(with: "-") {
            cell.priceLabel!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.priceLabel!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        let coinPrice = (coin.price as NSString).doubleValue
        cell.priceLabel.text = "\((coinPrice).formattedWithSeparator)"
        cell.totalPriceLabel.text = String((Double(coin.price)! * ((self.portFolioDict[coin.symbol]!["amount"]!) as! Double)).formattedWithSeparator)
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let indexPath = portfolioTableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                let coin: Coin
                
                coin = self.ownedCoins[indexPath.row]
                controller.detailCoin = coin
            }
        }
    }

}
