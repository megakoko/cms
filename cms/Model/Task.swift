//
//  Task.swift
//  cms
//
//  Created by Andy on 13/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct Task : Codable {
    var id: Int?
    var name: String
    var endDate: Date?
    var endDateReminder: Date?
    var endDateReminderAmount: Int?
    var endDateReminderTimePeriod: String?
    var startDate: Date?
    var startDateReminder: Date?
    var startDateReminderAmount: Int?
    var startDateReminderTimePeriod: String?
    var clientName: String?
    var clientId: Int?
    var clientType: Client.ClientType?
    var assignee: String?
    var assigneeId: Int?
    var workDescription: String?
    var status: String?
}
