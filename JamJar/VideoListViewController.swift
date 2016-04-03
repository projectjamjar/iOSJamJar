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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    var concert: Concert? = nil
    var videos: [Video] = [Video]()
    var myVideos: [Video] = [Video]()
    var individualVideos: [Video] = [Video]()
    var jamjars: [JamJarGraph] = [JamJarGraph]()
    
    var showJamJars: Bool = true
    var showMyVideos: Bool = true
    var showIndividualVideos: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the reusable video cell
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.tableView.registerNib(UINib(nibName: "JamJarCell", bundle: nil), forCellReuseIdentifier: "JamJarCell")
        self.tableView.registerNib(UINib(nibName: "JamJarHeaderCell", bundle: nil), forCellReuseIdentifier: "JamJarHeaderCell")
        
        // Set JamJars
        ConcertService.getJamJars((self.concert?.id)!) {
            (success, result, error) in
            if !success {
                // Error - show the user
                let errorTitle = "JamJar error!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Successfully retrieved JamJars, store them
                self.jamjars = result!
                self.tableView.reloadData()
            }
        }
        
        // Set myVideos
        self.myVideos = self.videos.filter { (video) -> Bool in
            return (video.user.username.lowercaseString == UserService.currentUser()?.username.lowercaseString)
        }
        
        // Set individualVideos
        self.individualVideos = self.videos.filter { (video) -> Bool in
            return !(video.user.username.lowercaseString == UserService.currentUser()?.username.lowercaseString)
        }
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("JamJarHeaderCell") as! JamJarHeaderCell
        headerCell.backgroundColor = UIColor.grayColor()
        
        switch (section) {
        case 0:
            headerCell.setup("JamJars", number: 0, status: showJamJars)
        case 1:
            headerCell.setup("My Videos", number: 1, status: showMyVideos)
        case 2:
            headerCell.setup("Individual Videos", number: 2, status: showIndividualVideos)
        default:
            headerCell.setup("Error", number: -1, status: false)
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "collapseExpandSection:")
        tap.cancelsTouchesInView = true
        headerCell.addGestureRecognizer(tap)
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            if(showJamJars) {
                return self.jamjars.count
            }
        case 1:
            if(showMyVideos) {
                return self.myVideos.count
            }
        case 2:
            if(showIndividualVideos) {
                return self.individualVideos.count
            }
        default:
            return 0
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //TODO: Get a code review for this, could be refactored to separate videos from JamJars
        //cell for JamJar
        if(indexPath.section == 0) {
            let jamjar = self.jamjars[indexPath.row]
            
            //retrieve first video
            let firstVideo = self.videos.filter { (video) -> Bool in
                return (video.id == jamjar.startId)
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("JamJarCell", forIndexPath: indexPath) as! JamJarCell
            cell.setup(jamjar, startVideo: firstVideo[0])
            
            return cell
        }
        
        //cell for everything else
        var videoList: [Video] = [Video]()
        
        switch (indexPath.section) {
        case 0:
            print("Error: JamJar trying to use VideoCell")
        case 1:
            videoList = self.myVideos
        case 2:
            videoList = self.individualVideos
        default:
            print("Error: Not a Section")
        }
        
        let video = videoList[indexPath.row]
        
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
    /*
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
    */
    
    /***************************************************************************
     Header Cell Action
     ***************************************************************************/
    //Calls this function when the tap is recognized.
    func collapseExpandSection(sender: UITapGestureRecognizer) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        let headerCell = sender.view as! JamJarHeaderCell
        
        switch (headerCell.sectionNumber) {
        case 0:
            showJamJars = !showJamJars
        case 1:
            showMyVideos = !showMyVideos
        case 2:
            showIndividualVideos = !showIndividualVideos
        default:
            print("Error: Not a Section")
        }
        self.tableView.reloadData()
    }
}

