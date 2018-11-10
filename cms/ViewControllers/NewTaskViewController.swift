//
//  TaskViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewTaskViewController: UITableViewController {
    var id: Int? = nil

    var task: Task? = nil

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var endDateEnabled: UISwitch!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateEnabled: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var assigneeField: UITextField!
    @IBOutlet weak var clientNameField: UITextField!
    @IBOutlet weak var clientNameCell: UITableViewCell!
    @IBOutlet weak var workDescriptionField: UITextField!
    @IBOutlet weak var clientNameTapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        onEndDateToggled(endDatePicker)
        onStartDateToggled(startDatePicker)

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
        assigneeField.text = task?.assignee
        clientNameField.text = task?.clientName
        clientNameCell.accessoryType = task?.clientId == nil ? .none : .disclosureIndicator
        workDescriptionField.text = task?.workDescription

//        if task?.clientId == nil {
//            clientNameTapGestureRecognizer.isEnabled = false
//        }
    }

    struct Test : Codable {
        var id: Int?
        var name: String?
        var t: Int?
    }

    @IBAction func done(_ sender: Any) {
        task = Task(id: nil,
                    name: nameField.text ?? "",
                    endDate: endDateEnabled.isOn ? endDatePicker.date : nil,
                    endDateReminder: nil,
                    startDate: startDateEnabled.isOn ? startDatePicker.date : nil,
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

    @IBAction func onEndDateToggled(_ sender: Any) {
        endDatePicker.isEnabled = endDateEnabled.isOn
    }

    @IBAction func onStartDateToggled(_ sender: Any) {
        startDatePicker.isEnabled = startDateEnabled.isOn
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
}
