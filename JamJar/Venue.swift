//
//  Venue.swift
//  JamJar
//
//  Created by Ethan Riback on 2/20/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class Venue: Mappable {
    
    // Venue Attributes
    // Note: Based off of Google Maps
    var description: String!
    var place_id: String!
    
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
        description <- map["description"]
        place_id <- map["place_id"]
    }
}