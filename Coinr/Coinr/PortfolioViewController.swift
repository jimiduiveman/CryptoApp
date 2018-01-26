//
//  PortfolioViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 12-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class PortfolioViewController: UIViewController {
   
    let ref = Database.database().reference(withPath: "trades")
    
    var userID = Auth.auth().currentUser?.uid
    var coins: [Coin] = []
    
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var totalProfit: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinController.shared.fetchCoins() { (coins) in
            if let coins = coins {
                self.updateUI(with: coins)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        CoinController.shared.fetchCoins() { (coins) in
            if let coins = coins {
                self.updateUI(with: coins)
            }
        }
    }
    
    func updateUI(with coins: [Coin]) {
        DispatchQueue.main.async {
            self.coins = coins
            self.getTrades()
        }
    }

    
    func getPortfolioStats(portfolio: [String: NSDictionary]) {
        var totalBuyPrice = 0.0
        var totalWorthNow = 0.0
        for item in portfolio {
            totalBuyPrice += (item.value["totalPrice"]!) as! Double
            for coin in self.coins {
                if item.key == coin.symbol {
                    totalWorthNow += (Double(coin.price)! * ((item.value["amount"]!) as! Double))
                }
            }
        }
        totalValue.text = String(totalWorthNow.formattedWithSeparator)
        let profit = String(format: "%.2f", ((totalWorthNow/totalBuyPrice)*100)) + "%   " + String((totalWorthNow - totalBuyPrice).formattedWithSeparator)
        if profit.starts(with: "-") {
            totalProfit.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        else {
            totalProfit.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        totalProfit.text = profit
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
    
    func makePortfolioDict(trades: [Trade]) {
        var portFolioDict: [String: NSDictionary] = [:]
        for trade in trades {
            var newTotalPrice: Double = 0.0
            var newTotalAmount: Double = 0.0
            var newNumberOfTrades: Double = 0.0
            
            if portFolioDict["\(trade.coinSymbol)"] == nil {
                
                if trade.type == "Buy" {
                    
                    portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": Double(trade.totalPrice)!, "amount": Double(trade.amountBought)!, "numberOfTrades": 1 ]
                }
                else {
                    
                    portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": Double(trade.totalPrice)!, "amount": Double(("-\(trade.amountBought)" as NSString).doubleValue), "numberOfTrades": 1 ]
                }
            
            }
            else {
                
                if trade.type == "Buy" {
                    
                    newTotalPrice = ( (portFolioDict[trade.coinSymbol]!["totalPrice"]!) as! Double) + Double(trade.totalPrice)!
                    newTotalAmount = ( (portFolioDict[trade.coinSymbol]!["amount"]!) as! Double) + Double(trade.amountBought)!
                }
                else {
                    
                    newTotalPrice = ((portFolioDict[trade.coinSymbol]!["totalPrice"]!) as! Double) - Double(trade.totalPrice)!
                    newTotalAmount = ((portFolioDict[trade.coinSymbol]!["amount"]!) as! Double) - Double(trade.amountBought)!
                }
                
                
                newNumberOfTrades = ((portFolioDict[trade.coinSymbol]!["numberOfTrades"]! as! Double) + 1.0)
                
                portFolioDict["\(trade.coinSymbol)"] = ["totalPrice": newTotalPrice, "amount": newTotalAmount, "numberOfTrades": newNumberOfTrades]
            }
        }
        getPortfolioStats(portfolio: portFolioDict)
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


}
