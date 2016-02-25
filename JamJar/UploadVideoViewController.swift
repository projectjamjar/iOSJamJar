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
    var videosToUpload: [AnyObject]?
    @IBOutlet var videoNameTextField: UITextField!
    @IBOutlet var publicPrivateSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(selectedVenue.description)
        //print(self.videoToUpload)
        
        //removes the white background from the corners to make the UI look better
        self.publicPrivateSegmentedControl.layer.cornerRadius = 5.0;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadVideos(sender: UIButton) {
        print("Upload the Videos!")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            print("play video")
            print(self.videosToUpload)
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videosToUpload![0]["UIImagePickerControllerReferenceURL"]
            print(videoPath)
            //let videoURL = NSURL(fileURLWithPath: videoPath)
            //print(videoURL)
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath as! NSURL)
        }
    }
}