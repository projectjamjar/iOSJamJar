//
//  HomeViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class HomeViewController: UIViewController{
    
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
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        let prefs = NSUserDefaults.standardUserDefaults()
        let user = User(username: prefs.stringForKey("username")!, password: "")
        
        do {
            try user.deleteFromSecureStore()
            prefs.removeObjectForKey("username")
            prefs.synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            //TODO: implement code for actual error
            print("There was an error when trying to delete user information")
        }
    }
}
