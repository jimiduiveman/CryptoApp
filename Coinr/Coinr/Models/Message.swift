//
//  Message.swift
//  Coinr
//
//  Created by Jimi Duiveman on 16-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import Firebase




struct Message {
    
    let key: String
    let message: String
    let addedByUser: String
    let timeStamp: String
    let ref: DatabaseReference?
    
    init(message: String, addedByUser: String, timeStamp: String, key: String = "") {
        self.key = key
        self.message = message
        self.addedByUser = addedByUser
        self.timeStamp = timeStamp
        self.ref = nil
    }
    
    // Inspiration from Ray Wenderlich
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        message = snapshotValue["message"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        timeStamp = snapshotValue["timeStamp"] as! String
        ref = snapshot.ref
    }

    func toAnyObject() -> Any {
        return [
            "message": message,
            "addedByUser": addedByUser,
            "timeStamp": timeStamp
        ]
    }
    
}
