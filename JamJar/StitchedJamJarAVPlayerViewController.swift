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
    
    // Delegate for JamJarPageViewController
    // Declare as weak to avoid memory cycles
    weak var jamjarDelegate: updateVideoDelegate?
    
    // UI Elements
    var rewindButton: UIButton!
    var fastFowardButton: UIButton!
    var videoStackView: UIStackView!
    var videoScrollView: UIScrollView!
    
    // Video and AVPlayer Storage
    var jamjar: JamJarGraph!
    var currentVideo: Video!
    var videos: [Video]!
    var overlappingVideos: [Video]! = [Video]()
    var storedAVPlayers: [JamJarAVPlayer]! = [JamJarAVPlayer]()
    let avPlayerListMax = 5
    
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
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(StitchedJamJarAVPlayerViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        // add observer for when current video ends
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StitchedJamJarAVPlayerViewController.playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
    }
    
    // This controller needs to remove JamJar unique elements
    override func removeObservers() {
        super.removeObservers()
        
        //Remove buttons to avoid duplication if the view is reloading
        self.rewindButton.removeFromSuperview()
        self.fastFowardButton.removeFromSuperview()
        
        // Remove observer for checking if video ended
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Functions to add custom UI Elements
    
    // Rewind Button Button
    func createRewindButton() {
        self.rewindButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        rewindButton.frame = CGRectMake(10, 0, uiElementSize, uiElementSize)
        rewindButton.tintColor = UIColor.whiteColor()
        rewindButton.setImage(UIImage(named: "ic_fast_rewind"), forState: .Normal)
        rewindButton.addTarget(self, action: #selector(StitchedJamJarAVPlayerViewController.rewindButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(rewindButton)
    }
    
    // Fast Forward Button
    func createFastForwardButton() {
        self.fastFowardButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        fastFowardButton.frame = CGRectMake(10 + ((10 + uiElementSize) * 2), 0, uiElementSize, uiElementSize)
        fastFowardButton.tintColor = UIColor.whiteColor()
        fastFowardButton.setImage(UIImage(named: "ic_fast_forward"), forState: .Normal)
        fastFowardButton.addTarget(self, action: #selector(StitchedJamJarAVPlayerViewController.fastForwardButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(fastFowardButton)
    }
    
    // Stack view for overlapping videos
    func createVideoStackViewAndScrollView() {
        print("Lets display the overlapping videos")
        self.videoStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: uiElementSize))
        
        //have update function that updates size of scroll and size of contents in scroll
    }
    
    func rewindButtonAction(sender:UIButton!)
    {
        if !self.overlappingVideos.isEmpty {
            let newVideoId = self.storedAVPlayers.last?.videoId
            changeCurrentVideo(newVideoId!)
        }
    }
    
    func fastForwardButtonAction(sender:UIButton!)
    {
        if !self.overlappingVideos.isEmpty {
            let newVideoId = self.storedAVPlayers.first?.videoId
            changeCurrentVideo(newVideoId!)
        }
    }
    
    // check for new overlaps
    override func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        super.updateTimeLabel(elapsedTime, duration: duration)
        
        // Find overlaps
        let edges = jamjar.nodes![String(self.currentVideo.id!)]
        let storedVideoIds = self.overlappingVideos.map { $0.id }
        for edge in edges! {
            let overlapVideo = getVideoByIdFromList(edge.video)
            if !storedVideoIds.contains(edge.video) && edge.offset < elapsedTime {
                // Make sure this offset and video length is larger than the elapsed time
                if(elapsedTime < (Double(overlapVideo.length) + edge.offset)) {
                    self.overlappingVideos.append(overlapVideo)
                    self.addVideoToStackView(overlapVideo.thumbnailForSize(256))
                    // restrict AVPlayer adding if there are too many
                    if(self.storedAVPlayers.count < avPlayerListMax) {
                        self.storedAVPlayers.append(JamJarAVPlayer(URL: NSURL(string: overlapVideo.hls_src)!, videoId: overlapVideo.id!))
                    }
                    
                    // Record view to video
                    self.jamjarDelegate?.updateViewCount(overlapVideo.id!)
                }
            } else if storedVideoIds.contains(edge.video) && (Double(overlapVideo.length) + edge.offset) < elapsedTime {
                // Remove video from appropriate lists
                let removedVideo = self.overlappingVideos.filter() { $0.id! == overlapVideo.id! }.first
                let removedVideoIndex = self.getOverlappingVideoIndexById((removedVideo?.id)!)
                //remove both video and the element in stack
                self.overlappingVideos.removeAtIndex(removedVideoIndex)
                self.removeVideoFromStackView(removedVideoIndex)
                self.storedAVPlayers = self.storedAVPlayers.filter() { $0.videoId! != overlapVideo.id! }
                // If we removed a video and a player, and the video list is larger than the avplayer list, add next video to the AVPlayer list
                if(self.overlappingVideos.count > self.storedAVPlayers.count) {
                    // New video to be added
                    let newVideoToPlayer = self.overlappingVideos[self.storedAVPlayers.count]
                    self.storedAVPlayers.append(JamJarAVPlayer(URL: NSURL(string: newVideoToPlayer.hls_src)!, videoId: newVideoToPlayer.id!))
                }
            }
        }
    }
    
    // Switch current AVPlayer
    func changeCurrentVideo(newVideoId: Int) {
        let isPlaying = self.player?.rate == 1.0
        self.player?.pause()
        self.removeObservers()
        
        let timePassed = CMTimeGetSeconds(self.player!.currentItem!.currentTime())
        let edge = getEdgeFromJamJar(newVideoId)
        let newTime = Double(timePassed) - edge.offset
        
        // Switch videos
        let tempVideoIndex = getOverlappingVideoIndexById(newVideoId)
        self.overlappingVideos.insert(self.currentVideo, atIndex: 0)
        self.pushVideoToStackView(self.currentVideo.thumbnailForSize(256))
        self.currentVideo = self.overlappingVideos.removeAtIndex(tempVideoIndex + 1)
        self.removeVideoFromStackView(tempVideoIndex + 1)
        
        // Switch AVPlayers
        let tempPlayerIndex = getPlayerIndexById(newVideoId)
        self.storedAVPlayers.append(self.player as! JamJarAVPlayer)
        self.player = self.storedAVPlayers.removeAtIndex(tempPlayerIndex)
        
        // Now that information has been updated, reload the view and set proper time
        self.jamjarDelegate?.updateVideo(self.currentVideo)
        self.viewDidLoad()
        self.player!.seekToTime(CMTimeMakeWithSeconds(newTime, 10)) { (completed: Bool) -> Void in
            // Make the player maintain the play/pause status
            if isPlaying {
                self.player!.play()
            } else {
                self.player!.pause()
            }
        }
    }
    
    // Swipe recognition method
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                // find videoId of first AVPlayer
                if !self.overlappingVideos.isEmpty {
                    let newVideoId = self.storedAVPlayers.first?.videoId
                    changeCurrentVideo(newVideoId!)
                }
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                // find videoId of first AVPlayer
                if !self.overlappingVideos.isEmpty {
                    let newVideoId = self.storedAVPlayers.last?.videoId
                    changeCurrentVideo(newVideoId!)
                }
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    // Handling when a video ends
    func playerDidFinishPlaying(note: NSNotification) {
        //move to default next video
        if !self.overlappingVideos.isEmpty {
            let newVideoId = self.storedAVPlayers.first?.videoId
            changeCurrentVideo(newVideoId!)
        }
    }
    
    /*
     * Video Stack View Functions
     */
    private func createImageView(image: UIImage?) -> UIImageView {
        print("createImageView began")
        let newVideoImageView = UIImageView()
        
        //Set Size
        newVideoImageView.frame.size.height = uiElementSize
        newVideoImageView.frame.size.width = uiElementSize * (110.0/75.0)
        
        if let thumbImage = image {
            newVideoImageView.image = thumbImage
            newVideoImageView.layer.borderColor = UIColor.jjCoralColor().CGColor
        }
        else {
            newVideoImageView.image = UIImage(named: "logo-transparent")
            newVideoImageView.contentMode = .ScaleAspectFit
            newVideoImageView.backgroundColor = UIColor.jjCoralColor()
            newVideoImageView.layer.borderColor = UIColor.whiteColor().CGColor
            
        }
        
        print("createImageView ended")
        return newVideoImageView
    }
    
    private func addVideoToStackView(image: UIImage?) {
        print("addVideoToStackView began")
        self.videoStackView.addArrangedSubview(self.createImageView(image))
        print("addVideoToStackView ended")
    }
    
    private func pushVideoToStackView(image: UIImage?) {
        print("pushVideoToStackView began")
        self.videoStackView.insertArrangedSubview(self.createImageView(image), atIndex: 0)
        print("pushVideoToStackView ended")
    }
    
    private func removeVideoFromStackView(index: Int!) {
        print("removeVideoFromStackView began")
        let removedVideo = self.videoStackView.arrangedSubviews[index]
        self.videoStackView.removeArrangedSubview(removedVideo)
        print("removeVideoFromStackView ended")
    }
    
    /*
     * The Methods below are used to pull information from arrays that store
     * information about videos and AVPlayers. I tried getting this to work
     * for the Array extension but could not and I wanted to focus on getting
     * JamJars to work. @mark: let's make sure we revisit this.
     */
    
    // Get index of overlapping video based on Id
    private func getOverlappingVideoIndexById(videoId: Int) -> Int {
        for (index,video) in self.overlappingVideos.enumerate() {
            if video.id == videoId {
                return index
            }
        }
        print("Error: getOverlappingVideoIndexById")
        return -1
    }
    
    // Get video from video list based on Id
    private func getVideoByIdFromList(videoId: Int) -> Video {
        let video = self.videos.filter{ $0.id == videoId }.first
        return video!
    }
    
    // Get index of player based on Id
    private func getPlayerIndexById(videoId: Int) -> Int {
        for (index,player) in storedAVPlayers.enumerate() {
            if player.videoId == videoId {
                return index
            }
        }
        print("Error: getPlayerIndexById")
        return -1
    }
    
    // Get player from player list based on Id
    private func getPlayerByIdFromList(videoId: Int) -> JamJarAVPlayer {
        let player = self.storedAVPlayers.filter{ $0.videoId == videoId }.first
        return player!
    }
    
    // Get edge from jamjar based on current video id and input id
    private func getEdgeFromJamJar(videoId: Int) -> JamJarEdge {
        let edges = jamjar.nodes![String(self.currentVideo.id!)]
        let edge = edges!.filter{ $0.video == videoId }.first
        return edge!
    }
}