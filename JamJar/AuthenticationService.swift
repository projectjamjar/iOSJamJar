//
//  AuthenticationService.swift
//  JamJar
//
//  Created by Mark Koh on 2/23/16.
//  Copyright © 2016 JamJar. All rights reserved.
//

import Alamofire
import Locksmith
import ObjectMapper
import SwiftyJSON

class AuthService: APIService {
    
    static let userAccount: String = "JamJar"
    
    static func AttemptAuth() {
        let token = self.GetToken()
        let user = self.GetUser()
        if token != nil && user != nil {
            UserService.currentUser(user)
            APIService.setToken(token!)
        }
    }
    
    static func SetTokenAndUser(token: String, user: User) {
        do {
            try Locksmith.saveData(["authToken" : token, "user": user], forUserAccount: AuthService.userAccount)
        }
        catch _ {
            print("Couldn't set token")
        }
    }
    
    static func GetToken() -> String? {
        if let dictionary = Locksmith.loadDataForUserAccount(AuthService.userAccount) {
            return dictionary["authToken"] as! String?
        }
        else {
            return nil
        }
    }
    
    static func GetUser() -> User? {
        if let dictionary = Locksmith.loadDataForUserAccount(AuthService.userAccount) {
            return dictionary["user"] as! User?
        }
        else {
            return nil
        }
    }
    
    static func RemoveUserData() {
        do {
            try Locksmith.deleteDataForUserAccount(AuthService.userAccount)
        }
        catch _ {
            print("Couldn't delete user data")
        }
    }
}