//
//  SignUpViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class SignUpViewController: BaseViewController{
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToLoginButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        //Make sure that both the email and password field are filled in
        if(username == "" || password == "") {
            SCLAlertView().showError("Unable to log in", subTitle: "Username and Password are required", closeButtonTitle: "Got it")
            return
        }
        
        if !(username.characters.count < 1 || password.characters.count < 1) {
            
            UserService.login(username, password: password).response{request, response, data, error in
                let loginData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                
                if let userData = loginData as? NSDictionary{
                    if let token = userData["token"] as? NSDictionary{
                        if(UserService.saveUserInfo(username, password: password, token: token["key"] as! String)) {
                            //performs the segue to the home screen
                            self.performSegueWithIdentifier("goto_home", sender: self)
                        } else {
                            //API is not working, warn the user
                            let alert = UIAlertController(title: "Server Error", message: "The server is down at the moment", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                    else if let loginError = userData["error"] as? NSDictionary{
                        print(loginError)
                        
                        //TODO: Give a different error message based on response
                        let alert = UIAlertController(title: "Login Failed", message: "Username or Password was incorrect", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
}