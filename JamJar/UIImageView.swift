//
//  UIImageView.swift
//  JamJar
//
//  Created by Mark Koh on 3/7/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func cropToCircle() -> UIView? {
        // Make the photo circular
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        
        return self
    }
    
    public func cropToCircleWithBorder(borderWidth: CGFloat, borderColor: UIColor) -> UIView? {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        self.cropToCircle()
        return self
    }
    
    public func addOverLay(overlayColor: UIColor) -> UIView? {
        let overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        overlay.backgroundColor = overlayColor
        self.addSubview(overlay)
        return self
    }
}