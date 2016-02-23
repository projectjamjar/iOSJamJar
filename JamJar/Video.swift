//
//  Video.swift
//  JamJar
//
//  Created by Ethan Riback on 10/29/15.
//  Copyright © 2015 JamJar. All rights reserved.
//

import ObjectMapper

class Video {
    
    var id : Int?
    var name : String!
    var hls_src: String!
    //private var src : String!;
    
    init?(id: Int, name: String, hls_src: String) {
        self.id = id
        self.name = name
        self.hls_src = hls_src
    }
    
//    /**
//     The constructor required by ObjectMapper
//     */
//    required init?(_ map: Map) {}
//    
//    /**
//     The mapping function for ObjectMapper.  This function relates model
//     properties to fields in a JSON Response.
//     
//     - parameter map: The map of the JSON response
//     */
//    func mapping(map: Map) {
//        id <- map["id"]
//        email <- map["email"]
//        firstName <- map["first_name"]
//        lastName <- map["last_name"]
//        fullName <- map["full_name"]
//        photo <- map["photo"]
//        title <- map["title"]
//    }
    
}