//
//  ArtistService.swift
//  JamJar
//
//  Created by Ethan Riback on 3/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class ArtistService: APIService {

    // search venues
    static func search(searchString: String, completion: (success: Bool, artists: [Artist]?, result: String?) -> Void) {
        self.get(APIService.buildURL("artists/search/" + searchString)).responseJSON { response in
            switch response.result {
                case .Failure(_):
                    // We got an error response code
                    completion(success: false, artists: nil, result: "Cannot Search Artists")
                    return
                case .Success:
                    let artists = Mapper<Artist>().mapArray(response.result.value!)
                    completion(success: true, artists: artists, result: nil)
                    return
            }
        }
    }
}