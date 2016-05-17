//
//  UserBlock.swift
//  JamJar
//
//  Created by Mark Koh on 5/16/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class UserBlock: Mappable {
    var userId: Int!
    var blockedUser: User!
    
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
        userId <- map["user"]
        blockedUser <- map["blocked_user"]
    }
}

