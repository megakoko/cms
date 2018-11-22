//
//  TimesheetFilterViewController.swift
//  cms
//
//  Created by Andrey on 20/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TimesheetFilterViewController: UITableViewController {
    @IBOutlet weak var dateRangeOptionsControl: UISegmentedControl!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!

    var delegate: TimesheetFilterTableViewControllerDelegate?

    var rangeOption: TimesheetEntry.DateRangeOption = .week

    override func viewDidLoad() {
        super.viewDidLoad()

        addDateRangeOptions()
        onDateRangeOptionChanged(dateRangeOptionsControl)
    }

    private func addDateRangeOptions() {
        dateRangeOptionsControl.removeAllSegments()

        for option in TimesheetEntry.DateRangeOption.allCases {
            var description: String
            switch option {
            case .day:      description = "Day"
            case .week:     description = "Week"
            case .month:    description = "Month"
            case .custom:   description = "Custom"
            }

            let index = dateRangeOptionsControl.numberOfSegments
            dateRangeOptionsControl.insertSegment(withTitle: description, at: index, animated: false)
        }

        dateRangeOptionsControl.selectedSegmentIndex = TimesheetEntry.DateRangeOption.allCases.firstIndex(of: rangeOption)!
    }

    @IBAction func onDateRangeOptionChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let option = TimesheetEntry.DateRangeOption.allCases[index]

        var startDate: Date? = startDatePicker.date
        var endDate: Date? = endDatePicker.date
        var isCustom = false

        switch option {
        case .day:
            startDate = Date()
            endDate = Date()
        case .week:
            endDate = Date()
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .month:
            endDate = Date()
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case .custom:
            isCustom = true
        }

        guard startDate != nil && endDate != nil else { return }

        startDatePicker.date = startDate!
        startDatePicker.isEnabled = isCustom
        endDatePicker.date = endDate!
        endDatePicker.isEnabled = isCustom
    }

    @IBAction func done(_ sender: Any) {
        let rangeIndex = dateRangeOptionsControl.selectedSegmentIndex
        rangeOption = TimesheetEntry.DateRangeOption.allCases[rangeIndex]
        delegate?.didSelectOptions(controller: self)
        dismiss(animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}
