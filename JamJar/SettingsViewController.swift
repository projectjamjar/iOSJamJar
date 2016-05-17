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
        UserService.getBlockedUsers { (success, result, error) in
            if !success {
                // Do nothing?
            }
            else {
                for block in result! {
                    let nameLabel = MuliLabel()
                    nameLabel.setup(block.blockedUser.username, data: block)
                    
                    // Make it wide
                    let width = self.blockedUsersStackView.frame.width
                    nameLabel.widthAnchor.constraintEqualToConstant(width).active = true
                    nameLabel.heightAnchor.constraintEqualToConstant(35.0).active = true
                    nameLabel.userInteractionEnabled = true
                    
                    // Add a delete button to unblock users
                    let buttonFrame = CGRect(x: width-30, y: 0, width: 30, height: 30)
                    let deleteButton = PaddedButton(frame: buttonFrame)
                    deleteButton.padding = 2.5
                    deleteButton.setImage(UIImage(named: "delete"), forState: .Normal)
                    deleteButton.addTarget(self, action: #selector(self.unblockUser(_:)), forControlEvents: .TouchUpInside)
                    nameLabel.addSubview(deleteButton)
                    
                    // Add the user to the blocked list
                    self.blockedUsersStackView.addArrangedSubview(nameLabel)
                }
            }
        }
    }
    
    func unblockUser(sender: UIButton) {
        if let label = sender.superview as? MuliLabel,
            block = label.data as? UserBlock {
            UserService.unblockUser(block.blockedUser.id!, completion: { (success, error) in
                // Remove that kid
                self.blockedUsersStackView.removeArrangedSubview(label)
                label.removeFromSuperview()
            })
        }
    }
    
    @IBAction func logoutButtonPressed(sender: UIButton) {
        UserService.logout()
    }
    
    @IBAction func endLicenseTapped() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://projectjamjar.com/license.pdf")!)
    }
}