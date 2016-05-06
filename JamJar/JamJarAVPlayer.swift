//
//  JamJarAVPlayer.swift
//  JamJar
//
//  Created by Ethan Riback on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import AVKit
import AVFoundation

class JamJarAVPlayer: AVPlayer {
    var videoId: Int?
    
    init(URL: NSURL,videoId: Int) {
        super.init(URL: URL)
        self.videoId = videoId
    }
    
    override init() {
        print("Default init called?")
        super.init()
    }
    
    override init(URL: NSURL) {
        super.init(URL: URL)
    }
    
    override init(playerItem item: AVPlayerItem) {
        print("PlayerItem init called?")
        super.init(playerItem: item)
    }
    
    deinit {
        print("Deallocating JamJarAVPlayer")
    }
}