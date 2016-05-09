//
//  VideoService.swift
//  JamJar
//
//  Created by Ethan Riback on 3/9/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import ObjectMapper
import SwiftyJSON

class VideoService: APIService {
    
    // Upload Video
    static func upload(videoURL: NSURL, name: String, is_private: Int, concert_id: Int, artists: [Artist], completion: (success: Bool, result: String?) -> Void) {
        let url = self.buildURL("videos")
        var headers = [
            "Content-Type": "multipart/form-data"
        ]
        if let token = AuthService.getToken() {
            headers["Authorization"] = "Token \(token)"
        }
        
        let parameters = [
            "name": name,
            "is_private": String((is_private == 1)),
            "concert": String(concert_id)
        ]
        
        Alamofire.upload(
            .POST,
            url,
            headers: headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: videoURL, name: "file")
                
                for (key, value) in parameters {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
                
                for artist in artists {
                    multipartFormData.appendBodyPart(data: artist.spotifyResponseId!.dataUsingEncoding(NSUTF8StringEncoding)!, name: "artists")
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        completion(success: true, result: "Upload was a success!")
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    completion(success: false, result: "Upload failed")
                }
            }
        )
    }
    
    // get all concerts
    static func getJamPicks(completion: (success: Bool, result: [Video]?, error: String?) -> Void) {
        var url = self.buildURL("videos/jampicks")
        
        self.get(url).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, result: nil, error: "Cannot Get Jampicks")
                return
            case .Success:
                let objects = Mapper<Video>().mapArray(response.result.value!)
                completion(success: true, result: objects, error: nil)
                return
            }
        }
    }
}