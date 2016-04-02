//
//  JamJarGraph.swift
//  JamJar
//
//  Created by Ethan Riback on 4/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class JamJarGraph: NSObject, Mappable {
    
    // JamJarGraph Attributes
    var nodes: [String : [JamJarEdge]]?
    var count: Int!
    var start_id: Int!
    
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
        nodes <- map["adjacencies"]
        count <- map["count"]
        start_id <- map["start_id"]
    }
    
}