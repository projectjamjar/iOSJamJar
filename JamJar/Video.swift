//
//  Video.swift
//  JamJar
//
//  Created by Ethan Riback on 10/29/15.
//  Copyright © 2015 JamJar. All rights reserved.
//

import ObjectMapper

class Video: NSObject, Mappable {
    
    // Video Attributes
    var id: Int?
    var name: String!
    var uploaded: Bool!
    var hls_src: String!
    var concertId: Int? // We may have a concertId
    var concert: Concert? // or we may have a Concert object O.o
    var is_private: Bool!
    var length: Float!
    var thumb_src: [String: String]!
    var user: User!
    var views: Int!
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
        id <- map["id"]
        name <- map["name"]
        uploaded <- map["uploaded"]
        hls_src <- map["hls_src"]
        concertId <- map["concert"]
        concert <- map["concert"]
        is_private <- map["is_private"]
        length <- map["length"]
        thumb_src <- map["thumb_src"]
        user <- map["user"]
        views <- map["views"]
        artists <- map["artists"]
    }
    
    
    func thumbnailForSize(size: Int) -> UIImage? {
        // Given a target size, get the thumbnail for that size (or nil)
        let targetThumbSize = "\(size)"
        if let thumbs = self.thumb_src,
               urlString = thumbs[targetThumbSize],
               url = NSURL(string: urlString),
               data = NSData(contentsOfURL: url),
               image = UIImage(data: data) {
                    return image
        }
        else {
            return nil
        }
    }
    
    func getArtistsString() -> String {
        let artistNames: [String] = self.artists.map({return $0.name})
        let artistsString = artistNames.joinWithSeparator(", ")
        return artistsString
    }
    
}