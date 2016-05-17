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
    @IBOutlet weak var videoCountLabel: UILabel!
    
    var jamjar: JamJarGraph!
    
    func setup(jamjar: JamJarGraph, startVideo: Video) {
        self.jamjar = jamjar
        
        // Assign Video Count
        videoCountLabel.text = String((jamjar.nodes?.count)!) + " Videos"
        
        // Set the thumbnail to the first video with the target thumbnail size
        if let thumbImage = startVideo.thumbnailForSize(256) {
            thumbnailImageView.image = thumbImage
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFit
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
        
        // Round the edges of the imageview
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.cornerRadius = 5.0
        thumbnailImageView.clipsToBounds = true
    }
}