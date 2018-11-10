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

    var task: Task? = nil

    private let statusCellSection = 1
    private let endDateFieldIndexPath = IndexPath(row: 0, section: 2)
    private let endDatePickerIndexPath = IndexPath(row: 1, section: 2)
    private let startDateFieldIndexPath = IndexPath(row: 0, section: 3)
    private let startDatePickerIndexPath = IndexPath(row: 1, section: 3)

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var statusField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var assigneeField: UITextField!
    @IBOutlet weak var clientNameField: UITextField!
    @IBOutlet weak var clientNameCell: UITableViewCell!
    @IBOutlet weak var workDescriptionField: UITextField!
    @IBOutlet weak var clientNameTapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUi()
        if id != nil {
            reloadData()
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }
    }

    func reloadData() {
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

    private func saveTask(completionHandler: @escaping (Bool) -> Void) {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/task")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(task!) else {
            completionHandler(false)
            return
        }

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to create new task: \(error!)")
                completionHandler(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    print("Failed to create new task, status code: \(httpResponse.statusCode)")
                    completionHandler(false)
                    return;
                }
            }

            completionHandler(true)
        }

        dataTask.resume();
    }

    private func updateUi() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy 'at' hh:mm"

        nameField.text = task?.name
        statusField.text = task?.status
        endDateField.text = task?.endDate != nil ? dateFormatter.string(from: (task?.endDate)!) : nil
        startDateField.text = task?.startDate != nil ? dateFormatter.string(from: (task?.startDate)!) : nil
        assigneeField.text = task?.assignee
        clientNameField.text = task?.clientName
        clientNameCell.accessoryType = task?.clientId == nil ? .none : .disclosureIndicator
        workDescriptionField.text = task?.workDescription

        if task?.clientId == nil {
            clientNameTapGestureRecognizer.isEnabled = false
        }
    }

    struct Test : Codable {
        var id: Int?
        var name: String?
        var t: Int?
    }

    @IBAction func done(_ sender: Any) {
        task = Task(id: nil,
                    name: nameField.text ?? "",
                    endDate: endDatePicker.date,
                    endDateReminder: nil,
                    startDate: startDatePicker.date,
                    clientName: nil,
                    clientId: nil,
                    clientType: nil,
                    assignee: nil,
                    workDescription: nil,
                    status: nil)

        saveTask() {
            saved in

            if !saved {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Save Task", message: "Failed to save the task", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToTaskList", sender: self)
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientSegue" {
            let clientViewController = segue.destination as! ClientViewController

            if let task = task {
                clientViewController.setClient(id: task.clientId!, type: task.clientType!)
                clientViewController.title = task.clientName
            }
        } else if segue.identifier == "unwindToTaskList" {

        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if id == nil && indexPath.section == statusCellSection {
            return 0
        }

        if (indexPath == endDateFieldIndexPath && id == nil) ||
            (indexPath == endDatePickerIndexPath && id != nil) {
            return 0
        }

        if (indexPath == startDateFieldIndexPath && id == nil) ||
            (indexPath == startDatePickerIndexPath && id != nil) {
            return 0
        }


        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if id == nil && section == statusCellSection {
            return 0
        }

        return super.tableView(tableView, heightForHeaderInSection: section)
    }
}
