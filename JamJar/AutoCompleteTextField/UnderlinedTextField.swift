//
//  UnderlinedTextField.swift
//  JamJar
//
//  Created by Ethan Riback on 2/23/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Foundation
import UIKit

public class UnderlinedTextField:UITextField {
    public override func awakeFromNib() {
        super.awakeFromNib()
        let startY = self.frame.height - 2
        let lineView = UIView(frame: CGRectMake(0,startY,self.frame.width,2.0))
        lineView.backgroundColor = UIColor.whiteColor()
        self.addSubview(lineView)
    }
}