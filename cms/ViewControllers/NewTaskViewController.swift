//
//  NewTaskViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewTaskViewController: UITableViewController, UserListViewControllerDelegate, ClientListViewControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    private var task: Task? = nil

    private var selectedAssigneeId: Int?
    private let noAssigneeSelectionOption = "No Assignee"

    private var selectedClientId: Int?
    private let noClientSelectionOption = "No Client"

    private var reminderTimePeriods = ["minute","hour","day","week","month"]
    private var reminderTimePeriodDescription = ["Minute(s)","Hour(s)","Day(s)","Week(s)","Month(s)"]

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var endDateEnabled: UISwitch!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDateReminderEnabled: UISwitch!
    @IBOutlet weak var endDateReminderPicker: UIPickerView!
    @IBOutlet weak var startDateEnabled: UISwitch!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateReminderEnabled: UISwitch!
    @IBOutlet weak var startDateReminderPicker: UIPickerView!
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
        NetworkManager.request(.newTask(task!)) {
            response in

            if let error = response?.error {
                print("Failed to create a task: \(error)")
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }

    func didSelect(userId: Int?, userName: String?) {
        selectedAssigneeId = userId
        assigneeLabel.text = userName ?? noAssigneeSelectionOption
    }

    func didSelect(clientId: Int?, clientName: String?) {
        selectedClientId = clientId
        clientNameLabel.text = clientName ?? noClientSelectionOption
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            nameField.resignFirstResponder()
        default:
            return false
        }
        
        return true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 100
        case 1: return reminderTimePeriodDescription.count
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return String(row + 1)
        case 1: return reminderTimePeriodDescription[row]
        default: return nil
        }
    }

    @IBAction private func done(_ sender: Any) {
        let hasEndReminder = endDateReminderEnabled.isEnabled && endDateReminderEnabled.isOn
        let endReminderAmount = hasEndReminder ? (endDateReminderPicker.selectedRow(inComponent: 0) + 1) : nil
        let endReminderTimePeriod = hasEndReminder ? (reminderTimePeriods[endDateReminderPicker.selectedRow(inComponent: 1)]) : nil

        let hasStartReminder = startDateReminderEnabled.isEnabled && startDateReminderEnabled.isOn
        let startReminderAmount = hasStartReminder ? (startDateReminderPicker.selectedRow(inComponent: 0) + 1) : nil
        let startReminderTimePeriod = hasStartReminder ? (reminderTimePeriods[startDateReminderPicker.selectedRow(inComponent: 1)]) : nil

        task = Task(id: nil,
                    name: nameField.text ?? "",
                    endDate: endDateEnabled.isOn ? endDatePicker.date : nil,
                    endDateReminder: nil,
                    endDateReminderAmount: endReminderAmount,
                    endDateReminderTimePeriod: endReminderTimePeriod,
                    startDate: startDateEnabled.isOn ? startDatePicker.date : nil,
                    startDateReminder: nil,
                    startDateReminderAmount: startReminderAmount,
                    startDateReminderTimePeriod: startReminderTimePeriod,
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
        let enabled = endDateEnabled.isOn
        endDatePicker.isEnabled = enabled
        endDateReminderEnabled.isEnabled = enabled
        onEndReminderToggled(sender)
    }

    @IBAction func onEndReminderToggled(_ sender: Any) {
        let enabled = endDateReminderEnabled.isEnabled && endDateReminderEnabled.isOn
        endDateReminderPicker.isUserInteractionEnabled = enabled
        endDateReminderPicker.alpha = enabled ? 1.0 : 0.4
    }

    @IBAction private func onStartDateToggled(_ sender: Any) {
        let enabled = startDateEnabled.isOn
        startDatePicker.isEnabled = enabled
        startDateReminderEnabled.isEnabled = enabled
        onStartReminderToggled(sender)
    }

    @IBAction func onStartReminderToggled(_ sender: Any) {
        let enabled = startDateReminderEnabled.isEnabled && startDateReminderEnabled.isOn
        startDateReminderPicker.isUserInteractionEnabled = enabled
        startDateReminderPicker.alpha = enabled ? 1.0 : 0.4
    }

    @IBAction private func chooseAssignee(_ sender: Any) {
        let userListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserListViewController") as! UserListViewController
        userListViewController.delegate = self
        userListViewController.emptySelectionOption = noAssigneeSelectionOption

        let userListNavigationController = UINavigationController(rootViewController: userListViewController)
        userListViewController.title = "Choose Assignee"

        present(userListNavigationController, animated: true)
    }

    @IBAction private func chooseClient(_ sender: Any) {
        let clientListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientListViewController") as! ClientListViewController
        clientListViewController.delegate = self
        clientListViewController.emptySelectionOption = noClientSelectionOption

        let clientListNavigationController = UINavigationController(rootViewController: clientListViewController)
        clientListViewController.title = "Choose Associated Client"

        present(clientListNavigationController, animated: true)
    }
}
