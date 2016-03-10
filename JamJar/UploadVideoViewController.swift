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
import Alamofire //TODO: remove this and have services working
import Photos
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
        print("Upload Videos!")
        
        let headers = [
            "Content-Type": "multipart/form-data",
            "Authorization": "Token \(AuthService.GetToken()!)"
        ]
        
        //begin for loop through videos
        for index in 0...(self.videosToUpload.count) - 1 {
            print(index)
            
            let parameters = [
                "name": self.namesOfVideos[index],
                "is_private": String((self.publicPrivateStatusOfVideos[index] == 1)),
                "concert": String(concert_id)
            ]
            
            let videoURL = self.videosToUpload[index]
            print(videoURL)
            
            Alamofire.upload(
                .POST,
                APIService.buildURL("videos"),
                headers: headers,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(fileURL: videoURL, name: "file")
                    
                    for (key, value) in parameters {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    }
                    
                    for artist in self.selectedArtists {
                        multipartFormData.appendBodyPart(data: String(artist.id).dataUsingEncoding(NSUTF8StringEncoding)!, name: "artists")
                    }
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            print("Sucess!")
                            debugPrint(response)
                        }
                    case .Failure(let encodingError):
                        print("Failure :(")
                        print(encodingError)
                    }
                }
            )
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videosToUpload[currentVideoSelected]
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath)
        }
    }
}