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

    var userId = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
    }

    private func refreshData() {
        if taskListDataTask != nil {
            taskListDataTask!.cancel()
            taskListDataTask = nil
        }

        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/tasks?assigneeId=eq.\(userId)&status=neq.completed&order=endDate.desc")

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

    private func sendTaskDeletionRequest(id: Int, completionHandler: @escaping (Bool) -> Void) {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/task?id=eq.\(id)")

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "DELETE"

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to delete task: \(error!)")
                completionHandler(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    print("Failed to delete task, status code: \(httpResponse.statusCode)")
                    completionHandler(false)
                    return;
                }
            }

            completionHandler(true)
        }

        dataTask.resume();
    }

    private func deleteTask(id: Int) {
        sendTaskDeletionRequest(id: id) {
            deleted in

            if !deleted {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Delete Task", message: "Failed to delete the task", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }

            for (row, task) in self.tasks.enumerated() {
                if task.id != id { continue }

                self.tasks.remove(at: row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
            }
        }
    }

    private func sendTaskCompletionRequest(id: Int, completionHandler: @escaping (Bool) -> Void) {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/task?id=eq.\(id)")

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(["status": "completed"]) else {
            completionHandler(false)
            return
        }

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PATCH"
        urlRequest.httpBody = data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to complete task: \(error!)")
                completionHandler(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    print("Failed to complete task, status code: \(httpResponse.statusCode)")
                    completionHandler(false)
                    return;
                }
            }

            completionHandler(true)
        }

        dataTask.resume();
    }

    private func completeTask(id: Int) {
        sendTaskCompletionRequest(id: id) {
            completed in

            if !completed {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Complete Task", message: "Failed to complete the task", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }

            for (row, task) in self.tasks.enumerated() {
                if task.id != id { continue }

                self.tasks.remove(at: row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
            }
        }
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

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Complete") {
            _, _, completionHandler in

            completionHandler(false)

            let task = self.tasks[indexPath.row]
            self.completeTask(id: task.id)
        }
        completeAction.backgroundColor = UIColor(red: 0.12, green: 0.46, blue: 1, alpha: 1)

        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            _, _, completionHandler in

            completionHandler(false)

            let task = self.tasks[indexPath.row]
            self.deleteTask(id: task.id)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[indexPath!.row]

        let taskViewController = segue.destination as! TaskViewController
        taskViewController.id = task.id
    }
}
