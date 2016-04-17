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
    var timeObserver: AnyObject!
    var timeRemainingLabel: UILabel = UILabel()
    var seekSlider: UISlider = UISlider()
    var playerRateBeforeSeek: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Disable the default Video Controls
        self.showsPlaybackControls = false
        
        // Add Buttons to Bar
        createPlayButton()
        createTimeObserver()
        createSeekSlider()
        
        let bottomBarColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        self.bottomBar.backgroundColor = bottomBarColor
        self.view.addSubview(self.bottomBar)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update Bottom Bar
        self.bottomBar.frame = CGRect(x: 0, y: self.view.frame.height - 30, width: self.view.frame.width, height: 30)
        self.updateSeekSlider()
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.player?.removeTimeObserver(self.timeObserver)
        self.player = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method that deals with switching between pause and play
    func playPause() {
        let playerIsPlaying = self.player?.rate > 0
        if playerIsPlaying {
            self.player?.pause()
        } else {
            self.player?.play()
        }
    }
    
    // Methods to handle time remaining
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(self.player!.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
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
        self.playButton = UIButton(type: UIButtonType.System) as UIButton
        playButton.frame = CGRectMake(0, 0, 30, 30)
        playButton.backgroundColor = UIColor.greenColor()
        playButton.setTitle(">", forState: UIControlState.Normal)
        playButton.addTarget(self, action: "playButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.bottomBar.addSubview(playButton)
    }
    
    // TimeRemaining Label
    func createTimeObserver() {
        timeRemainingLabel.text = "0:00" //Serves as a default value incase nothing is returned
        let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = self.player?.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue()) {
            (elapsedTime: CMTime) -> Void in
            self.observeTime(elapsedTime)
        }
        
        timeRemainingLabel.textColor = UIColor.whiteColor()
        self.bottomBar.addSubview(timeRemainingLabel);
        
        //layout time remaining label
        timeRemainingLabel.frame = CGRect(x: 40, y: 0, width: 60, height: 30)
    }
    
    // Seek Slider
    func createSeekSlider() {
        self.seekSlider.value = 0
        self.bottomBar.addSubview(seekSlider)
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
        self.seekSlider.frame = CGRect(x: self.timeRemainingLabel.frame.origin.x + self.timeRemainingLabel.bounds.size.width,
                                  y: 0, width: self.bottomBar.bounds.size.width - self.timeRemainingLabel.bounds.size.width - self.playButton.bounds.size.width - 5, height: 30)
    }
    
    // Button Actions
    
    // Play/Pause functionality
    func playButtonAction(sender:UIButton!)
    {
        print("play pause")
        playPause()
    }
    
    // Begin seeking
    func sliderBeganTracking(slider: UISlider!) {
        playerRateBeforeSeek = self.player!.rate
        self.player!.pause()
    }
    
    // End seeking
    func sliderEndedTracking(slider: UISlider!) {
        let videoDuration = CMTimeGetSeconds(self.player!.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime, duration: videoDuration)
        
        self.player!.seekToTime(CMTimeMakeWithSeconds(elapsedTime, 10)) { (completed: Bool) -> Void in
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
}