//
//  ClientModel.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class ClientModel {
    static let clientUpdateNotification = Notification.Name("clientUpdateNotification")
    static let clientRelationshipUpdateNotification = Notification.Name("clientRelationshipUpdateNotification")

    enum Gender : String, Decodable {
        case male = "male"
        case female = "female"
    }

    struct Relationship : Decodable {
        var relatedClientId: Int
        var relatedClientName: String
        var type: String
    }

    struct Client : Decodable {
        var id: Int
        var type: ClientListModel.Client.ClientType = .individual
        var code: String?
        var utr: String?
        var foreNames: String?
        var middleNames: String?
        var surname: String?
        var companyName: String?

        var gender: Gender?
    }

    private(set) var client: Client? = nil
    private(set) var relationships = [Relationship] ()

    func load(id: Int) {
        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let url = URL(string: "\(host)/client?id=eq.\(id)")!

        let coreDataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in

            if error != nil {
                print("Failed to get client: \(error!)")
                return
            }

            if let clients = try? JSONDecoder().decode([Client].self, from: data!) {
                self.client = clients.first
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientModel.clientUpdateNotification, object: self, userInfo: nil))
            }
        }
        coreDataTask.resume()

        let relationshipUrl = URL(string: "\(host)/clientrelationship?clientId=eq.\(id)")!
        let relationshipsDataTask = URLSession.shared.dataTask(with: relationshipUrl) {
            data, response, error in

            if error != nil {
                print("Failed to get relationships: \(error!)")
                return
            }

            if let relationships = try? JSONDecoder().decode([Relationship].self, from: data!) {
                self.relationships = relationships
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientModel.clientRelationshipUpdateNotification, object: self, userInfo: nil))
            }
        }

        relationshipsDataTask.resume()
    }
}
