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

    enum Gender : String {
        case male = "male"
        case female = "female"
    }

    struct Relationship {
        var relatedClientId: Int
        var relatedClientName: String
        var type: String
    }

    private(set) var id: Int? = nil
    private(set) var type: ClientListModel.Client.ClientType = .individual
    private(set) var utr: String? = nil
    private(set) var code: String? = nil
    private(set) var company: String? = nil
    private(set) var forenames: String? = nil
    private(set) var middleNames: String? = nil
    private(set) var surname: String? = nil
    private(set) var gender: Gender = .male

    private(set) var relationships = [Relationship] ()


    func load(id: Int) {
        self.id = id

        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let coreRequest = URLRequest(url: URL(string: "\(host)/client?id=eq.\(id)")!)
        let coreDataTask = URLSession.shared.dataTask(with: coreRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get client: \(error!)")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]] else {
                print("Failed to parse client")
                return
            }

            if json.isEmpty {
                print("Empty client");
                return
            }

            let jsonObject = json[0]
            self.utr = jsonObject["utr"] as? String

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientModel.clientUpdateNotification))
            }
        }
        coreDataTask.resume()

        let relationshipsRequest = URLRequest(url: URL(string: "\(host)/clientrelationship?clientid=eq.\(id)")!)
        let relationshipsDataTask = URLSession.shared.dataTask(with: relationshipsRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get relationships: \(error!)")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [[String: Any]] else {
                print("Failed to parse relationships")
                return
            }

            for jsonObject in json {
                guard   let relatedClientId = jsonObject["relatedclientid"] as? Int,
                        let relatedClientName = jsonObject["relatedclientname"] as? String,
                        let type = jsonObject["type"] as? String
                else {
                    print("Failed to parse relationship")
                    continue
                }

                self.relationships.append(Relationship(relatedClientId: relatedClientId, relatedClientName: relatedClientName, type: type))
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientModel.clientRelationshipUpdateNotification))
            }
        }

        relationshipsDataTask.resume()
    }
}
