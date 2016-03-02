//
//  Artist.swift
//  JamJar
//
//  Created by Ethan Riback on 2/18/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class Artist: Mappable {
    
    // Artist Attributes
    // Note: This model is based off of spotify_model, not JamJars
    // TODO: Add in missing attributes (like images)
    var id: String!
    var name: String!
    var genres: [String]!
    
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
        name <- map["name"]
        genres <- map["genres"]
    }
}