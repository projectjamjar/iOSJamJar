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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //Checks if the user has saved login information
        if UserService.currentUser() != nil {
            //performs the segue to the home screen
            self.performSegueWithIdentifier("goto_home", sender: self)
        }
    }
    
    @IBAction func signInButtonPressed(sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        //Make sure that both the email and password field are filled in
        if(username == "" || password == "") {
            SCLAlertView().showError("Unable to log in", subTitle: "Username and Password are required", closeButtonTitle: "Got it")
            return
        }
        
            
//        UserService.login(username, password: password).responseJSON { request, response, data, error in
//            let loginData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
//            
//            if let userData = loginData as? NSDictionary{
//                if let token = userData["token"] as? NSDictionary{
//                    if(UserService.saveUserInfo(username, password: password, token: token["key"] as! String)) {
//                        //performs the segue to the home screen
//                        self.performSegueWithIdentifier("goto_home", sender: self)
//                    } else {
//                        //API is not working, warn the user
//                        SCLAlertView().showError("Server Error", subTitle: "Username and Password are required", closeButtonTitle: "Got it")
//                    }
//                }
//                else if let loginError = userData["error"] as? NSDictionary{
//                    print(loginError)
//                    
//                    //TODO: Give a different error message based on response
//                    let alert = UIAlertController(title: "Login Failed", message: "Username or Password was incorrect", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//            }

//        }
        UserService.login(username, password: password) {
            (success: Bool, message: String?) in
            if !success {
                // Error - show the user
                let errorTitle = "Login failed!"
                if let error = message { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                self.performSegueWithIdentifier("goto_home", sender: self)
            }
        }
    }
    
}