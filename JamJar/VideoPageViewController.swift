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
    
    var video: Video!
    var concert: Concert!
    weak var embeddedVideoViewController: JamJarAVPlayerViewController!
    
    //IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploaderLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var likeDislikeLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var suggestedTableView: UITableView!
    
    //Variable to store video frame
    var videoFrameInPortrait: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.embeddedVideoViewController = self.childViewControllers[0] as! JamJarAVPlayerViewController
        
        //Save the potrait video frame
        videoFrameInPortrait = self.embeddedVideoViewController.view.frame
        
        //Set up UI Elements
        titleLabel.text = video.name
        uploaderLabel.text = video.user.username
        viewCountLabel.text = String(video.views) + " Views"
        artistsLabel.text = video.getArtistsString()
        venueLabel.text = concert.venue.name
        dateLabel.text = concert.date.string("MM-d-YYYY")
        
        // Register the reusable video cell
        self.suggestedTableView.registerNib(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        self.suggestedTableView.registerNib(UINib(nibName: "JamJarHeaderCell", bundle: nil), forCellReuseIdentifier: "JamJarHeaderCell")
        
        self.suggestedTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //make embedded controller full screen
    func fullScreenVideo() {
        //hide navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        
        //create offset in height from tabbar and navigationbar
        //TODO: This offset isn't calculated properly. Fix this if needed
        // 81 - 17 = 64
        let offset = (self.tabBarController!.tabBar.frame.size.height + self.navigationController!.navigationBar.frame.size.height - 17) * -1
        
        UIView.animateWithDuration(0.25) {
            self.embeddedVideoViewController.view.frame = CGRect(x: 0, y: offset, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    //Worst function name ever
    func unfullScreenVideo() {
        //show navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        
        UIView.animateWithDuration(0.25) {
            self.embeddedVideoViewController.view.frame = self.videoFrameInPortrait
        }
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
        case .LandscapeLeft,.LandscapeRight:
            fullScreenVideo()
            break
        default:
            print("Unknown Orientation")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let embeddedVideoViewController = segue.destinationViewController as! JamJarAVPlayerViewController
            print(self.video.hls_src)
            
            //let videoPath = NSURL(string: "http://144.118.231.71:8000/out.m3u8")
            let videoPath = NSURL(string: self.video.hls_src)
            //let videoPath = NSURL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
            //let videoPath = NSURL(string: "http://devstreaming.apple.com/videos/wwdc/2015/106z3yjwpfymnauri96m/106/hls_vod_mvp.m3u8")
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath!)
        }
    }
    
    /***************************************************************************
     TableView Setup
     ***************************************************************************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("JamJarHeaderCell") as! JamJarHeaderCell
        headerCell.backgroundColor = UIColor.grayColor()
        headerCell.setup("Suggested Videos", number: 0, status: true)
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
        self.viewDidLoad()
    }
}