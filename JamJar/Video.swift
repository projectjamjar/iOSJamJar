//
//  Video.swift
//  JamJar
//
//  Created by Ethan Riback on 10/29/15.
//  Copyright © 2015 JamJar. All rights reserved.
//

import Foundation

class Video {
    
    var id : Int!;
    var name : String!;
    var hls_src: String!;
    //private var src : String!;
    
    init?(id: Int, name: String, hls_src: String) {
        self.id = id
        self.name = name
        self.hls_src = hls_src
    }
    
}