//
//  TimesheetController.swift
//  cms
//
//  Created by Andrey on 17/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class TimesheetController {
    static var shared = TimesheetController()

    static let timesheetTaskActionNotificationName = Notification.Name("timesheetTaskAction")
    static let timesheetEntryNotificationKey = "entry"
    static let timesheetTaskActionNotificationKey = "action"
    enum TimesheetActionType {
        case start, stop
    }
    
    private(set) var currentTimesheetEntry: TimesheetEntry?
    
    var timeRecording: TimeInterval? {
        if let start = currentTimesheetEntry?.start {
            return Date().timeIntervalSince(start)
        } else {
            return nil
        }
    }
    
    private init() {
        NetworkManager.request(Request.currentTimesheetEntry) {
            response in
            
            if let error = response?.error {
                print("Failed to get the currently recording timesheet entry: \(error)")
            } else {
                let currentTimesheetEntryList = response?.parsed([TimesheetEntry].self)
                self.currentTimesheetEntry = currentTimesheetEntryList?.first
                if self.currentTimesheetEntry != nil {
                    DispatchQueue.main.async {
                        self.sendNotification(entry: self.currentTimesheetEntry!, action: .start)
                    }
                }
            }
        }
    }
    
    func formatTimeInterval(interval: TimeInterval?) -> String {
        if interval == nil {
            return ""
        }
        
        var interval = Int(interval!)
        
        let seconds = interval % 60
        interval /= 60
        
        let minutes = interval % 60
        interval /= 60
        
        let hours = interval
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m \(seconds)s"
        }
    }
    
    func taskRecordingToggled(taskId: Int) {
        if currentTimesheetEntry?.taskId == taskId {
            var entry = currentTimesheetEntry
            entry?.end = Date()
            
            NetworkManager.request(Request.updateTimesheetEntry(entry!)) {
                response in
                
                if let error = response?.error {
                    print("Failed to stop recording: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.currentTimesheetEntry = nil
                        self.sendNotification(entry: entry!, action: .stop)
                    }
                }
            }
        } else {
            let oldEntry = currentTimesheetEntry
            let newEntry = TimesheetEntry(id: nil, userId: 1, taskId: taskId, taskName: nil, taskType: nil, start: Date(), end: nil)
            
            NetworkManager.request(Request.newTimesheetEntry(newEntry)) {
                response in
                
                if let error = response?.error {
                    print("Failed to make new timesheet entry: \(error)")
                } else {
                    guard let createdEntry = response?.parsed(TimesheetEntry.self) else { return }
                    
                    DispatchQueue.main.async {
                        self.currentTimesheetEntry = createdEntry
                        
                        if oldEntry != nil {
                            self.sendNotification(entry: oldEntry!, action: .stop)
                        }
                        
                        self.sendNotification(entry: self.currentTimesheetEntry!, action: .start)
                    }
                }
            }
        }
    }
    
    private func sendNotification(entry: TimesheetEntry, action: TimesheetActionType) {
        let data: [String : Any] = [TimesheetController.timesheetEntryNotificationKey: entry,
                                    TimesheetController.timesheetTaskActionNotificationKey: action]
        
        let notification = Notification(name: TimesheetController.timesheetTaskActionNotificationName,
                                        object: self,
                                        userInfo: data)
        
        NotificationCenter.default.post(notification)
    }
}
