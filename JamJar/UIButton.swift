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
    
    func roundCorners(rounding: CGFloat) {
        self.layer.cornerRadius = rounding
        self.clipsToBounds = true
    }
}