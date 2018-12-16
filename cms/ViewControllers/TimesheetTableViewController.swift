//
//  TimesheetTableViewController.swift
//  cms
//
//  Created by Andrey on 17/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TimesheetTableViewController: UITableViewController, TimesheetTableViewCellDelegate, TimesheetFilterTableViewControllerDelegate {
    private var timesheetEntries = [TimesheetEntry]()
    private var rangeOption = TimesheetEntry.DateRangeOption.week
    private var useColorCoding = false
    private var recordingTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tableView.refreshControl?.tintColor = UIApplication.shared.delegate?.window??.tintColor
        
        NotificationCenter.default.addObserver(forName: TimesheetController.timesheetTaskActionNotificationName, object: TimesheetController.shared, queue: nil) { notification in
            self.handleTimesheetActionNotification(notification)
        }
        
        refreshData()
    }
    
    @IBAction func refreshData() {
        NetworkManager.request(Request.timesheetEntries(rangeOption)) {
            response in
            
            if let error = response?.error {
                print("Failed to get timesheet entries: \(error)")
            } else {
                self.timesheetEntries = response?.parsed([TimesheetEntry].self) ?? [TimesheetEntry]()
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()

                    let recordingEntry = self.timesheetEntries.first(where: { $0.end == nil } )
                    if recordingEntry != nil {
                        self.handleTimesheetAction(entry: recordingEntry!, action: .start)
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timesheetEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timesheetCell", for: indexPath) as! TimesheetTableViewCell
        cell.delegate = self
        cell.configure(for: timesheetEntries[indexPath.row], usingColorCoding: useColorCoding)
        return cell
    }
    
    private func handleTimesheetActionNotification(_ notification: Notification) {
        guard let data = notification.userInfo,
            let entry = data[TimesheetController.timesheetEntryNotificationKey] as? TimesheetEntry,
            let action = data[TimesheetController.timesheetTaskActionNotificationKey] as? TimesheetController.TimesheetActionType else { return }
     
        handleTimesheetAction(entry: entry, action: action)
    }
    
    private func handleTimesheetAction(entry: TimesheetEntry, action: TimesheetController.TimesheetActionType) {
        switch action {
        case .stop:
            recordingTimer?.invalidate()
            recordingTimer = nil
            updateRecordingTime(for: entry)
        case .start:
            recordingTimer?.invalidate()
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.updateRecordingTime(for: entry)
            }
            
            if !timesheetEntries.contains(where: { $0.id == entry.id }) {
                tableView.beginUpdates()
                timesheetEntries.insert(entry, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                tableView.endUpdates()
            }
        }
        
        updateRecordingTime(for: entry)
    }
    
    private func updateRecordingTime(for entry: TimesheetEntry) {
        let id = entry.id
        guard let row = timesheetEntries.firstIndex(where: { $0.id == id }) else { return }
        let indexPath = IndexPath(row: row, section: 0)

        guard let cell = tableView.cellForRow(at: indexPath) as? TimesheetTableViewCell else {
            return
        }

        cell.configure(for: timesheetEntries[indexPath.row], usingColorCoding: useColorCoding)
    }
    
    func recordTapped(_ cell: TimesheetTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let timesheetEntry = timesheetEntries[indexPath.row]
        TimesheetController.shared.taskRecordingToggled(taskId: timesheetEntry.taskId)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timesheetFilterSegue" {
            guard let navigationController = segue.destination as? UINavigationController else {
                print("Failed to cast destination to navigation controller")
                return
            }

            guard let timesheetFilterController = navigationController.topViewController as? TimesheetFilterViewController else {
                print("Failed to cast destination to timesheet filter controller")
                return
            }

            timesheetFilterController.delegate = self
            timesheetFilterController.rangeOption = rangeOption
            timesheetFilterController.useColorCoding = useColorCoding
        }
    }

    func didSelectOptions(controller: TimesheetFilterViewController) {
        rangeOption = controller.rangeOption
        useColorCoding = controller.useColorCoding
        refreshData()
    }
}
