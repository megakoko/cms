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
    
    private init() {
    }
    
    func taskRecordingToggled(taskId: Int) {
//        print("Before: \(currentTaskId)")
        
        if currentTaskId == taskId {
//            print("Stopping task \(currentTaskId)")
            sendNotification(taskId: currentTaskId!, action: .stop)
            
            currentTaskId = nil
        } else {
            if currentTaskId != nil {
                sendNotification(taskId: currentTaskId!, action: .stop)
            }
            
            currentTaskId = taskId
            
            sendNotification(taskId: currentTaskId!, action: .start)
        }
        
//        print("After: \(currentTaskId)")
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
