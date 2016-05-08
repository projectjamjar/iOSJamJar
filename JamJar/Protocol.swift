//
//  Protocol.swift
//  JamJar
//
//  Created by Ethan Riback on 5/8/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

protocol updateVideoDelegate: class {
    func updateVideo(video: Video)
    
    func recordView(videoId: Int!)
}