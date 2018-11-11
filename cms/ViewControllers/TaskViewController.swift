//
//  TaskViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController {
    var id: Int? = nil

    private var task: Task? = nil

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var assigneeLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var clientNameCell: UITableViewCell!
    @IBOutlet weak var workDescriptionLabel: UILabel!
    @IBOutlet weak var clientNameTapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUi()
        reloadData()
    }

    private func reloadData() {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/task?id=eq.\(id!)")

        let dataTask = URLSession.shared.dataTask(with: url!) {
            data, response, error in

            if error != nil {
                print("Failed to get task: \(error!)")
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            if let tasks = try? decoder.decode([Task].self, from: data!) {
                if !tasks.isEmpty {
                    self.task = tasks[0]
                }
            }

            DispatchQueue.main.async {
                self.updateUi()
            }
        }

        dataTask.resume()
    }

    private func updateUi() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy 'at' hh:mm"

        nameLabel.text = task?.name
        statusLabel.text = task?.status
        endDateLabel.text = task?.endDate != nil ? dateFormatter.string(from: (task?.endDate)!) : nil
        startDateLabel.text = task?.startDate != nil ? dateFormatter.string(from: (task?.startDate)!) : nil
        assigneeLabel.text = task?.assignee
        clientNameLabel.text = task?.clientName
        clientNameCell.accessoryType = task?.clientId == nil ? .none : .disclosureIndicator
        workDescriptionLabel.text = task?.workDescription

        clientNameTapGestureRecognizer.isEnabled = (task?.clientId != nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientSegue" {
            let clientViewController = segue.destination as! ClientViewController

            if let task = task {
                clientViewController.setClient(id: task.clientId!, type: task.clientType!)
                clientViewController.title = task.clientName
            }
        }
    }
}
