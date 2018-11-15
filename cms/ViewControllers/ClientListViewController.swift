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
    var delegate: ClientListViewControllerDelegate?
    var emptySelectionOption: String?

    private var clients = [Client]()
    private var clientDataTask: URLSessionDataTask? = nil
    private var clientTypeDescriptions = [Client.ClientType.limitedCompany: "Company",
                                          Client.ClientType.trust: "Trust",
                                          Client.ClientType.partnership: "Partnership",
                                          Client.ClientType.individual: "Individual"]

    @IBAction  private func onTablePulledToRefresh(_ sender: UIRefreshControl) {
        refreshData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if delegate != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelClientSelection))

            navigationItem.rightBarButtonItem = nil
        }

        refreshData()
    }

    private func refreshData() {
        if clientDataTask != nil {
            clientDataTask?.cancel()
            clientDataTask = nil
        }

        clientDataTask = NetworkManager.request(.clients) {
            response in

            self.clientDataTask = nil

            if let error = response?.error {
                print("Failed to get clients: \(error)")
            } else {
                self.clients = response?.parsed([Client].self) ?? [Client]()
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (emptySelectionOption != nil ? 1 : 0) + clients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)

        if emptySelectionOption != nil && indexPath.row == 0 {
            cell.textLabel?.text = emptySelectionOption
            cell.detailTextLabel?.text = nil
        } else {
            let client = clients[indexPath.row - (emptySelectionOption != nil ? 1 : 0)]
            cell.textLabel?.text = client.name
            cell.detailTextLabel?.text = clientTypeDescriptions[client.type]! + (client.code == nil ? "" : (" — " + client.code!))
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            var clientId: Int? = nil
            var clientName: String? = nil

            if emptySelectionOption != nil && indexPath.row != 0 {
                let client = clients[indexPath.row - 1]
                clientId = client.id
                clientName = client.name
            }

            delegate?.didSelect(clientId: clientId, clientName: clientName)
            dismiss(animated: true)

            return
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if delegate != nil && identifier == "clientDrilldownSegue" {
            return false
        }

        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)

        let client = clients[indexPath!.row]

        let clientViewController = segue.destination as! ClientViewController
        clientViewController.setClient(id: client.id!, type: client.type)
        clientViewController.title = client.name
    }

    @IBAction private func unwindToClientList(_ sender: UIStoryboardSegue) {
        let newClientController = sender.source as! NewClientTableViewController
        if newClientController.createdClient {
            refreshData()
        }
    }

    @IBAction private func cancelClientSelection() {
        dismiss(animated: true)
    }
}
