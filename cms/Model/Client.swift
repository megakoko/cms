//
//  Client.swift
//  cms
//
//  Created by Andy on 13/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct Client : Decodable {
    enum ClientType: String, Decodable {
        case individual = "individual"
        case limitedCompany = "limitedCompany"
        case trust = "trust"
        case partnership = "partnership"
    }

    var id: Int
    var type: ClientType
    var name: String?
    var code: String?
    var utr: String?
    var foreNames: String?
    var middleNames: String?
    var surname: String?
    var companyName: String?
    var phoneNumber: String?
    var email: String?
}

struct Relationship : Decodable {
    var relatedClientId: Int
    var relatedClientName: String
    var type: String
}
