//
//  User.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct User : Decodable {
    let id: Int
    let fullName: String
    let loggedIn: Bool
}
