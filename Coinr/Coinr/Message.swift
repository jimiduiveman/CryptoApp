//
//  Message.swift
//  Coinr
//
//  Created by Jimi Duiveman on 16-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import Firebase


// Inspiration from Ray Wenderlich

struct Message {
    
    let key: String
    let name: String
    let message: String
    let addedByUser: String
    let ref: DatabaseReference?
    
    init(name: String, message: String, addedByUser: String, key: String = "") {
        self.key = key
        self.name = name
        self.message = message
        self.addedByUser = addedByUser
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        message = snapshotValue["message"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "message": message,
            "addedByUser": addedByUser,
            "name": name
        ]
    }
    
}
