//
//  Coin.swift
//  Coinr
//
//  Created by Jimi Duiveman on 11-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

struct Coin {
    var id: String
    var name: String
    var symbol: String
    var price: String
    var sevenday_change: String
    var twentyfourhr_change: String
    var available_supply: String
    var marketcap: String
    var logo: String
    
    init(id: String, name: String, symbol: String, price: String, sevenday_change: String, twentyfourhr_change: String, available_supply: String, marketcap: String, logo: String) {
        
        self.id = id
        self.name = name
        self.symbol = symbol
        self.price = price
        self.sevenday_change = sevenday_change
        self.twentyfourhr_change = twentyfourhr_change
        self.available_supply = available_supply
        self.marketcap = marketcap
        self.logo = logo
    }
    
    let coinsRef = Database.database().reference(withPath: "favorites")
    func saveToFirebase(userID: String ) {
        let dict = ["id": self.id,
                    "name": self.name,
                    "symbol": self.symbol,
                    "price": self.price,
                    "sevenday_change": self.sevenday_change,
                    "twentyfourhr_change": self.twentyfourhr_change,
                    "available_supply": self.available_supply,
                    "marketcap": self.marketcap,
                    "logo": self.logo
            ] as [String : Any]
        
        let thisCoinsRef = coinsRef.child(userID).child(dict["symbol"] as! String)
        thisCoinsRef.setValue(dict)
    }
    
    func deleteFromFirebase(symbol: String, userID: String) {
        coinsRef.child(userID).child(symbol).removeValue { error,refer  in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
        }
    }

}
