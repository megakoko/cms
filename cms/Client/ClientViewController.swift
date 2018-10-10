//
//  ClientViewController.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation
import UIKit

class ClientViewController : UIViewController, UITableViewDataSource {
    private var model: ClientModel = ClientModel()
    var id: Int? = nil

    @IBOutlet weak var utrLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        model.load(id: id!)

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
            self.tableView.reloadData()
        }
    }

    func reloadData() {
        utrLabel.text = model.utr
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.relationships.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelationshipCell", for: indexPath)

        let relationship = model.relationships[indexPath.row]
        cell.textLabel?.text = relationship.relatedClientName

        return cell
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
