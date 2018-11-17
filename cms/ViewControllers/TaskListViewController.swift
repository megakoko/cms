//
//  FirstViewController.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController, TaskTableViewCellDelegate {
    private var tasks = [Task]()
    private var taskListDataTask: URLSessionDataTask? = nil

    static let listUpdateNotification = Notification.Name("listUpdateNotification")

    private var userId = 1
    
    private var recordingTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
        
        NotificationCenter.default.addObserver(forName: TimesheetController.timesheetTaskActionNotificationName, object: nil, queue: nil) {
            notification in
            self.handleTimesheetActionNotification(notification)
        }
    }

    private func refreshData() {
        if taskListDataTask != nil {
            taskListDataTask!.cancel()
            taskListDataTask = nil
        }

        taskListDataTask = NetworkManager.request(.tasks) {
            response in

            if let error = response?.error {
                print("Failed to get list of tasks: \(error)")
                return
            }

            self.tasks = response?.parsed([Task].self) ?? [Task]()

            self.taskListDataTask = nil

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                NotificationCenter.default.post(name: TaskListViewController.listUpdateNotification, object: self)
            }
        }
    }

    private func sendTaskDeletionRequest(id: Int, completionHandler: @escaping (Bool) -> Void) {
        NetworkManager.request(.deleteTask(id: id)) {
            response in

            if let error = response?.error {
                print("Failed to delete task: \(error)")
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
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
                    NotificationCenter.default.post(name: TaskListViewController.listUpdateNotification, object: self)
                }
            }
        }
    }

    private func sendTaskCompletionRequest(task: Task, completionHandler: @escaping (Bool) -> Void) {
        NetworkManager.request(.updateTask(task)) {
            response in

            if let error = response?.error {
                print("Failed to complete task: \(error)")
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }

    private func completeTask(task: Task) {
        sendTaskCompletionRequest(task: task) {
            completed in

            if !completed {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Complete Task", message: "Failed to complete the task", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }

            if let row = self.tasks.firstIndex(where: { $0.id == task.id } ) {
                self.tasks.remove(at: row)
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    NotificationCenter.default.post(name: TaskListViewController.listUpdateNotification, object: self)
                }
            }
        }
    }

    @IBAction private func onTablePulledToRefresh(_ sender: Any) {
        refreshData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        cell.delegate = self

        let task = tasks[indexPath.row]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
        
        cell.name.text = task.name
        cell.endDate.text = task.endDate == nil ? nil : (dateFormatter.string(from: task.endDate!))

        if task.endDate != nil && task.endDate! <= Date() {
            cell.endDate.textColor = UIColor.red
        } else if task.endDateReminder != nil && task.endDateReminder! <= Date() {
            cell.endDate.textColor = UIColor.orange
        } else {
            cell.endDate.textColor = UIColor.black
        }
        
        let isRecording = (task.id == TimesheetController.shared.currentTaskId)
        cell.setRecording(isRecording)
        cell.recordingTimeLabel.text = TimesheetController.shared.formatTimeInterval(interval: TimesheetController.shared.timeRecording)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Complete") {
            _, _, completionHandler in

            completionHandler(false)

            var task = self.tasks[indexPath.row]
            task.status = "completed"
            self.completeTask(task: task)
        }
        completeAction.backgroundColor = UIColor(red: 0.12, green: 0.46, blue: 1, alpha: 1)

        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            _, _, completionHandler in

            completionHandler(false)

            let task = self.tasks[indexPath.row]
            self.deleteTask(id: task.id!)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func recordTapped(_ cell: TaskTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("Can't find a cell that was clicked")
            return
        }
        
        let task = tasks[indexPath.row]
//        print("Recording task id \(task.id!)")
        
        TimesheetController.shared.taskRecordingToggled(taskId: task.id!)
        
//        cell.setRecording(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)
        let task = tasks[indexPath!.row]

        let taskViewController = segue.destination as! TaskViewController
        taskViewController.id = task.id
        taskViewController.title = task.name
    }

    @IBAction private func unwindToTaskList(sender: UIStoryboardSegue) {
        refreshData()
    }
    
    private func handleTimesheetActionNotification(_ notification: Notification) {
        guard let data = notification.userInfo,
            let taskId = data[TimesheetController.timesheetTaskIdNotificationKey] as? Int,
            let action = data[TimesheetController.timesheetTaskActionNotificationKey] as? TimesheetController.TimesheetActionType else { return }
        
        switch action {
        case .stop:
            recordingTimer?.invalidate()
            recordingTimer = nil
        case .start:
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.updateRecordingTime()
            }
        }
        
        guard let row = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
        
        let isRecording = (action == .start)
        cell.setRecording(isRecording)
        cell.recordingTimeLabel.text = TimesheetController.shared.formatTimeInterval(interval: TimesheetController.shared.timeRecording)
    }
    
    private func updateRecordingTime() {
        guard let taskId = TimesheetController.shared.currentTaskId else { return }
        
        guard let row = self.tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TaskTableViewCell else { return }
        
        cell.recordingTimeLabel.text = TimesheetController.shared.formatTimeInterval(interval: TimesheetController.shared.timeRecording)
    }
}
