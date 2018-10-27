//
//  ClientViewController.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation
import UIKit

class ClientViewController : UITableViewController {
    private var client: Client? = nil
    private var relationships = [Relationship] ()

    private struct Field {
        init(description: String, data: String?, detectorTypes: UIDataDetectorTypes = UIDataDetectorTypes()) {
            self.description = description
            self.data = data
            self.detectorTypes = detectorTypes
        }
        let description: String
        let data: String?
        let detectorTypes: UIDataDetectorTypes
    }
    private var fields = [Field]()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUi()

        if client?.id != nil {
            loadData()
            updateUi()
        }
    }

    func setClient(id: Int, type: Client.ClientType) {
        self.client = Client(id: id, type: type)
    }

    private func loadData() {
        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let url = URL(string: "\(host)/client?id=eq.\(client!.id)")!

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
                self.updateUi()
            }
        }
        coreDataTask.resume()

        let relationshipUrl = URL(string: "\(host)/clientrelationship?clientId=eq.\(client!.id)")!
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
                self.updateUi()
            }
        }

        relationshipsDataTask.resume()
    }

    private func updateUi() {
        fields.removeAll()

        if let client = client {
            let isPerson = (client.type == .individual)

            fields.append(Field(description: "Client Code", data: client.code))
            if isPerson {
                fields.append(Field(description: "First name", data: client.foreNames))
                fields.append(Field(description: "Middle name", data: client.middleNames))
                fields.append(Field(description: "Surname", data: client.surname))
            } else {
                fields.append(Field(description: "Company name", data: client.companyName))
            }
            fields.append(Field(description: "UTR", data: client.utr))
            fields.append(Field(description: "Telephone", data: client.phoneNumber, detectorTypes: .phoneNumber))
            fields.append(Field(description: "Email", data: client.email, detectorTypes: .link))
        }

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + fields.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == (numberOfSections(in: tableView) - 1) {
            return "Relationships"
        } else {
            return fields[section].description
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == (numberOfSections(in: tableView) - 1) {
            return relationships.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientViewCell", for: indexPath) as! ClientViewCell

        if indexPath.section == (numberOfSections(in: tableView) - 1) {
            let relationship = relationships[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.textView.isUserInteractionEnabled = false
            cell.textView.text = relationship.relatedClientName
        } else {
            cell.selectionStyle = .none
            cell.textView.text = fields[indexPath.section].data
            cell.textView.dataDetectorTypes = fields[indexPath.section].detectorTypes
        }

        return cell
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else { return false }
        return indexPath.section == (numberOfSections(in: tableView) - 1)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)

        let relationship = relationships[indexPath!.row]

        let clientViewController = segue.destination as! ClientViewController
        clientViewController.setClient(id: relationship.relatedClientId, type: relationship.relatedClientType)
        clientViewController.title = relationship.relatedClientName
    }
}
