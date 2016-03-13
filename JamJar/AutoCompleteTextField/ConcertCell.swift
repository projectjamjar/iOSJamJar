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
        
        // Get the first video
        if let firstVideo = self.concert.videos.filter({$0.thumb_src != nil}).first {
            let targetThumbSize = "256"
            if let urlString = firstVideo.thumb_src[targetThumbSize],
                   url = NSURL(string: urlString),
                   data = NSData(contentsOfURL: url),
                   image = UIImage(data: data) {
                thumbnailImageView.image = image
            }
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFit
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
        }
        
        // Join all artist names and set the artist label
        let artistNames: [String] = self.concert.getArtists().map({return $0.name})
        let artistsString = artistNames.joinWithSeparator(", ")
        artistLabel.text = artistsString
        
        // Get and format the date and venue
        let dateString = self.concert.date.string("MM-d-YYYY")
        let venueString = self.concert.venue.name
        dateVenueLabel.text = "\(dateString) | \(venueString)"
        
        // Number of videos
        let numVideos = self.concert.videos.count
        videoCountLabel.text = "\(numVideos) videos"
        
        
    }
}