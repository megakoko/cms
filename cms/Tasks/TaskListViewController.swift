//
//  FirstViewController.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController {
    private let model = TaskModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self

        model.refresh()

        NotificationCenter.default.addObserver(forName: TaskModel.taskUpdatedNotification,
                                               object: model,
                                               queue: nil) {
            _ in
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        let task = model.tasks[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.endDate == nil ? nil : (dateFormatter.string(from: task.endDate!))

        let overDue = task.endDate != nil ? (task.endDate! > Date()) : false
        cell.detailTextLabel?.textColor = overDue ? UIColor.red : UIColor.black

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        let task = model.tasks[indexPath!.row]

        let taskViewController = segue.destination as! TaskViewController
        taskViewController.id = task.id
    }
}
