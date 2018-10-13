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
    private var clients = [Client]()
    private var clientDataTask: URLSessionDataTask? = nil

    @IBAction func onTablePulledToRefresh(_ sender: UIRefreshControl) {
        refreshData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }

    func refreshData() {
        if clientDataTask != nil {
            clientDataTask?.cancel()
            clientDataTask = nil
        }

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
            } else {
                self.clients.removeAll()
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        clientDataTask!.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)

        let client = clients[indexPath.row]
        cell.textLabel?.text = client.name

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)

        let client = clients[indexPath!.row]

        let clientViewController = segue.destination as! ClientViewController
        clientViewController.id = client.id
        clientViewController.title = client.name
    }
}
