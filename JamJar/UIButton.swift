//
//  UIButton.swift
//  JamJar
//
//  Created by Ethan Riback on 5/8/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UIButton {
    func highlightBackgroundLike() {
        if(self.selected) {
            self.backgroundColor = UIColor(red: 155.0/255.0, green: 208.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        } else {
            self.backgroundColor = nil
        }
    }
    
    func highlightBackgroundDislike() {
        if(self.selected) {
            self.backgroundColor = UIColor(red: 245.0/255.0, green: 169.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        } else {
            self.backgroundColor = nil
        }
    }
}

class PaddedButton: UIButton {
    var padding: CGFloat = 0
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsetsMake(-padding, -padding, -padding, -padding)
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
        return CGRectContainsPoint(hitFrame, point)
    }
}