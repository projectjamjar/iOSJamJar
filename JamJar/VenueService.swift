//
//  VenueService.swift
//  JamJar
//
//  Created by Ethan Riback on 3/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class VenueService: APIService {
    
    // Attributes used to connect to GoogleMaps API
    static private let googleMapsKey = "AIzaSyBXPftf0XBdnSQhHzUuXihnABCRfnl3OiI"
    static private let googleMapsURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    // search venues
    static func search(searchString: String, completion: (success: Bool, venues: [Venue]?, result: String?) -> Void) {
        let urlString = "\(googleMapsURLString)?key=\(googleMapsKey)&input=\(searchString)"
        let url = NSURL(string: (urlString as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!.absoluteString
        
        self.get(url).responseJSON { response in
            switch response.result {
                case .Failure(_):
                    // We got an error response code
                    completion(success: false, venues: nil, result: "Cannot Search Venues")
                    return
                case .Success:
                    let venues = Mapper<Venue>().mapArray(response.result.value!["predictions"])
                    completion(success: true, venues: venues, result: nil)
                    return
            }
        }
    }
}