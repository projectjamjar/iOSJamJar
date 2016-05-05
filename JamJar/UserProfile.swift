//
//  UserProfile.swift
//  JamJar
//
//  Created by Mark Koh on 5/4/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class UserProfile: Mappable {
    var user: User!
    var videos: [Video]!
    var concerts: [Concert]!
    
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
        user <- map["user"]
        videos <- map["video"]
        concerts <- map["concert"]
    }
}
