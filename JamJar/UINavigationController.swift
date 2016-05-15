//
//  UINavigationController.swift
//  JamJar
//
//  Created by Ethan Riback on 4/16/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.visibleViewController!.supportedInterfaceOrientations()
    }
    
    public override func shouldAutorotate() -> Bool {
        // If there's a visible viewcontroller, defer to that
        if let visibleController = self.visibleViewController {
            return visibleController.shouldAutorotate()
        }
        // Otherwise, don't autorotate???
        // ETHAN: Is this what we want?
        return false
    }
}