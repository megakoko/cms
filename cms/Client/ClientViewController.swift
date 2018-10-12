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
    private var model: ClientModel = ClientModel()
    var id: Int? = nil

    struct Field {
        init(description: String, data: String?, detectorTypes: UIDataDetectorTypes = UIDataDetectorTypes()) {
            self.description = description
            self.data = data
            self.detectorTypes = detectorTypes
        }
        let description: String
        let data: String?
        let detectorTypes: UIDataDetectorTypes
    }
    var fields = [Field]()

    override func viewDidLoad() {
        super.viewDidLoad()

        model.load(id: id!)
        reloadData()

        NotificationCenter.default.addObserver(forName: ClientModel.clientUpdateNotification,
                                               object: model,
                                               queue: nil) {
            _ in
            self.reloadData()
        }

        NotificationCenter.default.addObserver(forName: ClientModel.clientRelationshipUpdateNotification,
                                               object: model,
                                               queue: nil) {
            _ in
            self.reloadData()
        }
    }

    func reloadData() {
        fields.removeAll()

        if let client = model.client {
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
            return model.relationships.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientViewCell", for: indexPath) as! ClientViewCell

        if indexPath.section == (numberOfSections(in: tableView) - 1) {
            let relationship = model.relationships[indexPath.row]
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
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("No relationship selected")
            return
        }

        let relationship = model.relationships[indexPath.row]

        let clientViewController = segue.destination as! ClientViewController
        clientViewController.id = relationship.relatedClientId
        clientViewController.title = relationship.relatedClientName
    }
}
