//
//  AssignedTasksController.swift
//  cms
//
//  Created by Andy on 14/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation
import UIKit

class TaskNotificationController {
    static let numberOfDueTasksNotification = Notification.Name("numberOfDueTasks")
    static let numberOfDueTasksKey = "numberOfDueTasks"

    static let refreshInterval = 60.0

    private var numberOfOverdueTasks = 0
    private var dataTask: URLSessionDataTask? = nil
    private var refreshTimer: Timer? = nil

    init() {
        NotificationCenter.default.addObserver(forName: TaskListViewController.listUpdateNotification, object: nil, queue: nil) {
            notification in
            self.stopRefreshing()
            self.startRefreshing()
        }
    }

    func refreshData(with completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        if dataTask != nil {
            dataTask?.cancel()
            dataTask = nil
        }

        guard let userId = LoginController.currentUserId else {
            print("Failed to get task notifications: no user is logged in")
            return
        }

        dataTask = NetworkManager.request(.taskNotification(userId: userId)) {
            response in

            self.dataTask = nil

            if let error = response?.error {
                print("Failed to get task reminders: \(error)")
                completionHandler?(.failed)
            } else {
                struct TasksWithReminder: Decodable {
                    let tasksWithReminder: Int
                }

                guard let data = response?.parsed(TasksWithReminder.self) else {
                    print("Failed to parse task reminder count")
                    completionHandler?(.failed)
                    return
                }

                if self.numberOfOverdueTasks != data.tasksWithReminder {
                    self.numberOfOverdueTasks = data.tasksWithReminder
                    completionHandler?(.newData)
                    NotificationCenter.default.post(name: TaskNotificationController.numberOfDueTasksNotification,
                                                    object: self,
                                                    userInfo: [TaskNotificationController.numberOfDueTasksKey: self.numberOfOverdueTasks])
                }
            }
        }
    }

    func startRefreshing() {
        refreshData()
        scheduleRefreshTimer()
    }

    func stopRefreshing() {
        dataTask?.cancel()
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func scheduleRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(timeInterval: TaskNotificationController.refreshInterval,
                                            target:self,
                                            selector: #selector(self.onRefreshTimerFired),
                                            userInfo: nil,
                                            repeats: false)
    }

    @objc private func onRefreshTimerFired() {
        refreshData()
        scheduleRefreshTimer()
    }
}
