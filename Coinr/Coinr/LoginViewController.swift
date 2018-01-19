//
//  LoginViewController.swift
//  Coinr
//
//  Created by Jimi Duiveman on 11-01-18.
//  Copyright © 2018 Jimi Duiveman. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let loginToApp = "loginToApp"
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.loginToApp, sender: nil)
            }
        }
        self.hideKeyboardWhenTappedAround()
        
        textFieldLoginEmail.attributedPlaceholder = NSAttributedString(string: "username",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textFieldLoginPassword.attributedPlaceholder = NSAttributedString(string: "password",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!) { user, error in
            if error != nil {
                let wrongCredentials = UIAlertController(title: "Login Failed", message: error?.localizedDescription, preferredStyle: .alert)
                let tryAgain = UIAlertAction(title: "Try Again", style: .default)
                wrongCredentials.addAction(tryAgain)
                self.present(wrongCredentials, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                if error == nil {
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!)
                }
                else {
                    let createFailure = UIAlertController(title: "Register Failed", message: error?.localizedDescription, preferredStyle: .alert)
                    let createAgain = UIAlertAction(title: "Try Again", style: .default)
                    createFailure.addAction(createAgain)
                    self.present(createFailure, animated: true, completion: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
