//
//  TradesTableViewController.swift
//  Coinr
//
//  Description: Overview of all your personal trades
//
//  Created by Jimi Duiveman on 23-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class TradesTableViewController: UITableViewController {

    // Constants
    let ref = Database.database().reference(withPath: "trades")
    
    
    // Variables
    var trades: [Trade] = []
    var userID = Auth.auth().currentUser?.uid
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getTrades()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // Get all the trades of the current user
    func getTrades() {
        ref.child(userID!).observe(.value, with: { snapshot in
            var newTrades: [Trade] = []
            
            // Get them one by one and create objects which will be stored in an array
            for item in snapshot.children {
                let trade = Trade(snapshot: item as! DataSnapshot)
                newTrades.append(trade)
            }
            
            // Assign trades to array and reload tableview
            self.trades = newTrades
            self.tableView.reloadData()
        })
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Determine number of rows
        return trades.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradeTableViewCell", for: indexPath) as! TradeTableViewCell
        
        // Sort trades, most recent on top
        let tradesSorted = trades.sorted(by: {$0.timeStamp > $1.timeStamp})
        let trade = tradesSorted[indexPath.row]
        
        // Assign values to labels
        cell.coinSymbol?.text = trade.coinSymbol
        
        // Change color of label based on trade type
        if trade.type.starts(with: "S") {
            cell.tradeType!.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            cell.tradeType!.textColor = #colorLiteral(red: 0, green: 0.8188306689, blue: 0.2586435676, alpha: 1)
        }
        cell.tradeType?.text = trade.type
        
        // Make sure the format of the label is correct
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Remove item from tableview
            self.trades.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Get specific trade
            let tradesSorted = trades.sorted(by: {$0.timeStamp > $1.timeStamp})
            let trade = tradesSorted[indexPath.row]
            
            // Remove trade from firebase
            ref.child(userID!).child(trade.timeStamp).removeValue()
        }
    }


}
