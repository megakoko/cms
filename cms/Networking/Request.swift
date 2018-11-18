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
    case timesheetEntries
    case currentTimesheetEntry
    case newTimesheetEntry(TimesheetEntry)
    case updateTimesheetEntry(TimesheetEntry)
    case clients
    case client(id: Int)
    case newClient(Client)
    case relationships(clientId: Int)
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
            return .url(["assigneeId": "eq.1",
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
        case .timesheetEntries:
            return .url(["userId": "eq.1",
                         "order": "start.desc"])
        case .currentTimesheetEntry:
            return .url(["userId": "eq.1",
                         "end": "is.null"])
        case .newTimesheetEntry(let entry):
            return .body(encode(entry))
        case .updateTimesheetEntry(let entry):
            return .body(encode(entry))
        case .clients:
            return .url(["order": "id.desc"])
        case .client(let id):
            return .url(["id": "eq.\(id)"])
        case .newClient(let client):
            return .body(encode(client))
        case .relationships(let clientId):
            return .url(["clientId": "eq.\(clientId)"])
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
        case .tasks, .task, .timesheetEntries, .currentTimesheetEntry, .clients, .client, .relationships, .users, .avatars, .taskNotification:
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
        case .task, .newTimesheetEntry, .updateTimesheetEntry, .client, .taskNotification:
            return true
        case .tasks, .deleteTask, .updateTask, .newTask, .timesheetEntries, .currentTimesheetEntry, .clients, .newClient, .relationships, .users, .avatars:
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
