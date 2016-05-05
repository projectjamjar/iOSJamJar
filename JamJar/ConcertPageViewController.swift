//
//  ConcertPageViewController.swift
//  JamJar
//
//  Created by Mark Koh on 3/12/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class ConcertPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var concert: Concert? = nil
    var myVideos: [Video] = [Video]()
    var individualVideos: [Video] = [Video]()
    
    var showJamJars: Bool = true
    var showMyVideos: Bool = true
    var showIndividualVideos: Bool = true
    
    var selectedVideo: Video? = nil
    var selectedJamJar: JamJarGraph? = nil
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add overlay to background image
        self.backgroundImageView.addOverLay(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3))
        
        // Register the reusable video cell
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.tableView.registerNib(UINib(nibName: "JamJarCell", bundle: nil), forCellReuseIdentifier: "JamJarCell")
        self.tableView.registerNib(UINib(nibName: "JamJarHeaderCell", bundle: nil), forCellReuseIdentifier: "JamJarHeaderCell")
        
        self.refreshTableView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ConcertPageViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl) // not required when using UITableViewController
    }
    
    func refresh(sender:AnyObject)
    {
        self.refreshTableView()
    }
    
    func refreshTableView() {
        showProgressView()
        // Set Update Concert Information
        ConcertService.getConcertDetails((self.concert?.id)!) {
            (success, result, error) in
            if !success {
                // Error - show the user
                let errorTitle = "Concert error!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Successfully retrieved JamJars, store them
                self.concert = result!
                
                // Set myVideos
                self.myVideos = self.concert!.videos!.filter { (video) -> Bool in
                    return (video.user.username.lowercaseString == UserService.currentUser()?.username.lowercaseString)
                }
                
                // Set individualVideos
                self.individualVideos = self.concert!.videos!.filter { (video) -> Bool in
                    return !(video.user.username.lowercaseString == UserService.currentUser()?.username.lowercaseString)
                }
                
                if let concert = self.concert {
                    self.title = concert.getArtistsString()
                    
                    // Make Image round and assign image
                    self.artistImageView.cropToCircle()
                    self.artistImageView.image = concert.getMostPopularArtist().getImage()
                    
                    // Assign Artist to label
                    self.artistLabel.text = concert.getArtistsString()
                    
                    // Assign Date to label
                    self.dateLabel.text = concert.date.string("MM-d-YYYY")
                    
                    // Assign Venue to Label
                    self.venueLabel.text = concert.venue.name
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            hideProgressView()
        }
    }
    
    
    /***************************************************************************
        TableView Setup
    ***************************************************************************/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConcertPageViewController.collapseExpandSection(_:)))
        tap.cancelsTouchesInView = true
        headerCell.addGestureRecognizer(tap)
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 0
            /*
            if(showJamJars) {
                return (self.concert?.jamjars?.count)!
            }*/
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
            let jamjar = self.concert!.jamjars![indexPath.row]
            
            //retrieve first video
            let firstVideo = self.concert!.videos!.filter { (video) -> Bool in
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
        switch (indexPath.section) {
        case 0:
            //let jamjarCell = tableView.cellForRowAtIndexPath(indexPath) as! JamJarCell
            SCLAlertView().showError("Under Construction!", subTitle: "JamJars will be available soon!", closeButtonTitle: "Got it")
            print("Push to JamJar Controller")
        default:
            let videoCell = tableView.cellForRowAtIndexPath(indexPath) as! VideoCell
            selectedVideo = videoCell.video
            
            self.performSegueWithIdentifier("ToVideoPage", sender: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: self)
        
        if segue.identifier == "ToVideoPage" {
            let vc = segue.destinationViewController as! VideoPageViewController
            vc.video = self.selectedVideo!
            vc.concert = self.concert!
        }
    }
}

