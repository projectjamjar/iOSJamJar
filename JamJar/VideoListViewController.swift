//
//  VideoListViewController.swift
//  JamJar
//
//  Created by Mark Koh on 3/12/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class VideoListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
//    @IBOutlet weak var sectionPicker: UISegmentedControl!
//    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    var concert: Concert? = nil
    var videos: [Video] = [Video]()
    var filteredVideos: [Video] = [Video]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the reusable video cell
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        
        // Initialize the filteredVideos to the video list
        filteredVideos = videos
        
        if let concert = self.concert {
            self.title = concert.getArtistsString()
            
            // Make Image round and assign image
            self.artistImageView.cropToCircle()
            self.artistImageView.image = concert.getArtists()[0].getImage()
            
            // Assign Artist to label
            self.artistLabel.text = concert.getArtistsString()
            
            // Assign Date to label
            self.dateLabel.text = concert.date.string("MM-d-YYYY")
            
            // Assign Venue to Label
            self.venueLabel.text = concert.venue.name
        }
    }
    
    
    /***************************************************************************
        TableView Setup
    ***************************************************************************/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredVideos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = self.filteredVideos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        
        cell.setup(video)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Video selected: \(indexPath.row)")
    }
    
    /***************************************************************************
        Search Bar Setup
    ***************************************************************************/
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let lowerCaseSearchString = searchText.lowercaseString
        // Filter videos by name, username, and artist
        self.filteredVideos = self.videos.filter { (video) -> Bool in
            if video.name.lowercaseString.containsString(lowerCaseSearchString) ||
               video.user.username.lowercaseString.containsString(lowerCaseSearchString) ||
                video.getArtistsString().lowercaseString.containsString(lowerCaseSearchString) {
                    return true
            }
            else {
                return false
            }
        }
        
        self.tableView.reloadData()
    }
}

