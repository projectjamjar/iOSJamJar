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
        return self.visibleViewController!.shouldAutorotate()
    }
}