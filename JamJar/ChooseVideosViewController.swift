//
//  VideoStagingArea.swift
//  JamJar
//
//  Created by Mark Koh on 5/11/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import DKImagePickerController
import SCLAlertView
import AVFoundation
import Photos
import KTCenterFlowLayout

class VideoItem: UICollectionViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var videoUrl: NSURL!
    var deleteCallback: ((videoURL: NSURL) -> Void)!
    
    func setup(videoUrl: NSURL, deleteCallback: ((videoURL: NSURL) -> Void)) {
        self.videoUrl = videoUrl
        self.deleteCallback = deleteCallback
        

        // Get the thumbnail for the video
        let asset = AVAsset(URL: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            self.thumbnailView.image = UIImage(CGImage: imageRef)
        } catch {
            print(error)
        }
        
        // Round the edges
        self.thumbnailView.layer.borderWidth = 2
        self.thumbnailView.layer.cornerRadius = 5.0
        self.thumbnailView.clipsToBounds = true
        self.thumbnailView.layer.borderColor = UIColor.jjCoralColor().CGColor
        
        // Also round the edges of the delete button
        self.deleteButton.layer.cornerRadius = 5.0
        self.deleteButton.clipsToBounds = true

     }
    
    @IBAction func deleteVideo(sender: UIButton?) {
        print("Delete: \(videoUrl)")
        self.deleteCallback(videoURL: self.videoUrl)
    }
}

class ChooseVideosViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var concertTitleLabel: UILabel!
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: VenueSearchResult!
    var selectedDate: NSDate!
    
    // Videos that are selected in this controller
    var videosToUpload: [NSURL] = []
    var queue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collection view flow styles
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 15.0
        layout.minimumLineSpacing = 15.0
        self.collectionView.setCollectionViewLayout(layout, animated: true)
        
        // Setup the title
        let artistNamesList: [String] = self.selectedArtists.map { return $0.name }
        let artistNamesString = artistNamesList.joinWithSeparator(", ")
        let dateString = self.selectedDate.string(prettyDateFormat)
        
        // Try to parse out the venue name from the string (google only gives us a long jawn)
        let commaIndex = self.selectedVenue.name.characters.indexOf(",")
        let concertString: String
        if let commaIndex = commaIndex {
            let venueName = self.selectedVenue.name.substringToIndex(commaIndex)
            concertString = "\(artistNamesString) @ \(venueName) on \(dateString)"
        }
        else {
            concertString = "\(artistNamesString) on \(dateString)"
        }
        self.concertTitleLabel.text = concertString
        
        // Add the camera jawn
        let cameraImage = UIImage(named: "camera")!.imageWithRenderingMode(.AlwaysTemplate)
        self.chooseButton.setImage(cameraImage, forState: .Normal)
        self.chooseButton.tintColor = UIColor.whiteColor()
        
        // Update the UI
        self.updateUI()
        
        // Show the video piker when the view gets loaded
        self.showVideoPicker()
    }
    
    func updateUI() {
        // Enable/disable the continue button
        self.continueButton.enabled = videosToUpload.count > 0
        
        // If there are no videos, let the user know
        if self.videosToUpload.count == 0 {
            self.displayBackgroundMessage("Choose some videos to get started")
        }
        else {
            self.collectionView.backgroundView = nil
        }
        
        self.collectionView.reloadData()
    }
    
    func displayBackgroundMessage(message: String) {
        let backgroundLabel = MuliLabel()
        backgroundLabel.setup(message,
                              size: 24.0,
                              alignment: .Center,
                              padding: 10.0,
                              color: UIColor.lightGrayColor())
        self.collectionView.backgroundView = backgroundLabel
    }
    
    /***************************************************************************
     Video Collection View
     ***************************************************************************/
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosToUpload.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 110.0, height: 75.0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let videoUrl = self.videosToUpload[indexPath.row]
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("VideoItem", forIndexPath: indexPath) as! VideoItem
        
        item.setup(videoUrl, deleteCallback: { (videoUrl: NSURL) in
            self.removeVideo(videoUrl)
        })
        
        return item
    }
    
    /***************************************************************************
     Choose Video Stuff
     ***************************************************************************/
    // Called by the Choose Videos button
    @IBAction func chooseVideos(sender: UIButton?) {
        self.showVideoPicker()
    }
    
    // Called by the Choose Videos button
    func showVideoPicker() {
        // Instantiate DKImagePickerController and set it to only show videos
        let pickerController = DKImagePickerController()
        pickerController.sourceType = .Both
        pickerController.assetType = .AllVideos
        pickerController.UIDelegate = JamJarVideoCameraDelegate()

        // Cancel button action for DKImagePickerController
        pickerController.didCancel = {
            pickerController.dismissViewControllerAnimated(true, completion: nil)
        }
        pickerController.showsCancelButton = true

        // Action for DKImagePickerController after videos were selected
        pickerController.didSelectAssets = { (assets: [DKAsset]) in

            // Don't let the user move on until they have selected videos
            if(assets.count == 0) {
                SCLAlertView().showError("No Videos Selected!", subTitle: "Please select a video", closeButtonTitle: "Got it")
                return
            }

            showProgressView()
            self.queue = assets.count

            // Store all of the URLs for the selected videos
            for asset in assets {
                asset.fetchAVAsset(nil, completeBlock: { info in
                    let targetVideoURL = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/" + info.AVAsset!.URL.lastPathComponent!

                    PHCachingImageManager().requestAVAssetForVideo(asset.originalAsset!, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                        dispatch_async(dispatch_get_main_queue(), {
                            let asset = asset as? AVURLAsset
                            if let data = NSData(contentsOfURL: asset!.URL) {
                                data.writeToFile(targetVideoURL, atomically: true)
                                // Saved URL is stored for future use
                                self.videosToUpload.append(NSURL(fileURLWithPath: targetVideoURL))
                                self.callback()
                            } else {
                                print("Error: Video could not be processed")
                                showErrorView()
                            }
                        })
                    })
                })
            }
        }
        
        self.presentViewController(pickerController, animated: true) {}
    }
    
    func callback() {
        self.queue -= 1
        // Execute final callback when queue is empty
        if self.queue == 0 {
            showSuccessView()
//            self.performSegueWithIdentifier("uploadVideo", sender: nil)
            self.updateUI()
        }
    }
    
    func removeVideo(videoUrl: NSURL) {
        let index = self.videosToUpload.indexOf(videoUrl)
        if let index = index {
            self.videosToUpload.removeAtIndex(index)
            self.updateUI()
        }
    }
    
    
    /***************************************************************************
     Continue Stuff
     ***************************************************************************/
    @IBAction func continueButtonPressed(sender: UIButton?) {
        if self.videosToUpload.count > 0 {
            self.performSegueWithIdentifier("ToUploadVideos", sender: nil)
        }
        else {
            // ETHAN: Make sure Mark put an error message here before merging
            print("Nawww")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ToUploadVideos") {
            let uploadVideoViewController = segue.destinationViewController as! UploadVideoViewController

            uploadVideoViewController.selectedVenue = self.selectedVenue
            uploadVideoViewController.selectedArtists = self.selectedArtists
            uploadVideoViewController.selectedDate = self.selectedDate
            uploadVideoViewController.videosToUpload = self.videosToUpload

            //Clear video list to avoid conflicts
//            self.videosToUpload = []
        }
    }
}
