//
//  TaskModel.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class TaskModel {
    static let taskUpdatedNotification = Notification.Name("taskUpdatedNotification")

    struct Task : Decodable{
        let id: Int
        let name: String
        let endDate: Date?
        let endDateReminder: Date?
    }

    private(set) var tasks = [Task]() {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: TaskModel.taskUpdatedNotification, object: self)
            }
        }
    }

    private var taskListDataTask: URLSessionDataTask?

    func clear() {
        tasks.removeAll()
        if taskListDataTask != nil {
            taskListDataTask!.cancel()
            taskListDataTask = nil
        }
    }

    func refresh() {
        clear()

        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let url = URL(string: "\(host)/tasks?order=endDate.desc")
        
        taskListDataTask = URLSession.shared.dataTask(with: url!) {
            data, response, error in

            if error != nil {
                print("Failed to get list of tasks. \(error!))")
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let tasks = try? decoder.decode([Task].self, from: data!) {
                self.tasks = tasks
            }
        }

        taskListDataTask!.resume()
    }
}
