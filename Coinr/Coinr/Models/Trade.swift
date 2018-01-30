//
//  Trade.swift
//  Coinr
//
//  Created by Jimi Duiveman on 23-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import Firebase

struct Trade {
    
    let key: String
    let coinSymbol: String
    let coinPriceBought: String
    let totalPrice: String
    let amountBought: String
    let timeStamp: String
    let type: String
    let ref: DatabaseReference?
    
    init(coinSymbol: String, coinPriceBought: String, totalPrice: String, amountBought: String, timeStamp: String, type: String, key: String = "") {
        self.key = key
        self.coinSymbol = coinSymbol
        self.coinPriceBought = coinPriceBought
        self.totalPrice = totalPrice
        self.amountBought = amountBought
        self.timeStamp = timeStamp
        self.type = type
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        coinSymbol = snapshotValue["coinSymbol"] as! String
        coinPriceBought = snapshotValue["coinPriceBought"] as! String
        totalPrice = snapshotValue["totalPrice"] as! String
        amountBought = snapshotValue["amountBought"] as! String
        timeStamp = snapshotValue["timeStamp"] as! String
        type = snapshotValue["type"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "coinSymbol": coinSymbol,
            "coinPriceBought": coinPriceBought,
            "totalPrice": totalPrice,
            "amountBought": amountBought,
            "timeStamp": timeStamp,
            "type": type
        ]
    }
    
}
