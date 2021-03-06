//
//  JamJarAVPlayerViewController.swift
//  JamJar
//
//  Created by Ethan Riback on 4/11/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class JamJarAVPlayerViewController: AVPlayerViewController {
    
    //UI elements
    var bottomBar: UIView! = UIView()
    var playButton: UIButton!
    var fullScreenButton: UIButton!
    var timeObserver: AnyObject!
    var timePassedLabel: UILabel = UILabel()
    var seekSlider: UISlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    var loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    let playbackLikelyToKeepUpContext: UnsafeMutablePointer<(Void)> = nil
    
    // UIElements work off of this size constant
    var uiElementSize: CGFloat = 40
    
    var showFullScreenButton = true
    var autoPlay = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Disable the default Video Controls
        self.showsPlaybackControls = false
        
        // Add Buttons to Bar
        createPlayButton()
        if showFullScreenButton {
            createFullScreenButton()
        }
        createTimeObserver()
        createSeekSlider()
        createBufferIndicator()
        
        // Create bottom bar
        let bottomBarColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        self.bottomBar.backgroundColor = bottomBarColor
        self.view.addSubview(self.bottomBar)
        
        // start video
        loadingIndicatorView.startAnimating()
        
        if autoPlay {
            self.playPause() // Start the playback
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update Bottom Bar
        self.bottomBar.frame = CGRect(x: 0, y: self.view.frame.height - uiElementSize, width: self.view.frame.width, height: uiElementSize)
        if showFullScreenButton {
            self.updateFullScreenButton()
        }
        self.updateSeekSlider()
        self.updateBufferIndicator()
    }
    
    // This controller needs to have observers removed from memory or else the player will never deinit
    func removeObservers() {
        //Remove the observers
        self.player!.removeTimeObserver(self.timeObserver)
        timeObserver = nil
        self.player!.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", context: playbackLikelyToKeepUpContext)
        
        //Remove buttons to avoid duplication if the view is reloading
        self.playButton.removeFromSuperview()
        self.seekSlider.removeFromSuperview()
        if showFullScreenButton {
            self.fullScreenButton.removeFromSuperview()
        }
        self.bottomBar.removeFromSuperview()
    }
    
    //Pause the video if the video is out of scope
    override func viewDidDisappear(animated: Bool) {
        playButton.setImage(UIImage(named: "right-arrow"), forState: .Normal)
        self.player!.pause()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method that deals with switching between pause and play
    func playPause() {
        let playerIsPlaying = self.player?.rate > 0
        if playerIsPlaying {
            playButton.setImage(UIImage(named: "right-arrow"), forState: .Normal)
            self.player?.pause()
        } else {
            playButton.setImage(UIImage(named: "ic_pause"), forState: .Normal)
            self.player?.play()
        }
    }
    
    // Methods to handle time remaining
    internal func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timePassed: Float64 = elapsedTime
        let totalTime: Float64 = CMTimeGetSeconds(self.player!.currentItem!.duration)
        
        timePassedLabel.text = String(format: "%02d:%02d/%02d:%02d",
                                      ((lround(timePassed) / 60) % 60),
                                      lround(timePassed) % 60,
                                      ((lround(totalTime) / 60) % 60),
                                      lround(totalTime) % 60)
        
        //Update Slider
        let sliderPosition = elapsedTime / CMTimeGetSeconds(self.player!.currentItem!.duration)
        self.seekSlider.value = Float(sliderPosition)
    }
    
    // Method is called when observer cycles periodically
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(self.player!.currentItem!.duration);
        if (isfinite(duration)) {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime, duration: duration)
        }
    }
    
    // Functions to add custom UI Elements
    
    // Play Button
    func createPlayButton() {
        self.playButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        playButton.frame = CGRectMake(20 + uiElementSize, 0, uiElementSize, uiElementSize)
        playButton.tintColor = UIColor(red: 241, green: 95, blue: 78)
        playButton.setImage(UIImage(named: "right-arrow"), forState: .Normal)
        playButton.addTarget(self, action: #selector(JamJarAVPlayerViewController.playButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(playButton)
    }
    
    // Full Screen Button
    func createFullScreenButton() {
        self.fullScreenButton = UIButton(type: UIButtonType.RoundedRect) as UIButton
        fullScreenButton.frame = CGRectMake(self.view.frame.width - (10 + uiElementSize), 0, uiElementSize, uiElementSize)
        fullScreenButton.tintColor = UIColor.whiteColor()
        fullScreenButton.setImage(UIImage(named: "full_screen"), forState: .Normal)
        fullScreenButton.addTarget(self, action: #selector(JamJarAVPlayerViewController.fullScreenPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(fullScreenButton)
    }
    
    // When the view is updated, change fullscreen button's position
    func updateFullScreenButton() {
        fullScreenButton.frame = CGRectMake(self.view.frame.width - (10 + uiElementSize), 0, uiElementSize, uiElementSize)
    }
    
    // TimeRemaining Label
    func createTimeObserver() {
        timePassedLabel.text = "0:00/0:00" //Serves as a default value incase nothing is returned
        timePassedLabel.font = UIFont(name: "Muli", size: 17)
        // Make a better time interval
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.25, 100)
        timeObserver = self.player?.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue()) {
            (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime)
        }
        timePassedLabel.textColor = UIColor.whiteColor()
        self.bottomBar.addSubview(timePassedLabel);
        
        //layout time remaining label
        timePassedLabel.frame = CGRect(x: 10 + ((10 + uiElementSize) * 3), y: 0, width: 200, height: uiElementSize)
    }
    
    // Seek Slider
    func createSeekSlider() {
        seekSlider.tintColor = UIColor(red: 241, green: 95, blue: 78)
        self.view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: #selector(JamJarAVPlayerViewController.sliderBeganTracking(_:)),
                             forControlEvents: UIControlEvents.TouchDown)
        seekSlider.addTarget(self, action: #selector(JamJarAVPlayerViewController.sliderEndedTracking(_:)),
                             forControlEvents: UIControlEvents.TouchUpInside)
        seekSlider.addTarget(self, action: #selector(JamJarAVPlayerViewController.sliderEndedTracking(_:)),
                             forControlEvents: UIControlEvents.TouchUpOutside)
        seekSlider.addTarget(self, action: #selector(JamJarAVPlayerViewController.sliderValueChanged(_:)),
                             forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // When the view is updated, change slider position
    func updateSeekSlider() {
        self.seekSlider.frame = CGRect(x: 10, y: self.bottomBar.frame.origin.y - uiElementSize, width: self.bottomBar.bounds.size.width - 20, height: 30)
    }
    
    // Show a loader image when video is buffering
    func createBufferIndicator() {
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        self.player!.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                             options: NSKeyValueObservingOptions.New, context: playbackLikelyToKeepUpContext)
    }
    
    func updateBufferIndicator() {
        loadingIndicatorView.center = CGPoint(x: CGRectGetMidX(view.bounds), y: CGRectGetMidY(view.bounds))
    }
    
    // Button Actions
    
    // Play/Pause functionality
    func playButtonAction(sender:UIButton!)
    {
        playPause()
    }
    
    // Begin seeking
    func sliderBeganTracking(slider: UISlider!) {
        playerRateBeforeSeek = self.player!.rate
        print(playerRateBeforeSeek)
        self.player!.pause()
    }
    
    // End seeking
    func sliderEndedTracking(slider: UISlider!) {
        let videoDuration = CMTimeGetSeconds(self.player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        print(seekSlider.value) //prints a float that is between 0 and 1
        updateTimeLabel(elapsedTime, duration: videoDuration)
        
        self.player!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.player!.play()
            }
        }
    }
    
    // Seek Value Changed
    func sliderValueChanged(slider: UISlider!) {
        let videoDuration = CMTimeGetSeconds(self.player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime, duration: videoDuration)
    }
    
    // Full Screen pressed
    func fullScreenPressed(sender:UIButton!) {
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            let value = UIInterfaceOrientation.LandscapeLeft.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
            break
        default:
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }
    
    // Buffer stuff
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == playbackLikelyToKeepUpContext) {
            if (self.player!.currentItem!.playbackLikelyToKeepUp) {
                loadingIndicatorView.stopAnimating()
            } else {
                loadingIndicatorView.startAnimating()
            }
        }
    }
    
    func fadeUIElements(value: CGFloat, completion: () -> Void) {
        UIView.animateWithDuration(0.5) {
            self.bottomBar.alpha = value;
            self.seekSlider.alpha = value;
        }
        completion()
    }
    
    // executed code for when the AVPlayer is touched
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        var alphaSetting: CGFloat
        
        if(self.bottomBar.hidden && self.seekSlider.hidden) {
            alphaSetting = 1.0
        } else {
            alphaSetting = 0.0
        }
        
        self.fadeUIElements(alphaSetting) {
            self.bottomBar.hidden = !self.bottomBar.hidden
            self.seekSlider.hidden = !self.seekSlider.hidden
        }
    }
}