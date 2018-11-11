//
//  NewTaskViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewTaskViewController: UITableViewController, UserListViewControllerDelegate, ClientListViewControllerDelegate {
    private var task: Task? = nil

    private var selectedAssigneeId: Int?
    private let noAssigneeSelectionOption = "No Assignee"

    private var selectedClientId: Int?
    private let noClientSelectionOption = "No Client"

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var endDateEnabled: UISwitch!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateEnabled: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var assigneeLabel: UILabel!
    @IBOutlet weak var clientNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        assigneeLabel.text = noAssigneeSelectionOption
        clientNameLabel.text = noClientSelectionOption
        onEndDateToggled(endDatePicker)
        onStartDateToggled(startDatePicker)
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

    func didSelect(userId: Int?, userName: String?) {
        selectedAssigneeId = userId
        assigneeLabel.text = userName ?? noAssigneeSelectionOption
    }

    func didSelect(clientId: Int?, clientName: String?) {
        selectedClientId = clientId
        clientNameLabel.text = clientName ?? noClientSelectionOption
    }

    @IBAction private func done(_ sender: Any) {
        task = Task(id: nil,
                    name: nameField.text ?? "",
                    endDate: endDateEnabled.isOn ? endDatePicker.date : nil,
                    endDateReminder: nil,
                    startDate: startDateEnabled.isOn ? startDatePicker.date : nil,
                    clientName: nil,
                    clientId: selectedClientId,
                    clientType: nil,
                    assignee: nil,
                    assigneeId: selectedAssigneeId,
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

    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func onEndDateToggled(_ sender: Any) {
        endDatePicker.isEnabled = endDateEnabled.isOn
    }

    @IBAction private func onStartDateToggled(_ sender: Any) {
        startDatePicker.isEnabled = startDateEnabled.isOn
    }

    @IBAction private func chooseAssignee(_ sender: Any) {
        let userListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
        userListViewController.delegate = self
        userListViewController.emptySelectionOption = noAssigneeSelectionOption

        let userListNavigationController = UINavigationController(rootViewController: userListViewController)

        present(userListNavigationController, animated: true)
    }

    @IBAction private func chooseClient(_ sender: Any) {
        let clientListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientListViewController") as! ClientListViewController
        clientListViewController.delegate = self
        clientListViewController.emptySelectionOption = noClientSelectionOption

        let clientListNavigationController = UINavigationController(rootViewController: clientListViewController)

        present(clientListNavigationController, animated: true)
    }
}
