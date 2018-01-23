//
//  MakeTradeViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 22-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit

class MakeTradeViewController: UIViewController {

    
    @IBOutlet weak var makeTransactionButton: UIButton!
    @IBOutlet weak var segmentTradePage: UISegmentedControl!
    @IBOutlet weak var pricePerCoin: UITextField!
    @IBOutlet weak var amountCoin: UITextField!
    @IBOutlet weak var totalPriceTrade: UILabel!
  
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        var amountAfterUpdate = ""
//        var priceAfterUpdate = ""
//        if textField == pricePerCoin {
//            if let textPrice = pricePerCoin.text as NSString? {
//                priceAfterUpdate = textPrice.replacingCharacters(in: range, with: string)
//                print(priceAfterUpdate)
//            }
//        }
//        if textField == amountCoin {
//            if let textAmount = pricePerCoin.text as NSString? {
//                amountAfterUpdate = textAmount.replacingCharacters(in: range, with: string)
//                print(amountAfterUpdate)
//            }
//        }
//        if priceAfterUpdate != "" && amountAfterUpdate != "" {
//            totalPriceTrade.text = String( Double(priceAfterUpdate)!+Double(amountAfterUpdate)! )
//        }
//        return true
//    }
    
    
    @IBAction func priceDidChange(_ sender: UITextField) {
        if sender.text != "" && amountCoin.text != "" {
            totalPriceTrade.text = String( Double(sender.text!)! * Double(amountCoin.text!)! )
        }
    }
    
    @IBAction func amountDidChange(_ sender: UITextField) {
        if sender.text != "" && pricePerCoin.text != "" {
            totalPriceTrade.text = String( Double(pricePerCoin.text!)! * Double(sender.text!)! )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTransactionButton()
        configureSegment()
        
        pricePerCoin.attributedPlaceholder = NSAttributedString(string: "Fill in price", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        amountCoin.attributedPlaceholder = NSAttributedString(string: "Fill in amount", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
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
