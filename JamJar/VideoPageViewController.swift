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

class VideoPageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var video: Video!
    weak var concert: Concert!
    
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
    
    //Variable to store video frame
    var videoContainerFrameInPortrait: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Save the potrait video frame
        videoContainerFrameInPortrait = self.videoContainerView.frame
        
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
        
        // Register the reusable video cell
        self.suggestedTableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.suggestedTableView.registerNib(UINib(nibName: "JamJarHeaderCell", bundle: nil), forCellReuseIdentifier: "JamJarHeaderCell")
        
        self.suggestedTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //When the video page is dismissed, remove observers from the AVPlayerController
        removeOberservsInPlayer()
    }
    
    //make embedded controller full screen
    func fullScreenVideo() {
        //hide navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        
        UIView.animateWithDuration(0.25) {
            self.videoContainerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    //Worst function name ever
    func unfullScreenVideo() {
        //show navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        
        UIView.animateWithDuration(0.25) {
            self.videoContainerView.frame = self.videoContainerFrameInPortrait
        }
        
        self.view.layoutIfNeeded()
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
            video.userVote = nil
        } else {
            video.userVote = true
        }
        updateLikeDislikeButtons()
    }
    
    @IBAction func dislikePressed(sender: UIButton) {
        if(video.userVote == false) {
            video.userVote = nil
        } else {
            video.userVote = false
        }
        updateLikeDislikeButtons()
    }
    
    @IBAction func flagVideoTapped(sender: UIButton) {
        print("Flagged Video")
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
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("JamJarHeaderCell") as! JamJarHeaderCell
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
        
        cell.setup(videoList[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoCell = tableView.cellForRowAtIndexPath(indexPath) as! VideoCell
        self.video = videoCell.video
        changeVideoInPlayer()
        self.viewDidLoad()
    }
}