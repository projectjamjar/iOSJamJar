//
//  Artist.swift
//  JamJar
//
//  Created by Ethan Riback on 2/18/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Foundation

class Artist {
    
    var name: String!
    var id: String!
    
    init?(id: String) {
        self.id = id
    }
    
    init?(id: String, name: String) {
        self.id = id
        self.name = name
    }
}