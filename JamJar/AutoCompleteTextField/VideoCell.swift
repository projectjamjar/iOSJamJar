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
    var concert: Concert!
    
    // Store the viewController that we'll push the profile to if the user
    // button is clicked
    weak var viewController: UIViewController!
    
    func setup(video: Video, concert: Concert, viewController: UIViewController) {
        self.video = video
        self.concert = concert
        self.viewController = viewController
        
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
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.cornerRadius = 5.0
        thumbnailImageView.clipsToBounds = true
        
        // Join all artist names and set the artist label
        let artistNames: [String] = self.video.artists.map({return $0.name})
        let artistsString = artistNames.joinWithSeparator(", ")
        artistLabel.text = artistsString
        
        // Get and format the date and venue
        let dateString = self.concert.date.string("MM-d-YYYY")
        let venueString = self.concert.venue.name
        dateVenueLabel.text = "\(dateString) | \(venueString)"
        
        // Uploader label
        self.uploaderLabel.text = "@\(self.video.user.username)"
        // When clicked, bring up the profile for that user
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.uploaderLabelTapped))
        self.uploaderLabel.addGestureRecognizer(tgr)
        
        // Number of videos
        let numViews = self.video.views
        viewCountLabel.text = "\(numViews) views"
        
        
    }
    
    func setThumbnail(image: UIImage?) {
        if let thumbImage = image {
            thumbnailImageView.image = thumbImage
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
        else {
            thumbnailImageView.image = UIImage(named: "logo-transparent")
            thumbnailImageView.contentMode = .ScaleAspectFill
            thumbnailImageView.backgroundColor = UIColor.jjCoralColor()
            thumbnailImageView.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
    }
    
    func uploaderLabelTapped() {
        
        // Initialize the ProfileViewController for the uploader
        let vc = UIStoryboard(name: "Profile",bundle: nil).instantiateViewControllerWithIdentifier("Profile") as! ProfileViewController
        vc.username = self.video.user.username
        vc.user = self.video.user
        
        // Push it onto the navcontroller of our parent viewcontroller
        self.viewController.navigationController?.pushViewController(vc, animated: true)
        
    }
}
