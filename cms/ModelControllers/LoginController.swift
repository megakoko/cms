//
//  LoginController.swift
//  cms
//
//  Created by Andrey on 09/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class LoginController {
    static private(set) var currentUserId: Int? = 1

    private init() {
        
    }

    class func tryToLogIn(userName: String, password: String, handler: @escaping (Bool) -> (Void)) {
        NetworkManager.request(.logIn(userName: userName, password: password)) {
            response in

            if let error = response?.error {
                print("Failed to log in:", error)
                handler(false)
            } else if let data = response?.parsed([String:Int].self),
                let userId = data["id"] {
                LoginController.currentUserId = userId
                handler(true)
            } else {
                print("Failed to log in, error in parsing data")
                handler(false)
            }
        }
    }

    class func logOut() {
        currentUserId = nil
    }
}
