//
//  ClientListViewController.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

import UIKit

class ClientListViewController : UITableViewController {
    private var model = ClientListModel()

    @IBAction func onTablePulledToRefresh(_ sender: UIRefreshControl) {
        model.refresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        model.refresh()

        NotificationCenter.default.addObserver(forName: ClientListModel.clientListUpdateNotification, object: nil, queue: nil) {
            _ in
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.clients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)

        let client = model.clients[indexPath.row]
        cell.textLabel?.text = client.name

        return cell
    }
}
