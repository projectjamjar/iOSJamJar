//
//  ForgetPasswordViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class ForgetPasswordViewController: BaseViewController{
    
    @IBOutlet var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func returnToLogin() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func returnToLoginButtonPressed(sender: UIButton) {
        self.returnToLogin()
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        let email = emailTextField.text!
        
        //Make sure that all fields are filled in
        if(email == "") {
            SCLAlertView().showError("Unable to send", subTitle: "Email is required", closeButtonTitle: "Got it")
            return
        }
        
        UserService.forgot(email) {
            (success: Bool, error: String?) in
            if !success {
                // Error - show the user
                let errorTitle = "Password reset failed!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Signup was successful, tell them to check their email
                let alertView = SCLAlertView()
                alertView.addButton("Got it!") {
                    self.returnToLogin()
                }
                alertView.showCloseButton = false
                alertView.showSuccess("Reset successful!", subTitle: "A password reset email has been sent to \(email).  Please check there to reset your password.")
            }
        }
    }

}
