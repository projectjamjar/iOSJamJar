//
//  Venue.swift
//  JamJar
//
//  Created by Ethan Riback on 2/20/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import ObjectMapper

class Venue: NSObject, Mappable {
    
    // Venue Attributes
    // Note: Based off of Google Maps
    var id: Int?
    var place_id: String!
    var name: String!
    var formattedAddress: String!
    var lat: Double!
    var lng: Double!
    var phoneNumber: String?
    var utcOffset: Int?
    var website: String?
    var city: String?
    var state: String?
    var stateShort: String?
    var country: String?
    var countryShort: String?
    
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
        place_id <- map["place_id"]
        name <- map["name"]
        formattedAddress <- map["formatted_address"]
        lat <- (map["lat"], StringDoubleTransform())
        lng <- (map["lng"], StringDoubleTransform())
        phoneNumber <- map["phone_number"]
        utcOffset <- map["utc_offset"]
        website <- map["website"]
        city <- map["city"]
        state <- map["state"]
        stateShort <- map["state_short"]
        country <- map["country"]
        countryShort <- map["country_short"]
    }
    
    func cityState() -> String {
        var string = ""
        if let city = self.city {
            string += city
        }
        
        if let stateShort = self.stateShort {
            if string != "" {
                string += ", "
            }
            string += stateShort
        }
        else if let countryShort = self.countryShort {
            if string != "" {
                string += ", "
            }
            string += countryShort
        }
        
        // Sanity Check
        if string == "" {
            string = "City/State unknown"
        }
        return string
    }
}