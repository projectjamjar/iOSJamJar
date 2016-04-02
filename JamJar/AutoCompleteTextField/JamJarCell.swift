//
//  JamJarCell.swift
//  JamJar
//
//  Created by Ethan Riback on 4/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class JamJarCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var jamjarTitleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var contributorsLabel: UILabel!
    @IBOutlet weak var lengthTimeLabel: UILabel!
    
    var jamjar: JamJarGraph!
    
    func setup(jamjar: JamJarGraph, startVideo: Video) {
        self.jamjar = jamjar
        
        // Assign JamJar title
        jamjarTitleLabel.text = "JamJar Title"
        
        // Assign view count
        viewsLabel.text = "\(123) views"
        
        // Assign contributor count
        contributorsLabel.text = "\(jamjar.count) contributors"
        
        // Assign length of time
        lengthTimeLabel.text = "123 Minutes"
        
        // Set the thumbnail to the first video with the target thumbnail size
        if let thumbImage = startVideo.thumbnailForSize(256) {
            thumbnailImageView.image = thumbImage
            thumbnailImageView.layer.borderColor = UIColor.jjCoralColor().CGColor
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFit
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
        
        // Round the edges of the imageview
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.cornerRadius = 5.0
        thumbnailImageView.clipsToBounds = true
    }
}