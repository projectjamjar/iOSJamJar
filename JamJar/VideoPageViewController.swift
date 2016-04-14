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

class VideoPageViewController: BaseViewController{
    
    var video: Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            print(self.video.hls_src)
            
            let videoPath = NSURL(string: self.video.hls_src)
            //let videoPath = NSURL(string: "https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")
            //let videoPath = NSURL(string: "http://devstreaming.apple.com/videos/wwdc/2015/106z3yjwpfymnauri96m/106/hls_vod_mvp.m3u8")
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath!)
        }
    }
}