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

    private var userId: Int
    private var numberOfOverdueTasks = 0
    private var dataTask: URLSessionDataTask? = nil
    private var refreshTimer: Timer? = nil

    init(userId: Int) {
        self.userId = userId

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

        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/taskreminders?assigneeId=eq.\(userId)&select=tasksWithReminder")!

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")

        dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            self.dataTask = nil

            if error != nil {
                print("Failed to get overdue tasks")
                if let completionHandler = completionHandler {
                    completionHandler(.failed)
                }
                return
            }

            guard   let jsonResponse = try? JSONSerialization.jsonObject(with: data!, options: []),
                    let jsonObject = jsonResponse as? [String: Int],
                    let newCount = jsonObject["tasksWithReminder"] else {
                print("Failed to parse number of task reminders from response")
                return
            }

            if self.numberOfOverdueTasks == newCount  {
                return
            }

            self.numberOfOverdueTasks = newCount

            if let completionHandler = completionHandler {
                completionHandler(.newData)
            }
            
            NotificationCenter.default.post(name: TaskNotificationController.numberOfDueTasksNotification,
                                            object: self,
                                            userInfo: [TaskNotificationController.numberOfDueTasksKey: self.numberOfOverdueTasks])
        }
        dataTask!.resume()
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
