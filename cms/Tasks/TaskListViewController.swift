//
//  FirstViewController.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private let model = TaskModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self

        model.refresh()

        NotificationCenter.default.addObserver(forName: TaskModel.taskUpdatedNotification,
                                               object: nil,
                                               queue: nil) {
            _ in
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        cell.label.text = "Cell \(indexPath.row)"

        let task = model.tasks[indexPath.row]
        cell.label.text = "\(task.name)"
        return cell
    }
}
