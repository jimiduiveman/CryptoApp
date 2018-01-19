//
//  PortfolioViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 12-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class PortfolioViewController: UIViewController {
    
    @IBAction func signoutButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            // there is a user signed in
            do {
                try? Auth.auth().signOut()
                
                if Auth.auth().currentUser == nil {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(.init(horizontal: 10, vertical: 20), for: UIBarMetrics.default)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
