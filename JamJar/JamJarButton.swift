//
//  RoundedButton.swift
//  JamJar
//
//  Created by Mark Koh on 5/12/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class JamJarButton: UIButton {
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.roundCorners(10.0)
    }
}
