//
//  LoginController.swift
//  cms
//
//  Created by Andrey on 09/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class LoginController {
    static var shared = LoginController()

    static private(set) var currentUserId: Int? = 1

    private init() {
        
    }
}
