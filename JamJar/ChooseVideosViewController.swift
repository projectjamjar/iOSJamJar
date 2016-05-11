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

class VideoItem: UICollectionViewCell {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var videoUrl: NSURL!
    
    func setup(videoUrl: NSURL) {
        self.videoUrl = videoUrl
        
//        self.thumbnail
        let asset = AVAsset(URL: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTime(seconds: 1, preferredTimescale: 1)
        
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            self.thumbnailView.image = UIImage(CGImage: imageRef)
        } catch {
            print(error)
        }
     }
    
    @IBAction func deleteVideo(sender: UIButton?) {
        print("Delete: \(videoUrl)")
    }
}

class ChooseVideosViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //information about the concert that is sent to this controller
    var selectedArtists = [Artist]()
    var selectedVenue: VenueSearchResult!
    var selectedDate: String!
    
    // Videos that are selected in this controller
    var videosToUpload: [NSURL] = []
    var queue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do stuff here
        
        self.updateUI()
    }
    
    func updateUI() {
        // Enable/disable the continue button
        self.continueButton.enabled = videosToUpload.count > 0
    }
    
    /***************************************************************************
     Video Collection View
     ***************************************************************************/
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videosToUpload.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let videoUrl = self.videosToUpload[indexPath.row]
        let item = collectionView.dequeueReusableCellWithReuseIdentifier("VideoItem", forIndexPath: indexPath) as! VideoItem
        
        item.setup(videoUrl)
        
        return item
    }
    
    /***************************************************************************
     Choose Video Stuff
     ***************************************************************************/
    
    // Called by the Choose Videos button
    @IBAction func chooseVideos(sender: UIButton?) {
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
            self.collectionView.reloadData()
        }
    }
}
