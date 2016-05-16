//
//  SettingsViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController{
    
    @IBOutlet weak var blockedUsersStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.getBlockedUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBlockedUsers() {
        
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        UserService.logout()
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func endLicenseTapped() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://projectjamjar.com/license.pdf")!)
    }
}