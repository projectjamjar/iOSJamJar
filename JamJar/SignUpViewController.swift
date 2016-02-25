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
    
    func returnToLogin() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func returnToLoginButtonPressed(sender: UIButton) {
        self.returnToLogin()
    }
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let password = passwordTextField.text!
        let confirm = confirmTextField.text!
        
        //Make sure that all fields are filled in
        if([username, email, firstName,lastName,password,confirm].contains("")) {
            SCLAlertView().showError("Unable to sign up", subTitle: "All fields are required", closeButtonTitle: "Got it")
            return
        }
        
        //Make sure that password and confirm match
        if( password != confirm) {
            SCLAlertView().showError("Unable to sign up", subTitle: "Passwords do not match", closeButtonTitle: "Got it")
            return
        }
        
        UserService.signup(email, username: username, firstName: firstName, lastName: lastName, password: password, confirm: confirm) {
            (success: Bool, error: String?) in
            if !success {
                // Error - show the user
                let errorTitle = "Signup failed!"
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
                alertView.showSuccess("Signup Successful!", subTitle: "An activation email has been sent to \(email).  Please activate your account in order to login.")
            }
        }
    }
}