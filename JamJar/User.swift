//
//  User.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Locksmith
import ObjectMapper

struct User: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    
    // User attributes
    var id: Int?
    var username: String!
    var email: String!
    var firstName: String!
    var lastName: String!
    var fullName: String!

    // Required by GenericPasswordSecureStorable
    let service = "JamJar"
    var account: String { return username }
    
    // Required by CreateableSecureStorable
    var data: [String: AnyObject] {
        return ["password" : password,
            "authToken" : authToken]
    }
    
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
        username <- map["username"]
        email <- map["email"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        fullName <- map["full_name"]
    }
}