//
//  JamJarPageViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class JamJarPageViewController: BaseViewController {
    
    weak var jamjar: JamJarGraph!
    weak var concert: Concert!
    
    // UI Element
    @IBOutlet weak var jamJarContainerView: UIView!

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
            
            let videoPath = NSURL(string: "https://s3.amazonaws.com/jamjar-videos/prod/b31229ba-ac12-4acd-9f0f-28198ab2c9bc/video.m3u8")
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath!)
        }
        else if segue.identifier == "ToConcertPage" {
            let vc = segue.destinationViewController as! ConcertPageViewController
            vc.concert = self.concert
        }
    }
}