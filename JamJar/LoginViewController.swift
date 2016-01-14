//
//  LoginViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class LoginViewController: UIViewController{
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //Checks if the user has saved login information
        let prefs = NSUserDefaults.standardUserDefaults()
        let username = prefs.stringForKey("username")
        let password = prefs.stringForKey("password")
        
        if !(username == nil || password == nil) {
            //performs the segue to the home screen
            self.performSegueWithIdentifier("goto_home", sender: self)
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        print("Sign In Pressed")
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        print("Username: " + username!)
        print("Password: " + password!)
        
        if !(username?.characters.count < 1 || password?.characters.count < 1) {
            print("Logging In...")
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(username, forKey: "username")
            prefs.setValue(password, forKey: "password")
            prefs.synchronize()
            
            /*
            let user = User(username: username!, password: password!)
            do {
                try user.createInSecureStore()
            } catch {
                //TODO: implement code for actual error
                print("There was an error")
            }
            
            let temp = User(username: username!, password: "")
            let result = temp.readFromSecureStore()
            print(result)
            */
            
            //performs the segue to the home screen
            self.performSegueWithIdentifier("goto_home", sender: self)
        }
    }
    
}