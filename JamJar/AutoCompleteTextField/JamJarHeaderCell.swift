//
//  JamJarHeaderCell.swift
//  JamJar
//
//  Created by Ethan Riback on 4/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class JamJarHeaderCell: UITableViewCell {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var sectionNumber: Int!
    
    func setup(title: String, number: Int, status: Bool) {
        sectionLabel.text = title
        self.sectionNumber = number
        
        if(status) {
            statusLabel.text = "<"
        } else {
            statusLabel.text = ">"
        }
    }
}