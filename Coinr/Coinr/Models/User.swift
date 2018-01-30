//
//  User.swift
//  Coinr
//
//  Created by Jimi Duiveman on 15-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
