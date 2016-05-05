//
//  SearchResult.swift
//  JamJar
//
//  Created by Mark Koh on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

enum SearchResultType {
    case Video, Venue, Artist, Concert, User
}

class SearchResult: Mappable {
    var videos: [Video]!
    var venues: [Venue]!
    var artists: [Artist]!
    var concerts: [Concert]!
    var users: [User]!
    
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
        videos <- map["video"]
        venues <- map["venue"]
        artists <- map["artist"]
        concerts <- map["concert"]
        users <- map["user"]
    }
}
