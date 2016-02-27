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

class UploadVideoViewController: BaseViewController{
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: Venue!
    var selectedDate: String!
    
    //Information to maintain information on all videos
    var currentVideoSelected = 0
    var videosToUpload: [AnyObject]?
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
        self.namesOfVideos = [String](count:self.videosToUpload!.count, repeatedValue: "")
        self.publicPrivateStatusOfVideos = [Int](count:self.videosToUpload!.count, repeatedValue: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeVideo(newIndex: Int) {
        //Update video
        let embeddedVideoViewController = self.childViewControllers[0] as! AVPlayerViewController
        let videoPath = self.videosToUpload![currentVideoSelected]["UIImagePickerControllerReferenceURL"]
        embeddedVideoViewController.player = AVPlayer(URL: videoPath as! NSURL)
        
        //update videoNameTextField
        self.videoNameTextField.text = self.namesOfVideos[newIndex]
        
        //update publicPrivateSegmentedControl
        self.publicPrivateSegmentedControl.selectedSegmentIndex = self.publicPrivateStatusOfVideos[newIndex]
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
    
    @IBAction func videoNameTextFieldEdited(sender: UnderlinedTextField) {
        self.namesOfVideos[currentVideoSelected] = sender.text!
    }
    
    @IBAction func publicPrivateSelected(sender: UISegmentedControl) {
        self.publicPrivateStatusOfVideos[currentVideoSelected] = sender.selectedSegmentIndex
    }
    
    
    @IBAction func finishAndUploadButtonPressed(sender: UIButton) {
        // Post Concert
        let concertParameters = [
            "venue_place_id": self.selectedVenue.place_id,
            "date": self.selectedDate
        ]
        
        APIService.post(APIService.buildURL("concerts"),parameters: concertParameters).response{request, response, data, error in
            
            let concertData = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            
            if let concert = concertData as? NSDictionary{
                if let concert_id = concert["id"] as? Int {
                    self.uploadVideos(concert_id)
                }
            }
        }
        
        print("finishAndUploadButtonPressed completed")
    }
    
    func uploadVideos(concert_id: Int) {
        print("Upload Videos!")
        //begin for loop through videos
        for index in 0...(self.videosToUpload?.count)! - 1 {
            print(index)
            
            let parameters = [
                "name": self.namesOfVideos[index],
                //"is_private": (self.publicPrivateStatusOfVideos[index] == 1),
                "concert": String(concert_id),
                "artists": selectedArtists[0].id
            ]
            
            let videoURL = self.videosToUpload![index]["UIImagePickerControllerReferenceURL"] as! NSURL
            
            let assets = PHAsset.fetchAssetsWithALAssetURLs([videoURL], options: nil)
            let firstAsset = assets.firstObject as! PHAsset
            print(firstAsset)
            
            PHCachingImageManager().requestAVAssetForVideo(firstAsset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                print("About to dispatch some muthafukkin shit!")
                dispatch_async(dispatch_get_main_queue(), {
                    let asset = asset as? AVURLAsset
                    print(asset?.URL)
                    let videoData = NSData(contentsOfURL: asset!.URL)
                    let headers = [
                        "Content-Type": "multipart/form-data",
                        "Authorization": "Token \(AuthService.GetToken()!)"
                    ]
                    
                    Alamofire.upload(
                        .POST,
                        APIService.buildURL("videos"),
                        headers: headers,
                        multipartFormData: { multipartFormData in
                            multipartFormData.appendBodyPart(data: videoData!, name: "file")
                            //multipartFormData.appendBodyPart(fileURL: self.videosToUpload![index]["UIImagePickerControllerMediaURL"] as! NSURL, name: "file")
                            
                            for (key, value) in parameters {
                                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
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
                })
            })
            
            /*
            // Add all artists to upload parameter
            for artist in selectedArtists {
                parameters
            }
            */
            
            /*
            Alamofire.upload(
                .POST,
                APIService.buildURL("videos"),
                multipartFormData: { multipartFormData in
                    let videoData = NSData(contentsOfURL: self.videosToUpload![index]["UIImagePickerControllerMediaURL"] as! NSURL)
                    let videoURL = self.videosToUpload![index]["UIImagePickerControllerReferenceURL"] as! NSURL
                    
                    let assets = PHAsset.fetchAssetsWithALAssetURLs([videoURL], options: nil)
                    let firstAsset = assets.firstObject as! PHAsset
                    print(firstAsset)
                    PHCachingImageManager().requestAVAssetForVideo(firstAsset, options: nil, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                        print("About to dispatch some muthafukkin shit!")
                        dispatch_async(dispatch_get_main_queue(), {
                            let asset = asset as? AVURLAsset
                            print(asset?.URL)
                            print("Butt")
                            
                        })
                    })
                    print("Test")
                    
                    multipartFormData.appendBodyPart(data: videoData!, name: "file")
                    //multipartFormData.appendBodyPart(fileURL: self.videosToUpload![index]["UIImagePickerControllerMediaURL"] as! NSURL, name: "file")
                    
                    for (key, value) in parameters {
                        multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
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
            */
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "playVideo") {
            print("play video")
            print(self.videosToUpload)
            
            let embeddedVideoViewController = segue.destinationViewController as! AVPlayerViewController
            
            let videoPath = self.videosToUpload![currentVideoSelected]["UIImagePickerControllerReferenceURL"]
            print(videoPath)
            
            embeddedVideoViewController.player = AVPlayer(URL: videoPath as! NSURL)
        }
    }
}