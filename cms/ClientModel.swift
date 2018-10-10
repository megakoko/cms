//
//  ClientModel.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class ClientModel {
    static let clientListUpdateNotification = Notification.Name("clientListUpdateNotification")

    struct Client {
        enum ClientType: String {
            case individual = "individual"
            case limitedCompany = "limitedCompany"
            case trust = "trust"
            case partnership = "partnership"
        }

        let id: Int
        let type: ClientType
        let name: String
        let clientcode: String
    }


    private(set) var clients = [Client]()

    private var clientDataTask: URLSessionDataTask? = nil

    func clear() {
        clients.removeAll()
        if clientDataTask != nil {
            clientDataTask?.cancel()
            clientDataTask = nil
        }
    }

    func refresh() {
        clear()

        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let request = URLRequest(url: URL(string: "\(host)/clients")!)

        clientDataTask = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                print("Failed to get clients: \(error!)")
                return
            }

            guard let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] else {
                print("Failed to parse clients")
                return
            }

            for jsonObject in json {
                guard
                    let id = jsonObject["id"] as? Int,
                    let type = Client.ClientType(rawValue: jsonObject["type"] as? String ?? ""),
                    let name = jsonObject["name"] as? String,
                    let code = jsonObject["clientcode"] as? String
                else {
                    print("Failed to parse client")
                    continue
                }
                let client = Client(id: id, type: type, name: name, clientcode: code)
                self.clients.append(client)
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientModel.clientListUpdateNotification))
            }
        }

        clientDataTask!.resume()
    }
}
