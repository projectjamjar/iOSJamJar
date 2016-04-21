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
    
    var bottomBar: UIView! = UIView()
    var playButton: UIButton!
    var rewindButton: UIButton!
    var fastFowardButton: UIButton!
    var timeObserver: AnyObject!
    var timeRemainingLabel: UILabel = UILabel()
    var seekSlider: UISlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    var loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    let playbackLikelyToKeepUpContext = UnsafeMutablePointer<(Void)>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Disable the default Video Controls
        self.showsPlaybackControls = false
        
        // Add Buttons to Bar
        createRewindButton()
        createPlayButton()
        createFastForwardButton()
        createTimeObserver()
        createSeekSlider()
        createBufferIndicator()
        
        let bottomBarColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        self.bottomBar.backgroundColor = bottomBarColor
        self.view.addSubview(self.bottomBar)
        
        //start video
        loadingIndicatorView.startAnimating()
        self.player!.play() // Start the playback
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update Bottom Bar
        self.bottomBar.frame = CGRect(x: 0, y: self.view.frame.height - 30, width: self.view.frame.width, height: 30)
        self.updateSeekSlider()
        self.updateBufferIndicator()
    }
    
    deinit {
        self.player?.removeTimeObserver(timeObserver)
        self.player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
    }
    
    /*
    override func viewDidDisappear(animated: Bool) {
        self.player?.removeTimeObserver(self.timeObserver)
        self.player = nil
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method that deals with switching between pause and play
    func playPause() {
        let playerIsPlaying = self.player?.rate > 0
        if playerIsPlaying {
            playButton.setImage(self.imageFromSystemBarButton(UIBarButtonSystemItem.Pause), forState: .Normal)
            self.player?.pause()
        } else {
            playButton.setImage(self.imageFromSystemBarButton(UIBarButtonSystemItem.Play), forState: .Normal)
            self.player?.play()
        }
    }
    
    // Methods to handle time remaining
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(self.player!.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        
        //Update Slider
        let sliderPosition = elapsedTime / CMTimeGetSeconds(self.player!.currentItem!.duration)
        self.seekSlider.value = Float(sliderPosition)
    }
    
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
        playButton.frame = CGRectMake(40, 0, 30, 30)
        playButton.tintColor = UIColor(red: 241, green: 95, blue: 78)
        playButton.setImage(self.imageFromSystemBarButton(UIBarButtonSystemItem.Play), forState: .Normal)
        playButton.addTarget(self, action: "playButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(playButton)
    }
    
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
    
    
    // TimeRemaining Label
    func createTimeObserver() {
        timeRemainingLabel.text = "0:00" //Serves as a default value incase nothing is returned
        timeRemainingLabel.font = UIFont(name: "Muli", size: 14)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = self.player?.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue()) {
            (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime)
        }
        
        timeRemainingLabel.textColor = UIColor.whiteColor()
        self.bottomBar.addSubview(timeRemainingLabel);
        
        //layout time remaining label
        timeRemainingLabel.frame = CGRect(x: 100, y: 0, width: 60, height: 30)
    }
    
    // Seek Slider
    func createSeekSlider() {
        seekSlider.tintColor = UIColor(red: 241, green: 95, blue: 78)
        self.view.addSubview(seekSlider)
        seekSlider.addTarget(self, action: "sliderBeganTracking:",
                             forControlEvents: UIControlEvents.TouchDown)
        seekSlider.addTarget(self, action: "sliderEndedTracking:",
                             forControlEvents: UIControlEvents.TouchUpInside)
        seekSlider.addTarget(self, action: "sliderEndedTracking:",
                             forControlEvents: UIControlEvents.TouchUpOutside)
        seekSlider.addTarget(self, action: "sliderValueChanged:",
                             forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func updateSeekSlider() {
        self.seekSlider.frame = CGRect(x: 10, y: self.bottomBar.frame.origin.y - 30, width: self.bottomBar.bounds.size.width - 20, height: 30)
    }
    
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
        print("sliderBeganTracking")
        playerRateBeforeSeek = self.player!.rate
        print(playerRateBeforeSeek)
        self.player!.pause()
    }
    
    // End seeking
    func sliderEndedTracking(slider: UISlider!) {
        print("sliderEndedTracking")
        let videoDuration = CMTimeGetSeconds(self.player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        print(seekSlider.value) //prints a float that is between 0 and 1
        updateTimeLabel(elapsedTime, duration: videoDuration)
        
        self.player!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
            if (self.playerRateBeforeSeek > 0) {
                self.player!.play()
            }
        }
    }
    
    // Seek Value Changed
    func sliderValueChanged(slider: UISlider!) {
        print("sliderValueChanged")
        let videoDuration = CMTimeGetSeconds(self.player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime, duration: videoDuration)
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
    
    // private haxing of the built in icons that should need to be done but is done cause Apple wants to make my life harder
    //Get image from built in icons
    private func imageFromSystemBarButton(systemItem: UIBarButtonSystemItem)-> UIImage {
        let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        
        // add to toolbar and render it
        UIToolbar().setItems([tempItem], animated: false)
        
        // got image from real uibutton
        let itemView = tempItem.valueForKey("view") as! UIView
        for view in itemView.subviews {
            if view.isKindOfClass(UIButton){
                let button = view as! UIButton
                return button.imageView!.image!
            }
        }
        
        return UIImage()
    }
}