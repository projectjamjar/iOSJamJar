//
//  ProfileViewController.swift
//  JamJar
//
//  Created by Mark Koh on 5/4/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import SCLAlertView

class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Always set this!  This is how we get the data for the view
    var username: String?
    
    // Set this if possible, we'll use it to pre-populate part of the view
    var user: User? = nil
    
    // These get set once we fetch the data from the API
    var profile: UserProfile? = nil
    
    // State vars to tell us if these sections are expanded
    var showVideos: Bool = true
    var showConcerts: Bool = true
    
    // Segue variables
    var selectedVideo: Video? = nil
    var selectedConcert: Concert? = nil
    
    // Other shit
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the username to the current user if none is specified
        if self.username == nil {
            self.username = UserService.currentUser()?.username
        }
        
        //add overlay to background image
        self.backgroundImageView.addOverLay(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3))
        
        // Register the reusable video cell
        self.tableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.tableView.registerNib(UINib(nibName: "ConcertCell", bundle: nil), forCellReuseIdentifier: "JamJarCell")
//        self.tableView.registerNib(UINib(nibName: "JamJarHeaderCell", bundle: nil), forCellReuseIdentifier: "JamJarHeaderCell")
        self.tableView.registerNib(UINib(nibName: "JamJarHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "JamJarHeader")
        
        self.refreshTableView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ProfileViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl) // not required when using UITableViewController
    }
    
    // Called by PullToRefresh
    func refresh(sender:AnyObject)
    {
        self.refreshTableView()
    }
    
    func refreshTableView() {
        showProgressView()
        // Set Update Concert Information
        UserService.getUserProfile(self.username!) {
            (success, result, error) in
            if !success {
                // Error - show the user
                let errorTitle = "Profile error!"
                if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
            }
            else {
                // Successfully retrieved JamJars, store them
                self.profile = result!
                
                self.user = self.profile?.user
                
                self.updateUI()
                self.refreshControl.endRefreshing()
            }
            hideProgressView()
        }
    }
    
    func updateUI() {
        self.tableView.reloadData()
        
        if let user = self.user {
            self.usernameLabel.text = user.username
            self.fullNameLabel.text = user.fullName
        }
        
        if let profile = self.profile {
            // Do thingsss
        }
    }
    
    
    /***************************************************************************
     TableView Setup
     ***************************************************************************/
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if profile == nil {
            return 0
        }
        else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let  headerCell = tableView.dequeueReusableCellWithIdentifier("JamJarHeaderCell") as! JamJarHeaderCell
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("JamJarHeader") as! JamJarHeader
        header.backgroundColor = UIColor.grayColor()
        
        switch (section) {
        case 0:
            header.setup("Videos", number: 0, status: showVideos)
        case 1:
            header.setup("Concerts", number: 1, status: showConcerts)
        default:
            header.setup("Error", number: -1, status: false)
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConcertPageViewController.collapseExpandSection(_:)))
        tap.cancelsTouchesInView = true
        header.addGestureRecognizer(tap)
        
        return header
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            if(showVideos) && self.profile?.videos != nil {
                return self.profile!.videos.count
            }
        case 1:
            if(showConcerts) && self.profile?.concerts != nil {
                return self.profile!.concerts.count
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

        }
        
        switch (indexPath.section) {
        case 0:
            let video = self.profile!.videos[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
            cell.setup(video)
            
            return cell
        case 1:
            let concert = self.profile!.concerts[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("ConcertCell", forIndexPath: indexPath) as! ConcertCell
            cell.setup(concert)
            
            return cell
        default:
            print("Error: Not a Section")
            // This shouldn't happen
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch (indexPath.section) {
//        case 0:
//            //let jamjarCell = tableView.cellForRowAtIndexPath(indexPath) as! JamJarCell
//            SCLAlertView().showError("Under Construction!", subTitle: "JamJars will be available soon!", closeButtonTitle: "Got it")
//            print("Push to JamJar Controller")
//        default:
//            let videoCell = tableView.cellForRowAtIndexPath(indexPath) as! VideoCell
//            selectedVideo = videoCell.video
//            
//            self.performSegueWithIdentifier("ToVideoPage", sender: nil)
//        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /***************************************************************************
     Header Cell Action
     ***************************************************************************/
    //Calls this function when the tap is recognized.
    func collapseExpandSection(sender: UITapGestureRecognizer) {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        let headerCell = sender.view as! JamJarHeader
        
        switch (headerCell.sectionNumber) {
        case 0:
            showVideos = !showVideos
        case 1:
            showConcerts = !showConcerts
        default:
            print("Error: Not a Section")
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: self)
        
//        if segue.identifier == "ToVideoPage" {
//            let vc = segue.destinationViewController as! VideoPageViewController
//            vc.video = self.selectedVideo!
//            vc.concert = self.concert!
//        }
    }
}