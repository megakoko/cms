//
//  Request.swift
//  cms
//
//  Created by Andy on 14/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

enum Request {
    case tasks
    case task(id: Int)
    case newTask(Task)
    case updateTask(Task)
    case deleteTask(id: Int)
    case timesheetEntries(TimesheetEntry.DateRangeOption)
    case currentTimesheetEntry
    case newTimesheetEntry(TimesheetEntry)
    case updateTimesheetEntry(TimesheetEntry)
    case clients(filter: String?)
    case client(id: Int)
    case newClient(Client)
    case relationships(clientId: Int)
    case attachments(clientId: Int)
    case attachment(id: Int)
    case users
    case avatars
    case taskNotification(userId: Int)
}

extension Request {
    private var path: String {
        switch self {
        case .tasks:
            return "/tasks"
        case .task, .newTask, .updateTask, .deleteTask:
            return "/task"
        case .timesheetEntries, .currentTimesheetEntry, .newTimesheetEntry, .updateTimesheetEntry:
            return "/timesheet"
        case .clients:
            return "/clients"
        case .client, .newClient:
            return "/client"
        case .relationships:
            return "/clientrelationship"
        case .attachments, .attachment:
            return "/clientattachment"
        case .users:
            return "/users"
        case .avatars:
            return "/avatars"
        case .taskNotification:
            return "/taskreminders"
        }
    }

    private var parameters: RequestParameters {
        switch self {
        case .tasks:
            return .url(["assigneeId": "eq.\(LoginController.currentUserId ?? 0)",
                         "status": "neq.completed",
                         "order": "endDate.desc"])
        case .task(let id):
            return .url(["id": "eq.\(id)"])
        case .newTask(let task):
            return .body(encode(task))
        case .updateTask(let task):
            return .body(encode(task))
        case .deleteTask(let id):
            return .url(["id": "eq.\(id)"])
        case .timesheetEntries(let rangeOption):
            let startOf = { date in Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date) }
            let endOf = { date in Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) }

            var start: Date?
            var end: Date?
            switch rangeOption {
            case .day:
                start = startOf(Date())
                end = endOf(Date())
            case .week:
                if let today = startOf(Date()) {
                    start = Calendar.current.date(byAdding: .day, value: -7, to: today)
                }
                end = endOf(Date())
            case .month:
                if let today = startOf(Date()) {
                    start = Calendar.current.date(byAdding: .month, value: -1, to: today)
                }
                end = endOf(Date())
            case .custom(let customStart, let customEnd):
                start = startOf(customStart)
                end = endOf(customEnd)
            }

            guard start != nil && end != nil else {
                print("Invalid dates for timesheet filter")
                return .url([:])
            }

            let dateFormatter = ISO8601DateFormatter()

            let startString = dateFormatter.string(from: start!)
            let endString = dateFormatter.string(from: end!)

            return .url(["userId": "eq.\(LoginController.currentUserId ?? 0)",
                         "start": "lt.\(endString)",
                         "or": "(end.is.null,end.gt.\(startString))",
                         "order": "start.desc"])
        case .currentTimesheetEntry:
            return .url(["userId": "eq.\(LoginController.currentUserId ?? 0)",
                         "end": "is.null"])
        case .newTimesheetEntry(let entry):
            return .body(encode(entry))
        case .updateTimesheetEntry(let entry):
            return .body(encode(entry))
        case .clients(let filter):
            if let filter = filter, !filter.isEmpty {
                return .url(["or": "(name.ilike.*\(filter)*,code.ilike.*\(filter)*)",
                             "order": "name.asc"])
            } else {
                return .url(["order": "id.desc"])
            }
        case .client(let id):
            return .url(["id": "eq.\(id)"])
        case .newClient(let client):
            return .body(encode(client))
        case .relationships(let clientId):
            return .url(["clientId": "eq.\(clientId)"])
        case .attachments(let clientId):
            return .url(["clientId": "eq.\(clientId)",
                         "select": "id,fileName,fileSize"])
        case .attachment(let id):
            return .url(["id": "eq.\(id)"])
        case .users:
            return .url([:])
        case .avatars:
            return .url([:])
        case .taskNotification(let userId):
            return .url(["assigneeId": "eq.\(userId)",
                         "select": "tasksWithReminder"])
        }
    }

    private var method: HttpMethod {
        switch self {
        case .tasks, .task, .timesheetEntries, .currentTimesheetEntry, .clients,
             .client, .relationships, .attachments, .attachment, .users, .avatars, .taskNotification:
            return .get
        case .newTask, .newClient, .newTimesheetEntry:
            return .post
        case .updateTask, .updateTimesheetEntry:
            return .patch
        case .deleteTask:
            return .delete
        }
    }

    private var singleEntity: Bool {
        switch self {
        case .task, .newTimesheetEntry, .updateTimesheetEntry, .client, .attachment, .taskNotification:
            return true
        case .tasks, .deleteTask, .updateTask, .newTask, .timesheetEntries, .currentTimesheetEntry,
             .clients, .newClient, .relationships, .attachments, .users, .avatars:
            return false
        }
    }
}

// Helper methods and types
extension Request {
    var urlRequest: URLRequest? {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""

        guard var urlComponents = URLComponents(string: "\(host)\(path)") else {
            return nil
        }

        let parameters = self.parameters
        switch parameters {
        case .url(let queryItems):
            urlComponents.queryItems = queryItems.map{ URLQueryItem(name: $0, value: $1) }
        case .body:
            break
        }

        guard let url = urlComponents.url else {
            return nil
        }

        var result = URLRequest(url: url)

        result.httpMethod = method.rawValue
        if singleEntity {
            result.setValue("application/vnd.pgrst.object+json", forHTTPHeaderField: "Accept")
            if method == .post {
                result.setValue("return=representation", forHTTPHeaderField: "Prefer")
            }
        }

        switch parameters {
        case .url: break
        case .body(let data):
            result.httpBody = data
            result.setValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        }

        return result
    }

    private enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    private enum RequestParameters {
        case url([String:String])
        case body(Data?)
    }

    private func encode<T: Encodable>(_ encodable: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        return try? encoder.encode(encodable)
    }
}
