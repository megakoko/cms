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
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tableView.refreshControl?.tintColor = UIApplication.shared.delegate?.window??.tintColor
        
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
}
