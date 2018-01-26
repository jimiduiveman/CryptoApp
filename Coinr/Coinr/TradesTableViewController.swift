//
//  TradesTableViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 23-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class TradesTableViewController: UITableViewController {

    
    let ref = Database.database().reference(withPath: "trades")
    
    var trades: [Trade] = []
    var userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getTrades()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    func getTrades() {
        ref.child(userID!).observe(.value, with: { snapshot in
            var newTrades: [Trade] = []
            
            for item in snapshot.children {
                let trade = Trade(snapshot: item as! DataSnapshot)
                newTrades.append(trade)
            }
            self.trades = newTrades
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trades.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell", for: indexPath) as! TradeTableViewCell
        let trade = trades[indexPath.row]
        
        cell.coinSymbol?.text = trade.coinSymbol
        if trade.type.starts(with: "S") {
            cell.tradeType!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.tradeType!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        cell.tradeType?.text = trade.type
        cell.amountBought?.text = trade.amountBought
        if trade.coinPriceBought.starts(with: "0") {
            cell.priceCoin?.text = "$\(trade.coinPriceBought)"
        }
        else {
            let priceCoin = (trade.coinPriceBought as NSString).doubleValue
            cell.priceCoin?.text = "\(priceCoin.formattedWithSeparator)"
        }
        let totalPrice = (trade.totalPrice as NSString).doubleValue
        cell.totalPriceTrade?.text = totalPrice.formattedWithSeparator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }


}
