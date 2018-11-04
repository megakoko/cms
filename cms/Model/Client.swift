//
//  Client.swift
//  cms
//
//  Created by Andy on 13/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct Client : Codable {
    enum ClientType: String, Codable {
        case individual = "individual"
        case limitedCompany = "limitedCompany"
        case trust = "trust"
        case partnership = "partnership"
    }

    init(id: Int?, type: ClientType) {
        self.id = id
        self.type = type
    }

    var id: Int?
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
    var address: String?
}

struct Relationship : Decodable {
    var relatedClientId: Int
    var relatedClientType: Client.ClientType
    var relatedClientName: String
    var type: String
}
