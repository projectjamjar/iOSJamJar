//
//  VideoCell.swift
//  JamJar
//
//  Created by Mark Koh on 3/12/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var uploaderLabel: UILabel!
    @IBOutlet weak var dateVenueLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    var video: Video!
    
    func setup(video: Video) {
        self.video = video
        
        // Set the thumbnail to the first video with the target thumbnail size
        if let thumbImage = self.video.thumbnailForSize(256) {
            thumbnailImageView.image = thumbImage
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFit
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
        }
        
        // Join all artist names and set the artist label
        let artistNames: [String] = self.video.artists.map({return $0.name})
        let artistsString = artistNames.joinWithSeparator(", ")
        artistLabel.text = artistsString
        
        // Get and format the date and venue
//        let dateString = self.video.concert.string("MM-d-YYYY")
//        let venueString = self.concert.venue.name
//        dateVenueLabel.text = "\(dateString) | \(venueString)"
        
        // Number of videos
        let numViews = self.video.views
        viewCountLabel.text = "\(numViews) views"
        
        
    }
}
