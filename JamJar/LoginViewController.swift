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
        
        if username != nil {
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
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        if !(username?.characters.count < 1 || password?.characters.count < 1) {
            print("Logging In...")
            
            let parameters = [
                "username": username!,
                "password" : password!
            ]
            
            Alamofire.request(
                .POST,
                "http://api.projectjamjar.com/auth/login/",
                parameters: parameters,
                encoding: .JSON).response{request, response, data, error in
                    let loginData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    //print(loginData)
                    
                    if let userData = loginData as? NSDictionary{
                        if let token = userData["token"] as? NSDictionary{
                            let user = User(username: username!, password: password!, authToken: token["key"] as! String)
                            do {
                                try user.createInSecureStore()
                                let prefs = NSUserDefaults.standardUserDefaults()
                                prefs.setValue(username, forKey: "username")
                                prefs.synchronize()
                                
                                //performs the segue to the home screen
                                self.performSegueWithIdentifier("goto_home", sender: self)
                            } catch {
                                //TODO: implement code for actual error
                                print("There was an error")
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