//
//  SuggestedEvent.swift
//  JamJar
//
//  Created by Mark Koh on 5/15/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class SponsoredEvent: Mappable {
    var name: String!
    var concert: Concert!
    var artists: [Artist]!
    
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
        name <- map["name"]
        concert <- map["concert"]
        artists <- map["artists"]
    }
}

