//
//  UserService.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import Locksmith

class UserService: APIService {
    
    //Log the user in with the provided username and password
    static func login(username: String, password: String) -> Request {
        print("Logging In...")
        
        let parameters = [
            "username": username,
            "password" : password
        ]
        
        return self.post(self.buildURL("auth/login/"),parameters: parameters)
    }
    
    //check if the user is already logged in
    static func isUserLoggedIn() -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let username = prefs.stringForKey("username")
        
        if username == nil {
            return false
        }
        
        //user is logged in, make sure auth token is recorded properly
        let user = currentUser()
        let data = user.readFromSecureStore()?.data
        let token = data!["authToken"] as! String
        self.setToken(token)
        
        return true
    }
    
    static func saveUserInfo(username: String, password: String, token: String) -> Bool {
        do {
            let user = User(username: username, password: password, authToken: token)
            try user.createInSecureStore()
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(username, forKey: "username")
            prefs.synchronize()
            
            //Save token in Service
            self.setToken(token)
            
            //username successfully stored, return true
            return true
        } catch {
            //something went wrong, return false
            return false
        }
    }
    
    static func logout() -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let user = User(username: prefs.stringForKey("username")!, password: "", authToken: "")
        
        do {
            try user.deleteFromSecureStore()
            prefs.removeObjectForKey("username")
            prefs.synchronize()
            //reset token
            self.setToken("")
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
        
        return user;
    }
}