//
//  TimesheetTableViewController.swift
//  cms
//
//  Created by Andrey on 17/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TimesheetTableViewController: UITableViewController {
    private var timesheetEntries = [TimesheetEntry]()
    
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
        NetworkManager.request(Request.timesheetEntries) {
            response in
            
            if let error = response?.error {
                print("Failed to get timesheet entries: \(error)")
            } else {
                self.timesheetEntries = response?.parsed([TimesheetEntry].self) ?? [TimesheetEntry]()
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timesheetEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timesheetCell", for: indexPath)

        let timesheetEntry = timesheetEntries[indexPath.row]
        let interval = timesheetEntry.end?.timeIntervalSince(timesheetEntry.start)
        
        cell.textLabel?.text = timesheetEntry.taskName
        cell.detailTextLabel?.text = TimesheetController.shared.formatTimeInterval(interval: interval)

        return cell
    }
    
    private func handleTimesheetActionNotification(_ notification: Notification) {
        guard let data = notification.userInfo,
            let entry = data[TimesheetController.timesheetEntryNotificationKey] as? TimesheetEntry,
            let action = data[TimesheetController.timesheetTaskActionNotificationKey] as? TimesheetController.TimesheetActionType else { return }
        
        switch action {
        case .stop:
            recordingTimer?.invalidate()
            recordingTimer = nil
        case .start:
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.updateRecordingTime()
            }
            
            tableView.beginUpdates()
            timesheetEntries.insert(entry, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            tableView.endUpdates()
        }
        
        updateRecordingTime()
    }
    
    private func updateRecordingTime() {
        guard let id = TimesheetController.shared.currentTimesheetEntry?.id else { return }
        
        guard let row = timesheetEntries.firstIndex(where: { $0.id == id }) else { return }
        
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        cell.detailTextLabel?.text = TimesheetController.shared.formatTimeInterval(interval: TimesheetController.shared.timeRecording)
    }
}
