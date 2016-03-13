//
//  LoginViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class LoginViewController: BaseViewController{
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let lastUser = userDefaults.stringForKey("previousUsername") {
            usernameTextField.text = lastUser
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        //Make sure that both the email and password field are filled in
        if(username == "" || password == "") {
            SCLAlertView().showError("Unable to log in", subTitle: "Username and Password are required", closeButtonTitle: "Got it")
            return
        }
        
        UserService.login(username, password: password) {
            (success: Bool, message: String?) in
            if !success {
                // Error - show the user
                let errorTitle = "Login failed!"
                if let error = message { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Our login was successful, save username and goto Home!
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(username, forKey: "previousUsername")
                
                self.performSegueWithIdentifier("goto_home", sender: self)
            }
        }
    }
    
}