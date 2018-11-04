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
    }

    func refreshData(with completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        if dataTask != nil {
            dataTask?.cancel()
            dataTask = nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
        let now = dateFormatter.string(from: Date())

        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/tasks?assigneeId=eq.\(userId)&endDateReminder=lte.\(now)")!

        dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in

            if error != nil {
                print("Failed to get overdue tasks")
                if let completionHandler = completionHandler {
                    completionHandler(.failed)
                }
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let tasksWithReminders = try? decoder.decode([Task].self, from: data!) else { return }

            if self.numberOfOverdueTasks == tasksWithReminders.count {
                return
            }

            self.numberOfOverdueTasks = tasksWithReminders.count

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

        refreshTimer = Timer.scheduledTimer(timeInterval: TaskNotificationController.refreshInterval,
                                            target:self,
                                            selector: #selector(self.onRefreshTimerFired),
                                            userInfo: nil,
                                            repeats: false)
    }

    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @objc private func onRefreshTimerFired() {
        refreshData()
    }
}
