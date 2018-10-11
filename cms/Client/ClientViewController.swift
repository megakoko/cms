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

    var data = [(String,String?)]()

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
        data.removeAll()

        if let client = model.client {
            let isPerson = (client.type == .individual)

            data.append(("Client code", client.code))
            if isPerson {
                data.append(("First name", client.foreNames))
                data.append(("Middle name", client.middleNames))
                data.append(("Surname", client.surname))
            } else {
                data.append(("Company name", client.companyName))
            }
            data.append(("UTR", client.utr))
        }

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + data.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == (numberOfSections(in: tableView) - 1) {
            return "Relationships"
        } else {
            return data[section].0
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelationshipCell", for: indexPath)

        if indexPath.section == (numberOfSections(in: tableView) - 1) {
            let relationship = model.relationships[indexPath.row]
            cell.textLabel?.text = relationship.relatedClientName
        } else {
            cell.selectionStyle = .none
            cell.textLabel?.text = data[indexPath.section].1
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
