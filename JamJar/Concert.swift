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
    var date: NSDate!
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
        date <- (map["date"], DateTransform())
        venue <- map["venue"]
        videos <- map["videos"]
    }
    
    func getArtists() -> [Artist] {
        var artistIds = [Int]()
        var artists = [Artist]()
        videos.forEach { video in
            video.artists.forEach({ (artist) -> () in
                if !artistIds.contains(artist.id) {
                    artists.append(artist)
                    artistIds.append(artist.id)
                }
            })
        }
        return artists
    }
}