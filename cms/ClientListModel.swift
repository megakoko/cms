//
//  ClientModel.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class ClientListModel {
    static let clientListUpdateNotification = Notification.Name("clientListUpdateNotification")

    struct Client : Decodable {
        enum ClientType: String, Decodable {
            case individual = "individual"
            case limitedCompany = "limitedCompany"
            case trust = "trust"
            case partnership = "partnership"
        }

        let id: Int
        let type: ClientType
        let name: String
        let code: String?
    }


    private(set) var clients = [Client]() {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(Notification(name: ClientListModel.clientListUpdateNotification))
            }
        }
    }

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
        let url = URL(string: "\(host)/clients")
        
        clientDataTask = URLSession.shared.dataTask(with: url!) {
            data, response, error in

            if error != nil {
                print("Failed to get clients: \(error!)")
                return
            }

            let decoder = JSONDecoder()
            if let clients = try? decoder.decode([Client].self, from: data!) {
                self.clients = clients
            }
        }

        clientDataTask!.resume()
    }
}
