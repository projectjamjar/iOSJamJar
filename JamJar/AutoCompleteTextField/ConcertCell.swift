//
//  ConcertCell.swift
//  JamJar
//
//  Created by Mark Koh on 3/10/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class ConcertCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateVenueLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    var concert: Concert!
    
    func setup(concert: Concert) {
        self.concert = concert
        
        // Set the thumbnail to the first video with the target thumbnail size
        if let thumbImage = self.concert.thumbnailForSize(256) {
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
        
        
        // Join all artist names and set the artist label
        artistLabel.text = concert.getArtistsString()
        
        // Get and format the date and venue
        let dateString = self.concert.date.string("MM-d-YYYY")
        let venueString = self.concert.venue.name
        dateVenueLabel.text = "\(dateString) | \(venueString)"
        
        // Number of videos
        let numVideos = self.concert.videos_count
        videoCountLabel.text = "\(numVideos) videos"
        
        
    }
}