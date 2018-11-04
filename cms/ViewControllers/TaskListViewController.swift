//
//  FirstViewController.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController {
    var tasks = [Task]()
    var taskListDataTask: URLSessionDataTask? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }

    func refreshData() {
        if taskListDataTask != nil {
            taskListDataTask!.cancel()
            taskListDataTask = nil
        }

        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/tasks?order=endDate.desc")

        taskListDataTask = URLSession.shared.dataTask(with: url!) {
            data, response, error in

            if error != nil {
                print("Failed to get list of tasks. \(error!))")
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let tasks = try? decoder.decode([Task].self, from: data!) {
                self.tasks = tasks
            } else {
                self.tasks.removeAll()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }

        taskListDataTask!.resume()
    }

    @IBAction func onTablePulledToRefresh(_ sender: Any) {
        refreshData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        let task = tasks[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.endDate == nil ? nil : (dateFormatter.string(from: task.endDate!))

        if task.endDate != nil && task.endDate! <= Date() {
            cell.detailTextLabel?.textColor = UIColor.red
        } else if task.endDateReminder != nil && task.endDateReminder! <= Date() {
            cell.detailTextLabel?.textColor = UIColor.orange
        } else {
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[indexPath!.row]

        let taskViewController = segue.destination as! TaskViewController
        taskViewController.id = task.id
    }
}
