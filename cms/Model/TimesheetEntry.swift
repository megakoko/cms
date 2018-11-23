//
//  TimesheetEntry.swift
//  cms
//
//  Created by Andrey on 17/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

struct TimesheetEntry: Codable {
    enum DateRangeOption {
        case day, week, month, custom(Date, Date)
    }

    let id: Int?
    let userId: Int
    let taskId: Int
    let taskName: String?
    let taskType: String?
    let start: Date
    var end: Date?
}
