//
//  UITabBarController.swift
//  JamJar
//
//  Created by Ethan Riback on 4/16/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UITabBarController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let selected = self.selectedViewController {
            return selected.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
    }
    
    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
}