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
import SCLAlertView

class UploadVideoViewController: BaseViewController{
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    var selectedDate: String!
    
    //Information to maintain information on all videos
    var currentVideoSelected = 0
    var videosToUpload: [NSURL] = []
    var namesOfVideos: [String]!
    var publicPrivateStatusOfVideos: [Int]!
    
    //UI Outlets
    @IBOutlet var videoNameTextField: UITextField!
    @IBOutlet var publicPrivateSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //placeholder text for videoNameTextField needs to be set to white
        videoNameTextField.attributedPlaceholder = NSAttributedString(string:"Video Name",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        //removes the white background from the corners to make the UI look better
        self.publicPrivateSegmentedControl.layer.cornerRadius = 5.0;
        
        //set default information for namesOfVideos and publicPrivateStatusOfVideos
        self.namesOfVideos = [String](count:self.videosToUpload.count, repeatedValue: "")
        self.publicPrivateStatusOfVideos = [Int](count:self.videosToUpload.count, repeatedValue: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeVideo(newIndex: Int) {
        //Update video
        let embeddedVideoViewController = self.childViewControllers[0] as! AVPlayerViewController
        let videoPath = self.videosToUpload[currentVideoSelected]
        embeddedVideoViewController.player = AVPlayer(URL: videoPath)
        
        //update videoNameTextField
        self.videoNameTextField.text = self.namesOfVideos[newIndex]
        
        //update publicPrivateSegmentedControl
        self.publicPrivateSegmentedControl.selectedSegmentIndex = self.publicPrivateStatusOfVideos[newIndex]
    }
    
    @IBAction func leftButtonPressed(sender: UIButton) {
        currentVideoSelected--
        if(currentVideoSelected < 0) {
            currentVideoSelected = (videosToUpload.count) - 1
        }
        changeVideo(currentVideoSelected)
    }
    
    @IBAction func rightButtonPressed(sender: UIButton) {
        currentVideoSelected++
        if(currentVideoSelected >= videosToUpload.count) {
            currentVideoSelected = 0
        }
        changeVideo(currentVideoSelected)
    }
    
    @IBAction func videoNameTextFieldEdited(sender: UnderlinedTextField) {
        self.namesOfVideos[currentVideoSelected] = sender.text!
    }
    
    @IBAction func publicPrivateSelected(sender: UISegmentedControl) {
        self.publicPrivateStatusOfVideos[currentVideoSelected] = sender.selectedSegmentIndex
    }
    
    
    @IBAction func finishAndUploadButtonPressed(sender: UIButton) {
        // Post Concert
        ConcertService.create(self.selectedVenue.place_id, date: self.selectedDate) {
            (success: Bool, concert: Concert?, message: String?) in
            if !success {
                // Error - show the user and clear previous search info
                SCLAlertView().showError("Concert Error!", subTitle: message!, closeButtonTitle: "Got it")
            } else {
                self.uploadVideos((concert?.id)!)
            }
        }
    }
    
    func uploadVideos(concert_id: Int) {
        //begin for loop through videos
        for index in 0...(self.videosToUpload.count) - 1 {
            VideoService.upload(self.videosToUpload[index], name: self.namesOfVideos[index], is_private: self.publicPrivateStatusOfVideos[index], concert_id: concert_id, artists: self.selectedArtists) { (success: Bool, message: String?) in
                if !success {
                    // Error - show the user and clear previous search info
                    SCLAlertView().showError("Upload Error!", subTitle: message!, closeButtonTitle: "Got it")
                } else {
                    self.resetUploadControllers()
                }
            }
            
        }
    }
    
    func resetUploadControllers() {
        print("Delete all stored information and return to the previous view")
        let concertViewController = self.navigationController?.viewControllers[((self.navigationController?.viewControllers.count)! - 2)] as! EnterConcertInformationViewController
        
        concertViewController.clearViewForm()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videosToUpload[currentVideoSelected]
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath)
        }
    }
}