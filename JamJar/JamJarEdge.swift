//
//  JamJarEdge.swift
//  JamJar
//
//  Created by Ethan Riback on 4/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class JamJarEdge: NSObject, Mappable {

    // JamJarEdge Attributes
    var confidence: Int!
    var offset: Double!
    var video: Int!
    
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
        confidence <- map["confidence"]
        offset <- map["offset"]
        video <- map["video"]
    }
    
}