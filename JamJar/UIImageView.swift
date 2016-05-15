//
//  UIImageView.swift
//  JamJar
//
//  Created by Mark Koh on 3/7/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

public extension UIView {
    public func addOverLay(overlayColor: UIColor) -> UIView? {
        let overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        overlay.backgroundColor = overlayColor
        self.addSubview(overlay)
        return self
    }
}