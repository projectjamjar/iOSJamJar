//
//  UserService.swift
//  JamJar
//
//  Created by Ethan Riback on 2/13/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import Locksmith
import ObjectMapper

class UserService: APIService {
    
    //Log the user in with the provided username and password
    static func login(username: String, password: String, completion: (success: Bool, result: String?) -> Void) {
        let url = self.buildURL("auth/login/")
        let parameters = [
            "username": username,
            "password" : password
        ]
        
        self.post(url, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                completion(success: false, result: "Invalid username or password")
                return
            case .Success:
                // We got a success response code, login info was correct
                // Parse the JSON response
                let json = JSON(response.result.value!)
                
                // Get the auth token and user from the response
                let token = json["token"]["key"].string!
                let user_json = json["user"]
                
                // Get a User object from the json
                let user = Mapper<User>().map(user_json.rawString())
                
                self.saveUserInfo(username, password: password, token: token)
            }
        }
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