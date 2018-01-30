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
    var username = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMessages()
        getUsername()
        
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    func getMessages() {
        ref.observe(.value, with: { snapshot in
            var newMessages: [Message] = []
            
            for item in snapshot.children {
                let message = Message(snapshot: item as! DataSnapshot)
                newMessages.append(message)
            }
            
            //Remove old messages if there are more than 20
            if newMessages.count > 20 {
                let sortedMessages = newMessages.sorted(by: {$0.timeStamp > $1.timeStamp})
                self.ref.child(sortedMessages.last!.key).removeValue(completionBlock: { (error, refer) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        print("Removed: \(sortedMessages.last!.message)")
                    }
                })
            }
            
            self.messages = newMessages
            self.tableView.reloadData()
        })
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
    
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Message", message: "Provide your message:", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Send", style: .default) { _ in
            let messageFieldText = alert.textFields![0].text
            let message = Message(message: messageFieldText!, addedByUser: self.username, timeStamp: String(describing: NSDate()) ) 
            let messageRef = self.ref.child(messageFieldText!.lowercased())
            messageRef.setValue(message.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
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
        let messages = self.messages.sorted(by: {$0.timeStamp > $1.timeStamp})
        let message = messages[indexPath.row]
        
        cell.messageLabel?.text = message.message
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        let dateFromString: Date? = dateFormatter.date(from: message.timeStamp)
        
        let dateFormatterFinal = DateFormatter()
        dateFormatterFinal.dateFormat = "HH:mm dd-MM-yyyy"
        
        cell.userLabel?.text = "\(message.addedByUser) - \(dateFormatterFinal.string(from: dateFromString!))"
        
        return cell
    }

}
