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

    enum Gender : String {
        case male = "male"
        case female = "female"
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



    func load(id: Int) {
        self.id = id

        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let request = URLRequest(url: URL(string: "\(host)/client?id=eq.\(id)")!)

        let task = URLSession.shared.dataTask(with: request) {
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

        task.resume()
    }
}
