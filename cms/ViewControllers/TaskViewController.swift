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
        NetworkManager.request(.task(id: id!)) {
            response in

            if let error = response?.error {
                print("Failed to get task: \(error)")
            } else {
                self.task = response?.parsed(Task.self)

                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        }
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
