//
//  UITextField.swift
//  JamJar
//
//  Created by Mark Koh on 2/29/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UITextField {
    func setColoredPlaceholder(placeholder: String, color: UIColor = UIColor.lightTextColor()) {
        let attributes = [NSForegroundColorAttributeName: color]
        self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
}