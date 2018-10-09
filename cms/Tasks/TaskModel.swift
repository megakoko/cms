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

    struct Task {
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

        let url = URL(string: "\(host)/tasks")
        let urlRequest = URLRequest(url: url!)
        //let task = URLSession.shared.dataTask(with: url!) {
        taskListDataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get list of tasks. \(error!))")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                    for taskObject in json {
                        guard let id = taskObject["id"] as? Int else {
                            print("Failed to get id")
                            continue
                        }
                        guard let name = taskObject["title"] as? String else {
                            print("Failed to get name")
                            continue
                        }
                        guard let endDateData = taskObject["enddate"] as? String else {
                            print("Failed to get end date")
                            continue
                        }
                        guard let endDate = dateFormatter.date(from: endDateData) else {
                            print("Failed to parse end date");
                            continue
                        }


                        let task = Task(id: id,
                                        name: name,
                                        endDate: endDate)

                        self.tasks.append(task)
                    }

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: TaskModel.taskUpdatedNotification, object: self)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        taskListDataTask!.resume()
    }
}
