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
        let headers = [
            "Content-Type": "multipart/form-data",
            "Authorization": "Token \(AuthService.GetToken()!)"
        ]
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
                    multipartFormData.appendBodyPart(data: String(artist.id).dataUsingEncoding(NSUTF8StringEncoding)!, name: "artists")
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
}