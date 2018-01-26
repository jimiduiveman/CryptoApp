//
//  MakeTradeViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 22-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class MakeTradeViewController: UIViewController {

    
    @IBOutlet weak var makeTransactionButton: UIButton!
    @IBOutlet weak var segmentTradePage: UISegmentedControl!
    @IBOutlet weak var pricePerCoin: UITextField!
    @IBOutlet weak var amountCoin: UITextField!
    @IBOutlet weak var totalPriceTrade: UILabel!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinSymbol: UILabel!
    
    var userID = Auth.auth().currentUser?.uid
    let tradesRef = Database.database().reference(withPath: "trades")
    let messageRef = Database.database().reference(withPath: "messages")
    var tradeCoin: Coin!
    var username = ""
    
    
    
    @IBAction func priceDidChange(_ sender: UITextField) {
        if sender.text != "" && amountCoin.text != "" {
            var price = ""
            var amount = ""
            price = String( sender.text!.split(separator: ",").joined(separator: ["."]) )
            amount = String ( amountCoin.text!.split(separator: ",").joined(separator: ["."]) )
            totalPriceTrade.text = String( Double(price)! * Double(amount)! )
        }
    }
    
    @IBAction func amountDidChange(_ sender: UITextField) {
        if sender.text != "" && pricePerCoin.text != "" {
            var price = ""
            var amount = ""
            price = String( pricePerCoin.text!.split(separator: ",").joined(separator: ["."]) )
            amount = String ( sender.text!.split(separator: ",").joined(separator: ["."]) )
            totalPriceTrade.text = String( Double(price)! * Double(amount)! )
        }
    }
    
    
    @IBAction func transactionButtonDidTouch(_ sender: UIButton) {
        var type = ""
        var action = ""
        if segmentTradePage.selectedSegmentIndex == 0{
            type = "Buy"
            action = "bought"
        }
        else {
            type = "Sell"
            action = "sold" 
        }
        
        var price = ""
        var amount = ""
        price = String( pricePerCoin.text!.split(separator: ",").joined(separator: ["."]) )
        amount = String ( amountCoin.text!.split(separator: ",").joined(separator: ["."]) )
        
        if pricePerCoin.text! != "" && amountCoin.text! != "" {
            let trade = Trade(coinSymbol: tradeCoin.symbol, coinPriceBought: price, totalPrice: totalPriceTrade.text!, amountBought: amount, timeStamp: String(describing: NSDate()), type: type)
            
            let personalTradeRef = tradesRef.child(userID!).child( String(describing: NSDate()) )
            personalTradeRef.setValue(trade.toAnyObject())
            
            let message = Message(message: "\(self.username) \(action) \(tradeCoin.symbol)", addedByUser: self.username, timeStamp: String(describing: NSDate()) )
            let thisMessageRef = self.messageRef.child(String(describing: NSDate()))
            thisMessageRef.setValue(message.toAnyObject())
            
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTransactionButton()
        configureSegment()
        
        coinName.text = tradeCoin.name
        coinSymbol.text = tradeCoin.symbol
        
        getUsername()
        
        pricePerCoin.attributedPlaceholder = NSAttributedString(string: "Fill in price", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        amountCoin.attributedPlaceholder = NSAttributedString(string: "Fill in amount", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }
    
    func getUsername() {
        let userRef = Database.database().reference().child("users").child(self.userID!)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.username = value!["username"] as! String
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func configureTransactionButton() {
        makeTransactionButton.layer.borderWidth = 1
        makeTransactionButton.layer.borderColor = #colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)
        makeTransactionButton.layer.cornerRadius = 4
    }
    
    
    func configureSegment() {
        segmentTradePage.backgroundColor = UIColor.black
        segmentTradePage.tintColor = #colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)
        segmentTradePage.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        segmentTradePage.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Avenir", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor.black
            ], for: .selected)
    }
    

}
