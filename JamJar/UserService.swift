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
import SwiftyJSON

class UserService: APIService {
    
    static private var user: User?
    
    static func currentUser() -> User? {
        return user
    }
    
    static func currentUser(u: User?) {
        user = u
    }
    
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
                
                // Set our data in Locksmith
                AuthService.SetTokenAndUser(token, user: user!)
                
                // Now set our singletons with that data!
                AuthService.AttemptAuth()
                
                completion(success: true, result: nil)
                return
            }
        }
    }
    
    //Log the user in with the provided username and password
    static func signup(email: String, username: String, firstName: String, lastName: String, password: String, confirm: String, completion: (success: Bool, error: String?) -> Void) {
        let url = self.buildURL("auth/signup/")
        let parameters = [
            "email": email,
            "username": username,
            "first_name": firstName,
            "last_name": lastName,
            "password" : password,
            "confirm": confirm
        ]
        
        self.post(url, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                let errorString = JSON(data: response.data!)["error"].rawString()
                completion(success: false, error: errorString)
                return
            case .Success:
                // We got a success response code, signup was successful
                completion(success: true, error: nil)
                return
            }
        }
    }
    
    //Log the user in with the provided username and password
    static func forgot(email: String, completion: (success: Bool, error: String?) -> Void) {
        let url = self.buildURL("auth/reset/")
        let parameters = [
            "email": email
        ]
        
        self.post(url, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                let errorString = JSON(data: response.data!)["error"].rawString()
                completion(success: false, error: errorString)
                return
            case .Success:
                // We got a success response code, reset was successful
                completion(success: true, error: nil)
                return
            }
        }
    }
    
    static func logout() {
        // Unset the user and token singletons and delete locksmith data
        UserService.currentUser(nil)
        APIService.setToken(nil)
        AuthService.RemoveUserData()
        
        // Set up the login storyboard again
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.setupLoginStoryboard()
    }
    
    static func getUserProfile(username: String, completion: (success: Bool, result: UserProfile?, error: String?) -> Void) {
        let url = self.buildURL("users/\(username)")
        
        self.get(url).responseJSON { response in
            switch response.result {
            case .Failure(_):
                // We got an error response code
                let errorString = JSON(data: response.data!)["error"].rawString()
                completion(success: false, result: nil, error: errorString)
                return
            case .Success:
                // We got a success response code and a profile
                let profile = Mapper<UserProfile>().map(response.result.value!)
                
                completion(success: true, result: profile, error: nil)
                return
            }
        }
    }
    
}