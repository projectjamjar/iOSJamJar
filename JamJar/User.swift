//
//  User.swift
//  JamJar
//
//  Created by Ethan Riback on 1/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Locksmith

struct User: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
    let username: String
    let password: String
    
    // Required by GenericPasswordSecureStorable
    let service = "JamJar"
    var account: String { return username }
    
    // Required by CreateableSecureStorable
    var data: [String: AnyObject] {
        return ["password": password]
    }
}