//
//  UploadVideoViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 2/20/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class UploadVideoViewController: BaseViewController{
    
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    var videoToUpload: [String:AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(selectedVenue.description)
        //print(self.videoToUpload)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            print("play video")
            print(self.videoToUpload)
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videoToUpload!["UIImagePickerControllerMediaURL"]
            print(videoPath)
            //let videoURL = NSURL(fileURLWithPath: videoPath)
            //print(videoURL)
            
            embeddedVideoViewController.player = AVPlayer(URL: self.videoToUpload!["UIImagePickerControllerMediaURL"] as! NSURL)
        }
    }
}