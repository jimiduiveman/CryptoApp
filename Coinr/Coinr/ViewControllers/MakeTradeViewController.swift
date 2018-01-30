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
    
    
    //Get value from price textfield when something changed in field and update total
    @IBAction func priceDidChange(_ sender: UITextField) {
        
        //Both must contain a value
        if sender.text != "" && amountCoin.text != "" {
            
            //Make variables
            var price = ""
            var amount = ""
            
            //Change , to . before calculations
            price = String( sender.text!.split(separator: ",").joined(separator: ["."]) )
            amount = String ( amountCoin.text!.split(separator: ",").joined(separator: ["."]) )
            
            //Calculate total value of transaction
            totalPriceTrade.text = String( Double(price)! * Double(amount)! )
        }
    }
    
    //Get value from amount textfield when something changed in field and update total
    @IBAction func amountDidChange(_ sender: UITextField) {
        
        //Both must contain a value
        if sender.text != "" && pricePerCoin.text != "" {
            
            //Make variables
            var price = ""
            var amount = ""
            
            //Change , to . before calculations
            price = String( pricePerCoin.text!.split(separator: ",").joined(separator: ["."]) )
            amount = String ( sender.text!.split(separator: ",").joined(separator: ["."]) )
            
            //Calculate total value of transaction
            totalPriceTrade.text = String( Double(price)! * Double(amount)! )
        }
    }
    
    //When user taps transaction button
    @IBAction func transactionButtonDidTouch(_ sender: UIButton) {
        
        //Make variables
        var type = ""
        var action = ""
        
        //If buy
        if segmentTradePage.selectedSegmentIndex == 0 {
            
            //Determine if we have to add
            type = "Buy"
            
            //Will be shown in message
            action = "bought"
        }
        //If sell
        else {
            
            //Determine if we have to substract
            type = "Sell"
            
            //Will be shown in message
            action = "sold" 
        }
        
        //Make variables
        var price = ""
        var amount = ""
        
        //Change , to . before calculations
        price = String( pricePerCoin.text!.split(separator: ",").joined(separator: ["."]) )
        amount = String ( amountCoin.text!.split(separator: ",").joined(separator: ["."]) )
        
        //Check if not empty
        if pricePerCoin.text! != "" && amountCoin.text! != "" {
            
            //Create object out of given stats
            let trade = Trade(coinSymbol: tradeCoin.symbol, coinPriceBought: price, totalPrice: totalPriceTrade.text!, amountBought: amount, timeStamp: String(describing: NSDate()), type: type)
            
            //Push to Firebase
            let personalTradeRef = tradesRef.child(userID!).child( String(describing: NSDate()) )
            personalTradeRef.setValue(trade.toAnyObject())
            
            //Create message out of given stats and push to Firebase
            let message = Message(message: "\(self.username) \(action) \(tradeCoin.symbol)", addedByUser: self.username, timeStamp: String(describing: NSDate()) )
            let thisMessageRef = self.messageRef.child(String(describing: NSDate()))
            thisMessageRef.setValue(message.toAnyObject())
            
            //Head back to detail page of coin
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
        
        //Configure the lay-out of the two textfields
        pricePerCoin.attributedPlaceholder = NSAttributedString(string: "Fill in price", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        amountCoin.attributedPlaceholder = NSAttributedString(string: "Fill in amount", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }
    
    //Get username of current user
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
    
    //Configure the lay-out of transaction button
    func configureTransactionButton() {
        makeTransactionButton.layer.borderWidth = 1
        makeTransactionButton.layer.borderColor = #colorLiteral(red: 0.2747907639, green: 0.5571715236, blue: 0.8975776434, alpha: 1)
        makeTransactionButton.layer.cornerRadius = 4
    }
    
    //Configure the lay-out of segmented control
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
