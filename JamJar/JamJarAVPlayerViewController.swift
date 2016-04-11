//
//  JamJarAVPlayerViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 4/11/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class JamJarAVPlayerViewController: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Disable the default Video Controls
        self.showsPlaybackControls = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Functions to add custom buttons
    
    // Play Button
    func createPlayButton() {
        let playButton   = UIButton(type: UIButtonType.System) as UIButton
        playButton.frame = CGRectMake(100, 100, 100, 50)
        playButton.backgroundColor = UIColor.greenColor()
        playButton.setTitle("Test Button", forState: UIControlState.Normal)
        playButton.addTarget(self, action: "playButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(playButton)
    }
    
    // Button Actions
    
    //Play/Pause functionality
    func playButtonAction(sender:UIButton!)
    {
        print("test")
        self.player?.pause()
    }
}