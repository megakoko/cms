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
        let endDate: Date
    }

    private(set) var tasks = [Task]()

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
        let urlRequest = URLRequest(url: url!)
        //let task = URLSession.shared.dataTask(with: url!) {
        taskListDataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get list of tasks. \(error!))")
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                guard let string = try? decoder.singleValueContainer().decode(String.self) else {
                    return Date()
                }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                return dateFormatter.date(from: string) ?? Date()
            })

            if let tasks = try? decoder.decode([Task].self, from: data!) {
                self.tasks = tasks
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: TaskModel.taskUpdatedNotification, object: self)
            }
        }

        taskListDataTask!.resume()
    }
}
