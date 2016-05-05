//
//  StitchedJamJarAVPlayerViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class StitchedJamJarAVPlayerViewController: JamJarAVPlayerViewController {
    
    // UI Elements
    var rewindButton: UIButton!
    var fastFowardButton: UIButton!
    
    // Video and AVPlayer Storage
    var jamjar: JamJarGraph!
    var currentVideo: Video!
    var videos: [Video]!
    var overlappingVideos: [Video]! = [Video]()
    var storedAVPlayers: [JamJarAVPlayer]! = [JamJarAVPlayer]()
    var testBackUpVideo: AVPlayer = AVPlayer(URL: NSURL(string: "https://s3.amazonaws.com/jamjar-videos/prod/a892649e-e138-476d-b928-d284d275430d/video.m3u8")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add Buttons to Bar
        createRewindButton()
        createFastForwardButton()
        
        // swipe gestures
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(StitchedJamJarAVPlayerViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    // This controller needs to remove JamJar unique elements
    override func removeObservers() {
        super.removeObservers()
        
        //Remove buttons to avoid duplication if the view is reloading
        self.rewindButton.removeFromSuperview()
        self.fastFowardButton.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Memory Warning in Stitched JamJar")
    }
    
    // Functions to add custom UI Elements
    
    // Rewind Button Button
    func createRewindButton() {
        self.rewindButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        rewindButton.frame = CGRectMake(10, 0, 30, 30)
        rewindButton.tintColor = UIColor.whiteColor()
        rewindButton.setImage(self.imageFromSystemBarButton(UIBarButtonSystemItem.Rewind), forState: .Normal)
        //rewindButton.addTarget(self, action: "playButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(rewindButton)
    }
    
    // Fast Forward Button
    func createFastForwardButton() {
        self.fastFowardButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        fastFowardButton.frame = CGRectMake(70, 0, 30, 30)
        fastFowardButton.tintColor = UIColor.whiteColor()
        fastFowardButton.setImage(self.imageFromSystemBarButton(UIBarButtonSystemItem.FastForward), forState: .Normal)
        //fastFowardButton.addTarget(self, action: "playButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(fastFowardButton)
    }
    
    // check for new overlaps
    override func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        super.updateTimeLabel(elapsedTime, duration: duration)
        
        //TODO: find overlaps
        let edges = jamjar.nodes![String(self.currentVideo.id!)]
        for edge in edges! {
            let storedVideoIds = self.overlappingVideos.map { $0.id }
            if !storedVideoIds.contains(edge.video) && edge.offset < elapsedTime {
                print("Video " + String(edge.video) + " Now overlapped!")
                //Todo: make sure this offset and video length is larger than the elapsed time
                let overlapVideo = getVideoByIdFromList(edge.video)
                if(elapsedTime < (Double(overlapVideo.length) + edge.offset)) {
                    self.overlappingVideos.append(overlapVideo)
                    //TODO: restrict AVPlayer adding if there are too many
                    self.storedAVPlayers.append(JamJarAVPlayer(URL: NSURL(fileURLWithPath: overlapVideo.hls_src), videoId: overlapVideo.id!))
                }
            }
        }
    }
    
    // Swipe recognition method
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
                self.removeObservers()
                self.player? = self.testBackUpVideo
                self.viewDidLoad()
                self.player?.play()
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    // Get video from video list based on Id
    private func getVideoByIdFromList(videoId: Int) -> Video {
        let video = self.videos.filter{ $0.id == videoId }.first
        return video!
    }
}