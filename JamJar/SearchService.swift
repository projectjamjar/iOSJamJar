//
//  SearchService.swift
//  JamJar
//
//  Created by Mark Koh on 5/2/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class SearchService: APIService {
    
    // search venues
    static func search(searchString: String, completion: (success: Bool, results: SearchResult?, result: String?) -> Void) {
        var url = self.buildURL("search") + "?q="
        
        let encodedSearchString = NSURL(string: (searchString as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!.absoluteString
        
        url += encodedSearchString
        
        self.get(url).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, results: nil, result: "Cannot Search Venues")
                return
            case .Success:
                let result = Mapper<SearchResult>().map(response.result.value!)
                completion(success: true, results: result, result: nil)
                return
            }
        }
    }
}
