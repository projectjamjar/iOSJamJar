//
//  Artist.swift
//  JamJar
//
//  Created by Ethan Riback on 2/18/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class Artist: NSObject, Mappable {
    
    // Artist Attributes
    // Note: This model is based off of spotify_model, not JamJars
    // TODO: Add in missing attributes (like images)
    var id: Int!
    var spotifyResponseId: String?
    var name: String!
    var spotifyId: String?
    var popularity: Int!
    var genres: [String]?
    var images: [ArtistImage]?
    
    var downloadedPhoto: UIImage? = nil
    
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
        spotifyResponseId <- map["id"]
        name <- map["name"]
        spotifyId <- map["spotify_id"] // Mark found this issue
        popularity <- map["popularity"]
        genres <- map["genres"]
        images <- map["images"]
    }
    
    func getImage() -> UIImage? {
        if var images = self.images where self.images!.count > 0 {
            if let downloadedPhoto = self.downloadedPhoto {
                return downloadedPhoto
            }
            // Run through the images and get the smallest (for now)
            images.sortInPlace({ (image1, image2) -> Bool in
                return (image1.width < image2.width ? true : false)
            })
            if let smallest = images.first {
                if let data = NSData(contentsOfURL: smallest.url) {
                    let image = UIImage(data: data)
                    self.downloadedPhoto = image
                    return image
                }
            }
            
        }
        // If we weren't able to get an actual image, fall back to this
        return nil
    }
    
    func getImageChipForFrame(frame: CGRect) -> UIView? {
        
        let view = UIView(frame: frame)
        
        if let image = self.getImage() {
            // We have a photo, set the imageview to that
            let imageView = UIImageView(frame: CGRectMake(0,0,frame.width,frame.height))
            imageView.image = image
            imageView.contentMode = .ScaleAspectFill
            view.addSubview(imageView)
        }
        else {
            // We don't have an image.  Make a grey namecard.
            let label = UILabel(frame: CGRectMake(0,0,frame.width,frame.height))
            
            label.adjustsFontSizeToFitWidth = true
            
            let splitName = name.characters.split(isSeparator: { $0 == " " })
            let initials = splitName.flatMap({ (word) -> Character? in
                return word.first
            })
            label.text = String(initials)
            
            label.textColor = UIColor.whiteColor()
            label.backgroundColor = UIColor(white: 1, alpha: 0.5)
            label.textAlignment = .Center
            
            view.addSubview(label)
        }
        
        view.cropToCircle()
        
        return view
    }
}

class ArtistImage: NSObject, Mappable {
    // Artist Image Attributes
    var url: NSURL!
    var height: Int!
    var width: Int!
    
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
        url <- (map["url"], URLTransform())
        height <- map["height"]
        width <- map["width"]
    }
}

class Genre: NSObject, Mappable {
    // Artist Image Attributes
    var id: Int!
    var name: String!
    
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
    }
}