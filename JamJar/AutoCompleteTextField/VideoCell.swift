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
        
        videoNameLabel.text = self.video.name
        
        // Asynchronously fetch the thumbnail
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // Background - get thumbnail
            let thumbImage = self.video.thumbnailForSize(256)
            dispatch_async(dispatch_get_main_queue()) {
                // Manipulate the UI in the main thread
                self.setThumbnail(thumbImage)
            }
        }
        
        // Round the edges of the imageview
        thumbnailImageView.layer.borderWidth = 2
        thumbnailImageView.layer.cornerRadius = 5.0
        thumbnailImageView.clipsToBounds = true
        
        // Join all artist names and set the artist label
        let artistNames: [String] = self.video.artists.map({return $0.name})
        let artistsString = artistNames.joinWithSeparator(", ")
        artistLabel.text = artistsString
        
        // Get and format the date and venue
//        let dateString = self.video.concert.string("MM-d-YYYY")
//        let venueString = self.concert.venue.name
//        dateVenueLabel.text = "\(dateString) | \(venueString)"
        
        // Uploader label (we need to make clicking this do something tapgesturerecognizer)
        self.uploaderLabel.text = "@\(self.video.user.username)"
        
        // Number of videos
        let numViews = self.video.views
        viewCountLabel.text = "\(numViews) views"
        
        
    }
    
    func setThumbnail(image: UIImage?) {
        if let thumbImage = image {
            thumbnailImageView.image = thumbImage
            thumbnailImageView.layer.borderColor = UIColor.jjCoralColor().CGColor
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFit
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
    }
}
