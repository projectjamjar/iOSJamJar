//
//  VideoPageViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 4/11/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SCLAlertView

class VideoPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var video: Video!
    weak var concert: Concert!
    var reasonsToFlag: [String]!
    
    //IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploaderLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var suggestedTableView: UITableView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var concertInfoView: UIView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var dislikesCountLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // PROTECT YO SELF
        // If the video is still processin, pop that shit from the navcontroller
        if !self.video.uploaded {
            self.navigationController?.popViewControllerAnimated(false)
        }
        
        //Add action for concert tapped
        let concertTap = UITapGestureRecognizer(target: self, action: #selector(VideoPageViewController.concertTapped(_:)))
        self.concertInfoView.addGestureRecognizer(concertTap)
        
        //Set up UI Elements
        titleLabel.text = video.name
        uploaderLabel.text = video.user.username
        viewCountLabel.text = String(video.views) + " Views"
        artistsLabel.text = video.getArtistsString()
        venueLabel.text = concert.venue.name
        dateLabel.text = concert.date.string("MM-d-YYYY")
        likesCountLabel.text = String((video.videoVotes.filter{$0.vote == 1}.first?.total)!)
        dislikesCountLabel.text = String((video.videoVotes.filter{$0.vote == 0}.first?.total)!)
        updateLikeDislikeButtons()
        
        // Register the reusable video cell
        self.suggestedTableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.suggestedTableView.registerNib(UINib(nibName: "JamJarHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "JamJarHeader")
        
        // Set Report Reasons Data
        self.reasonsToFlag = ["Accuracy", "Inappropriate", "Quality","Report User"];
        
        self.suggestedTableView.reloadData()
        
        // Acknowledge the video was viewed here
        self.recordView(self.video.id!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //When the video page is dismissed, remove observers from the AVPlayerController
        removeOberservsInPlayer()
    }
    
    // Record a view
    func recordView(videoId: Int!) {
        VideoService.watchingVideo(videoId)
    }
    
    //make embedded controller full screen
    func fullScreenVideo() {
        //hide navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    
    //Worst function name ever
    func unfullScreenVideo() {
        //show navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
    }
    
    func removeOberservsInPlayer() {
        for controller in self.childViewControllers {
            if let child = controller as? JamJarAVPlayerViewController {
                child.removeObservers()
            }
        }
    }
    
    func changeVideoInPlayer() {
        for controller in self.childViewControllers {
            if let child = controller as? JamJarAVPlayerViewController {
                child.removeObservers()
                let videoPath = NSURL(string: self.video.hls_src)
                child.player = AVPlayer(URL: videoPath!)
                child.viewDidLoad()
            }
        }
    }
    
    func updateLikeDislikeButtons() {
        self.likeButton.selected = (video.userVote == true)
        self.dislikeButton.selected = (video.userVote == false)
        self.likeButton.highlightBackgroundLike()
        self.dislikeButton.highlightBackgroundDislike()
    }
    
    func concertTapped(sender:AnyObject) {
        self.performSegueWithIdentifier("ToConcertPage", sender: nil)
    }
    
    @IBAction func likePressed(sender: UIButton) {
        if(video.userVote == true) {
            VideoService.vote(video.id, vote: nil) { success, error in
                if !success {
                    // Error - show the user
                    let errorTitle = "Video error!"
                    if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                    else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                } else {
                    self.video.userVote = nil
                    self.updateLikeDislikeButtons()
                }
            }
        } else {
            VideoService.vote(video.id, vote: true) { success, error in
                if !success {
                    // Error - show the user
                    let errorTitle = "Video error!"
                    if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                    else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                } else {
                    self.video.userVote = true
                    self.updateLikeDislikeButtons()
                }
            }
        }
    }
    
    @IBAction func dislikePressed(sender: UIButton) {
        if(video.userVote == false) {
            VideoService.vote(video.id, vote: nil) { success, error in
                if !success {
                    // Error - show the user
                    let errorTitle = "Video error!"
                    if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                    else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                } else {
                    self.video.userVote = nil
                    self.updateLikeDislikeButtons()
                }
            }
        } else {
            VideoService.vote(video.id, vote: false) { success, error in
                if !success {
                    // Error - show the user
                    let errorTitle = "Video error!"
                    if let error = error { SCLAlertView().showError(errorTitle, subTitle: error, closeButtonTitle: "Got it") }
                    else { SCLAlertView().showError(errorTitle, subTitle: "", closeButtonTitle: "Got it") }
                } else {
                    self.video.userVote = false
                    self.updateLikeDislikeButtons()
                }
            }
        }
    }
    
    @IBAction func flagVideoTapped(sender: UIButton) {
        let flagView = SCLAlertView()
        
        // Creat the subview
        let subview = UIView(frame: CGRectMake(0,0,216,100))
        let x = (subview.frame.width - 180) / 2
        
        // reason label
        let reasonLabel = UILabel(frame: CGRectMake(x,5,180,25))
        reasonLabel.text = "Reason:"
        subview.addSubview(reasonLabel)
        
        // reason PickerView
        let reasonPickerView = UIPickerView(frame: CGRectMake(x,10,180,100))
        reasonPickerView.delegate = self
        reasonPickerView.dataSource = self
        subview.addSubview(reasonPickerView)
        
        // Add the subview to the alert's UI property
        flagView.customSubview = subview
        
        // Add Notes Text Field
        let notes = flagView.addTextField("Notes")
        
        flagView.addButton("Submit") {
            let reason = self.reasonsToFlag[reasonPickerView.selectedRowInComponent(0)]
            
            var flagType: String
            if reason == "Report User" {
                flagType = "U"
            } else {
                flagType = String(reason[reason.startIndex])
            }
            
            VideoService.flag(self.video.id, reason: flagType, notes: notes.text) { success, result in
                if !success {
                    // Error - show the error
                    let errorTitle = "Video Flag Error!"
                    SCLAlertView().showError(errorTitle, subTitle: result!, closeButtonTitle: "Got it")
                } else {
                    // Success
                    let successTitle = "Video Flagged!"
                    SCLAlertView().showSuccess(successTitle, subTitle: result!, closeButtonTitle: "Got it")
                }
            }
        }
        
        flagView.showEdit("Flag Video", subTitle: "Reason", closeButtonTitle: "Cancel")
    }
    
    //Allow rotate
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            unfullScreenVideo()
            break
        default:
            fullScreenVideo()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            unowned let embeddedVideoViewController = segue.destinationViewController as! JamJarAVPlayerViewController
            print(self.video.hls_src)
            
            let videoPath = NSURL(string: self.video.hls_src)
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath!)
        }
        else if segue.identifier == "ToConcertPage" {
            let vc = segue.destinationViewController as! ConcertPageViewController
            vc.concert = self.concert
        }
    }
    
    /***************************************************************************
     TableView Setup
     ***************************************************************************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("JamJarHeader") as! JamJarHeader
        headerCell.backgroundColor = UIColor.grayColor()
        headerCell.setup("Suggested Content", number: 0, status: true)
        headerCell.hideStatus()
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concert.videos.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var videoList: [Video] = self.concert!.videos!.filter { (video) -> Bool in
            return !(video.id! == self.video.id)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        
        cell.setup(videoList[indexPath.row], concert: self.concert, viewController: self)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoCell = tableView.cellForRowAtIndexPath(indexPath) as! VideoCell
        self.video = videoCell.video
        changeVideoInPlayer()
        self.viewDidLoad()
    }
    
    /***************************************************************************
     UIPickerView Setup
     ***************************************************************************/
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reasonsToFlag.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reasonsToFlag[row]
    }
}