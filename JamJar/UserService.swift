//
//  UserService.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Locksmith

class UserService: APIService {
    
    static func logout() -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let user = User(username: prefs.stringForKey("username")!, password: "", authToken: "")
        
        do {
            try user.deleteFromSecureStore()
            prefs.removeObjectForKey("username")
            prefs.synchronize()
            return true
        } catch {
            //TODO: implement code for actual error
            print("There was an error when trying to delete user information")
            return false
        }
    }
    
    static func currentUser() -> User {
        let prefs = NSUserDefaults.standardUserDefaults()
        let user = User(username: prefs.stringForKey("username")!, password: "", authToken: "")
        
        user.readFromSecureStore()
        print(user);
        
        return user;
    }
}