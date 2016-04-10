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
    var artists: [Artist]?
    var thumbs: [[String: String]]?
    var videos: [Video]?
    var jamjars: [JamJarGraph]?
    
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
        date <- (map["date"], ObjectMapper.CustomDateFormatTransform(formatString: "yyyy-MM-dd"))
        venue <- map["venue"]
        artists <- map["artists"]
        thumbs <- map["thumbs"]
        videos <- map["videos"]
        jamjars <- map["graph"]
    }
    
    func getArtistsString() -> String {
        if let artistNames: [String] = self.artists!.map({return $0.name}) {
            let artistsString = artistNames.joinWithSeparator(", ")
            return artistsString
        }
        return "No Artists"
    }
    
    func thumbnailForSize(size: Int) -> UIImage? {
        // Given a target size, get the thumbnail for that size (or nil)
        let targetThumbSize = "\(size)"
        if let thumb_list = self.thumbs!.first,
            urlString = thumb_list[targetThumbSize],
            url = NSURL(string: urlString),
            data = NSData(contentsOfURL: url),
            image = UIImage(data: data) {
            return image
        }
        else {
            return nil
        }
    }
}