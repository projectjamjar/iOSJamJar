//
//  JamJarHeaderCell.swift
//  JamJar
//
//  Created by Ethan Riback on 4/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class JamJarHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    var sectionNumber: Int!
    
    func setup(title: String, number: Int, status: Bool) {
        sectionLabel.text = title
        self.sectionNumber = number
        
        if(status) {
            statusImageView.image = UIImage(named: "down-arrow-white")
        } else {
            statusImageView.image = UIImage(named: "right-arrow-white")
        }
    }
    
    func hideStatus() {
        self.statusImageView.hidden = true
    }
}