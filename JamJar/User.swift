//
//  User.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Locksmith
import ObjectMapper

class User: NSObject, NSCoding, Mappable {
    
    // User attributes
    var id: Int?
    var username: String!
    var email: String!
    var firstName: String!
    var lastName: String!
    var fullName: String!

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
    
    required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObjectForKey("id") as! Int?
        email = aDecoder.decodeObjectForKey("email") as! String
        username = aDecoder.decodeObjectForKey("username") as! String
        firstName = aDecoder.decodeObjectForKey("firstName") as! String
        lastName = aDecoder.decodeObjectForKey("lastName") as! String
        fullName = aDecoder.decodeObjectForKey("fullName") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(email, forKey: "email")
        aCoder.encodeObject(username, forKey: "username")
        aCoder.encodeObject(firstName, forKey: "firstName")
        aCoder.encodeObject(lastName, forKey: "lastName")
        aCoder.encodeObject(fullName, forKey: "fullName")
    }
}