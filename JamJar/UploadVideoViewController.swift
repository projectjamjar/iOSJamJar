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

class UploadVideoViewController: BaseViewController {
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: VenueSearchResult!
    var selectedDate: NSDate!
    
    //Information to maintain information on all videos
    var currentVideoSelected = 0
    var videosToUpload: [NSURL] = []
    var namesOfVideos: [String]!
    var publicPrivateStatusOfVideos: [Int]!
    
    // Keep track of upload progress
    var queue: Int = 0
    
    //Variable to store video frame
    var videoContainerFrameInPortrait: CGRect!
    
    //UI Outlets
    @IBOutlet var videoNameTextField: UITextField!
    @IBOutlet var publicPrivateSegmentedControl: UISegmentedControl!
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Prevents view from bugging out when it starts in landscape mode.
        if(!UIDevice.currentDevice().orientation.isPortrait) {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
        
        //Save the potrait video frame
        videoContainerFrameInPortrait = self.videoContainerView.frame
        
        //placeholder text for videoNameTextField needs to be set to white
//        videoNameTextField.attributedPlaceholder = NSAttributedString(string:"Video Name",
//            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        videoNameTextField.setColoredPlaceholder("Video Name...")
        
        //removes the white background from the corners to make the UI look better
        self.publicPrivateSegmentedControl.layer.cornerRadius = 5.0;
        
        //set default information for namesOfVideos and publicPrivateStatusOfVideos
//        self.namesOfVideos = [String](count:self.videosToUpload.count, repeatedValue: "")
        self.namesOfVideos = self.videosToUpload.map { return $0.lastPathComponent! }
        self.publicPrivateStatusOfVideos = [Int](count:self.videosToUpload.count, repeatedValue: 0)
        
        // Set the initial Video Name text field
        self.videoNameTextField.text = self.namesOfVideos[0]
        
        if(self.videosToUpload.count < 2) {
            self.leftButton.hidden = true
            self.leftButton.enabled = false
            self.rightButton.hidden = true
            self.rightButton.enabled = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //When the page is reset, remove observers from the AVPlayerController
        for controller in self.childViewControllers {
            if let child = controller as? JamJarAVPlayerViewController {
                child.removeObservers()
            }
        }
    }
    
    func changeVideo(newIndex: Int) {
        //Update video
        let embeddedVideoViewController = self.childViewControllers[0] as! JamJarAVPlayerViewController
        let videoPath = self.videosToUpload[currentVideoSelected]
        embeddedVideoViewController.removeObservers()
        embeddedVideoViewController.player = AVPlayer(URL: videoPath)
        embeddedVideoViewController.viewDidLoad()
        
        //update videoNameTextField
        self.videoNameTextField.text = self.namesOfVideos[newIndex]
        
        //update publicPrivateSegmentedControl
        self.publicPrivateSegmentedControl.selectedSegmentIndex = self.publicPrivateStatusOfVideos[newIndex]
    }
    
    @IBAction func leftButtonPressed(sender: UIButton) {
        currentVideoSelected -= 1
        if(currentVideoSelected < 0) {
            currentVideoSelected = (videosToUpload.count) - 1
        }
        changeVideo(currentVideoSelected)
    }
    
    @IBAction func rightButtonPressed(sender: UIButton) {
        currentVideoSelected += 1
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
        let prettyDate = self.selectedDate.string(shortDateFormat)
        ConcertService.create(self.selectedVenue.place_id, date: prettyDate) {
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
        showProgressView()
        self.queue = self.videosToUpload.count
        
        for index in 0...(self.videosToUpload.count) - 1 {
            VideoService.upload(self.videosToUpload[index], name: self.namesOfVideos[index], is_private: self.publicPrivateStatusOfVideos[index], concert_id: concert_id, artists: self.selectedArtists) { (success: Bool, message: String?) in
                if !success {
                    // Error - show the user and clear previous search info
                    showErrorView()
                    SCLAlertView().showError("Upload Error!", subTitle: message!, closeButtonTitle: "Got it")
                } else {
                    self.callback()
                }
            }
            
        }
    }
    
    // Keep track of videos uploaded
    func callback()
    {
        self.queue -= 1
        // Execute final callback when queue is empty
        if self.queue == 0 {
            showSuccessView()
            self.resetUploadControllers()
        }
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
    
    //reset view
    func resetUploadControllers() {
        let chooseViewController = self.navigationController?.viewControllers[((self.navigationController?.viewControllers.count)! - 2)] as! ChooseVideosViewController
        
        chooseViewController.clearVideos()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let embeddedVideoViewController = segue.destinationViewController as! JamJarAVPlayerViewController
            
            let videoPath = self.videosToUpload[currentVideoSelected]
            let videoPlayer = AVPlayer(URL: videoPath)
            
            embeddedVideoViewController.showFullScreenButton = false
            embeddedVideoViewController.player = videoPlayer
        }
    }
}