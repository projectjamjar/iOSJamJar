//
//  Venue.swift
//  JamJar
//
//  Created by Ethan Riback on 2/20/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Foundation

class Venue {
    
    var description: String!
    var place_id: String!
    
    init?(place_id: String) {
        self.place_id = place_id
    }
    
    init?(place_id: String, description: String) {
        self.place_id = place_id
        self.description = description
    }
}