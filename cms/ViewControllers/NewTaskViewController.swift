//
//  NewTaskViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewTaskViewController: UITableViewController, UserListViewControllerDelegate {
    var task: Task? = nil

    private var selectedAssigneeId: Int?
    private let noAssigneeSelectionOption = "No Assignee"

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var endDateEnabled: UISwitch!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateEnabled: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var assigneeLabel: UILabel!
    @IBOutlet weak var clientNameField: UITextField!
    @IBOutlet weak var clientNameCell: UITableViewCell!
    @IBOutlet weak var workDescriptionField: UITextField!
    @IBOutlet weak var clientNameTapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        assigneeLabel.text = noAssigneeSelectionOption
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

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onEndDateToggled(_ sender: Any) {
        endDatePicker.isEnabled = endDateEnabled.isOn
    }

    @IBAction func onStartDateToggled(_ sender: Any) {
        startDatePicker.isEnabled = startDateEnabled.isOn
    }

    @IBAction func chooseAssignee(_ sender: Any) {
        let userListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
        userListViewController.delegate = self
        userListViewController.emptySelectionOption = noAssigneeSelectionOption

        let userListNavigationController = UINavigationController(rootViewController: userListViewController)

        userListViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAssigneeSelection))
        userListViewController.navigationItem.leftBarButtonItem?.tintColor = view.tintColor

        present(userListNavigationController, animated: true)
    }

    @IBAction func cancelAssigneeSelection() {
        dismiss(animated: true)
    }
}
