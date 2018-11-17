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
    static let timesheetTaskIdNotificationKey = "taskId"
    static let timesheetTaskActionNotificationKey = "action"
    enum TimesheetActionType {
        case start, stop
    }
    
    private(set) var currentTaskId: Int?
    private var currentTaskRecordingStartTime: Date?
    
    var timeRecording: TimeInterval? {
        if let start = currentTaskRecordingStartTime {
            return Date().timeIntervalSince(start)
        } else {
            return nil
        }
    }
    
    private init() {
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
            return "\(hours)h \(minutes)"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    func taskRecordingToggled(taskId: Int) {
        if currentTaskId == taskId {
            let taskId = currentTaskId
            currentTaskId = nil
            currentTaskRecordingStartTime = nil
            sendNotification(taskId: taskId!, action: .stop)
        } else {
            if currentTaskId != nil {
                let taskId = currentTaskId
                currentTaskId = nil
                currentTaskRecordingStartTime = nil
                sendNotification(taskId: taskId!, action: .stop)
            }
            
            currentTaskId = taskId
            currentTaskRecordingStartTime = Date()
            sendNotification(taskId: currentTaskId!, action: .start)
        }
    }
    
    private func sendNotification(taskId: Int, action: TimesheetActionType) {
        
        let data: [String : Any] = [TimesheetController.timesheetTaskIdNotificationKey: taskId,
                                    TimesheetController.timesheetTaskActionNotificationKey: action]
        
        let notification = Notification(name: TimesheetController.timesheetTaskActionNotificationName,
                                        object: self,
                                        userInfo: data)
        
        NotificationCenter.default.post(notification)
    }
}
