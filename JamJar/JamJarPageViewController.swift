//
//  JamJarPageViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//
//  Note: This class has become a victim of code 
//  cloning. Due to deadlines, this can't be reversed
//  before the release of version 1.0. TODO: undo
//  the code cloning.
//

import UIKit
import AVKit
import AVFoundation

class JamJarPageViewController: BaseViewController, updateVideoDelegate {
    
    weak var jamjar: JamJarGraph!
    weak var concert: Concert!
    
    // UI Element
    @IBOutlet weak var jamJarContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploaderLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var suggestedTableView: UITableView!
    @IBOutlet weak var concertInfoView: UIView!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var dislikesCountLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    

    //Variable to store video frame
    var jamJarContainerFrameInPortrait: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Save the potrait jamjar frame
        jamJarContainerFrameInPortrait = self.jamJarContainerView.frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //When the video page is dismissed, remove observers from the AVPlayerController
        for controller in self.childViewControllers {
            if let child = controller as? StitchedJamJarAVPlayerViewController {
                child.removeObservers()
            }
        }
    }
    
    //make embedded controller full screen
    func fullScreenVideo() {
        //hide navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        
        UIView.animateWithDuration(0.25) {
            self.jamJarContainerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    //Worst function name ever
    func unfullScreenVideo() {
        //show navigation bar and tool bar
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        
        UIView.animateWithDuration(0.25) {
            self.jamJarContainerView.frame = self.jamJarContainerFrameInPortrait
        }
        
        self.view.layoutIfNeeded()
    }
    
    //Update video the UI elements
    func updateVideo(video: Video) {
        titleLabel.text = video.name
        uploaderLabel.text = video.user.username
        viewCountLabel.text = String(video.views) + " Views"
        artistsLabel.text = video.getArtistsString()
        venueLabel.text = concert.venue.name
        dateLabel.text = concert.date.string("MM-d-YYYY")
    }
    
    func concertTapped(sender:AnyObject) {
        self.performSegueWithIdentifier("ToConcertPage", sender: nil)
    }
    
    @IBAction func likePressed(sender: UIButton) {
        print("Liked Video")
    }
    
    @IBAction func dislikePressed(sender: UIButton) {
        print("Disliked Video")
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
        if(segue.identifier == "playJamJar") {
            unowned let embeddedVideoViewController = segue.destinationViewController as! StitchedJamJarAVPlayerViewController
            
            //define first video
            let firstVideo = self.concert.videos.filter{ $0.id == self.jamjar.startId }.first
            updateVideo(firstVideo!)
            let videoPath = NSURL(string: (firstVideo?.hls_src)!)
            
            embeddedVideoViewController.player = JamJarAVPlayer(URL: videoPath!, videoId: (firstVideo?.id)!)
            embeddedVideoViewController.currentVideo = firstVideo
            embeddedVideoViewController.videos = self.concert.videos
            embeddedVideoViewController.jamjar = self.jamjar
            embeddedVideoViewController.jamjarDelegate = self
        }
        else if segue.identifier == "ToConcertPage" {
            let vc = segue.destinationViewController as! ConcertPageViewController
            vc.concert = self.concert
        }
    }
}