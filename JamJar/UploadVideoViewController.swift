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
    
    var currentVideoSelected = 0
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
        
        //placeholder text for videoNameTextField needs to be set to white
        videoNameTextField.attributedPlaceholder = NSAttributedString(string:"Video Name",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        //removes the white background from the corners to make the UI look better
        self.publicPrivateSegmentedControl.layer.cornerRadius = 5.0;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeVideo(newIndex: Int) {
        print("Change Video")
        let embeddedVideoViewController = self.childViewControllers[0] as! AVPlayerViewController
        
        let videoPath = self.videosToUpload![currentVideoSelected]["UIImagePickerControllerReferenceURL"]
        
        embeddedVideoViewController.player = AVPlayer(URL: videoPath as! NSURL)
    }
    
    @IBAction func leftButtonPressed(sender: UIButton) {
        currentVideoSelected--
        if(currentVideoSelected < 0) {
            currentVideoSelected = (videosToUpload?.count)! - 1
        }
        changeVideo(currentVideoSelected)
    }
    
    @IBAction func rightButtonPressed(sender: UIButton) {
        currentVideoSelected++
        if(currentVideoSelected >= videosToUpload?.count) {
            currentVideoSelected = 0
        }
        changeVideo(currentVideoSelected)
    }
    
    @IBAction func uploadVideos(sender: UIButton) {
        print("Upload the Videos!")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            print("play video")
            print(self.videosToUpload)
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videosToUpload![currentVideoSelected]["UIImagePickerControllerReferenceURL"]
            print(videoPath)
            //let videoURL = NSURL(fileURLWithPath: videoPath)
            //print(videoURL)
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath as! NSURL)
        }
    }
}