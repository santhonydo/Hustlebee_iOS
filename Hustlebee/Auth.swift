//
//  User.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/1/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import Foundation

class Auth {

    func validateUserInputFields(email: String, password: String) -> Dictionary<String,Bool> {
        return ["email": email.isValidEmail, "password": password.isValidPassword]
    }
    
    func getUserInfoFromDB(_ email: String, _ password: String, _ completion: @escaping (User?, Error?) -> Void) {
        Request.userAuth(email, password) { user, error in
            if let error = error {
                completion(nil, error)
            } else if let user = user {
                let encodedUserData = NSKeyedArchiver.archivedData(withRootObject: user)
                let userDefaults = UserDefaults.standard
                userDefaults.set(encodedUserData, forKey: "userProfileData")
                userDefaults.set(true, forKey: "userLoggedIn")
                userDefaults.synchronize()
                completion(user, nil)
            }
        }
    }
}
