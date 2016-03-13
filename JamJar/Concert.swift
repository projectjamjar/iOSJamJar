//
//  Concert.swift
//  JamJar
//
//  Created by Ethan Riback on 3/9/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class Concert: NSObject, Mappable {

    // Concert Attributes
    var id: Int!
    var date: String!
    var venue: Venue!
    var videos: [Video]!
    
    /**
    The constructor required by ObjectMapper
    */
    required init?(_ map: Map) {}
    
    /**
     The mapping function for ObjectMapper.  This function relates model
     properties to fields in a JSON Response.
     
     - parameter map: The map of the JSON response
     */
    func mapping(map: Map) {
        id <- map["id"]
        date <- map["date"]
        venue <- map["venue"]
        videos <- map["videos"]
    }
}