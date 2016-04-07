//
//  ConcertService.swift
//  JamJar
//
//  Created by Ethan Riback on 3/9/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class ConcertService: APIService {
    
    // get all concerts
    static func getConcerts(completion: (success: Bool, concert: [Concert]?, result: String?) -> Void) {
        let url = self.buildURL("concerts")
        
        self.get(url).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, concert: nil, result: "Cannot Get Concerts")
                return
            case .Success:
                let concerts = Mapper<Concert>().mapArray(response.result.value!)
                completion(success: true, concert: concerts, result: nil)
                return
            }
        }
    }
    
    // create concert
    static func create(venue_place_id: String, date: String, completion: (success: Bool, concert: Concert?, result: String?) -> Void) {
        let url = self.buildURL("concerts")
        let parameters = [
            "venue_place_id": venue_place_id,
            "date" : date
        ]
        
        self.post(url,parameters: parameters).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, concert: nil, result: "Cannot Get/Create Concert")
                return
            case .Success:
                let concert = Mapper<Concert>().map(response.result.value!)
                completion(success: true, concert: concert, result: nil)
                return
            }
        }
    }
    
    // get JamJars
    static func getConcertDetails(concert_id: Int, completion: (success: Bool, concert: Concert?, result: String?) -> Void) {
        let url = self.buildURL("concerts/\(concert_id)/")
        
        self.get(url).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, concert: nil, result: "Cannot Get Concert")
                return
            case .Success:
                let concertDetail = Mapper<Concert>().map(response.result.value!)
                completion(success: true, concert: concertDetail, result: nil)
                return
            }
        }
    }
}