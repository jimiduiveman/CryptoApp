//
//  SocialTableViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 16-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import Firebase

class SocialTableViewController: UITableViewController {

    let ref = Database.database().reference(withPath: "messages")
    
    var messages: [Message] = []
    var userID = Auth.auth().currentUser?.uid
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(.init(horizontal: 10, vertical: 20), for: UIBarMetrics.default)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.observe(.value, with: { snapshot in
            var newMessages: [Message] = []
            
            for item in snapshot.children {
                let message = Message(snapshot: item as! DataSnapshot)
                newMessages.append(message)
            }
            self.messages = newMessages
            self.tableView.reloadData()
        })
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Message", message: "Provide your name and message", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Send", style: .default) { _ in
            let nameFieldText = alert.textFields![0].text
            let messageFieldText = alert.textFields![1].text
            
            let message = Message(name: nameFieldText!, message: messageFieldText!, addedByUser: self.userID!)
            let messageRef = self.ref.child(messageFieldText!.lowercased())
            messageRef.setValue(message.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textName in
            textName.placeholder = "Enter your name"
        }
        
        alert.addTextField { textMessage in
            textMessage.placeholder = "Enter your message"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! SocialTableViewCell
        let message = messages[indexPath.row]
        
        cell.messageLabel?.text = message.message
        cell.userLabel?.text = message.name
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70
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
