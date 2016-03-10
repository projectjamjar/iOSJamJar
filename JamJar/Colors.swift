//
//  Colors.swift
//  JamJar
//
//  Created by Mark Koh on 3/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

extension UIColor {
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
    
    class func jjCoralColor() -> UIColor {
        return UIColor(red: 241, green: 95, blue: 78)
    }
}
