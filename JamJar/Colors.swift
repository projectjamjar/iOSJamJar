//
//  Colors.swift
//  JamJar
//
//  Created by Mark Koh on 3/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UIColor {
    
    @nonobjc static let JamJarAccentColors = [
        UIColor.jjOrangeColor(),
        UIColor.jjYellowColor(),
        UIColor.jjGreenColor(),
        UIColor.jjPurpleColor(),
        UIColor.jjDarkPurpleColor()
    ]
    @nonobjc static let numAccentColors = 5
    
    /**
     Initializes and returns a color using the specified rgb value
     
     :param: red   red
     :param: green green
     :param: blue  blue
     
     :returns: color
     */
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    static func jjCoralColor() -> UIColor {
        return UIColor(red: 241, green: 95, blue: 78)
    }
    
    // #F5A95F
    static func jjOrangeColor() -> UIColor {
        return UIColor(red: 245, green: 169, blue: 95)
    }
    
    // #FDEB65
    static func jjYellowColor() -> UIColor {
        return UIColor(red: 253, green: 235, blue: 101)
    }
    
    // #9BD096
    static func jjGreenColor() -> UIColor {
        return UIColor(red: 155, green: 208, blue: 150)
    }
    
    // #7976B4
    static func jjPurpleColor() -> UIColor {
        return UIColor(red: 121, green: 118, blue: 180)
    }
    
    // #673A96
    static func jjDarkPurpleColor() -> UIColor {
        return UIColor(red: 103, green: 58, blue: 150)
    }
}
