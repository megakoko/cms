//
//  LoginData.swift
//  cms
//
//  Created by Andrey on 23/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct LoginData : Codable {
    let userId: Int?
    let userName: String?
    let userPassword: String?
}
