//
//  APIService.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire

class APIService {
    static private let baseURL: String = "http://api.projectjamjar.com/"
    static private let url: NSURL = NSURL(string: baseURL)!
    static private var token: String?
    
    static func appendSlash(var path: String) -> String {
        if path.characters.last != "/" {
            path += "/"
        }
        return path
    }
    
    static func buildURL(path: String) -> String {
        return NSURL(string: self.appendSlash(path), relativeToURL: url)!.absoluteString
    }
    
    /*
    static func buildAuthURL(path: String) -> String {
        let userId = UserService.currentUser().id!
        let pathWithUserId = "\(userId)/\(self.appendSlash(path))"
        
        return NSURL(string: pathWithUserId, relativeToURL: url)!.absoluteString
    }
    */
    
    static func setToken(token: String) {
        self.token = token
    }
    
    static func getRequestHeaders() -> [String: String] {
        var headers = [
            "Content-Type": "application/json"
        ]
        
        if (self.token != nil) {
            headers["Authorization"] = "Token \(self.token!)"
        }
        
        return headers
    }
    
    static func post(url: String, parameters: [String: AnyObject]? = nil) -> Request {
        let headers = self.getRequestHeaders()
        return Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: headers).validate()
    }
    
    static func get(url: String) -> Request {
        let headers = self.getRequestHeaders()
        return Alamofire.request(.GET, url, encoding: .JSON, headers: headers).validate()
    }
    
    static func put(url: String, parameters: [String: AnyObject]? = nil) -> Request {
        let headers = self.getRequestHeaders()
        return Alamofire.request(.PUT, url, parameters: parameters, encoding: .JSON, headers: headers).validate()
    }
    
}
