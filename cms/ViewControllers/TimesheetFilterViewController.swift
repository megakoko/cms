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

        initDateRangeOption()
        onDateRangeOptionChanged(dateRangeOptionsControl)
    }

    private func initDateRangeOption() {
        switch rangeOption {
        case .day:
            dateRangeOptionsControl.selectedSegmentIndex = 0
        case .week:
            dateRangeOptionsControl.selectedSegmentIndex = 1
        case .month:
            dateRangeOptionsControl.selectedSegmentIndex = 2
        case .custom:
            dateRangeOptionsControl.selectedSegmentIndex = 3
        }
    }

    @IBAction func onDateRangeOptionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            rangeOption = .day
        case 1:
            rangeOption = .week
        case 2:
            rangeOption = .month
        case 3:
            rangeOption = .custom(startDatePicker.date, endDatePicker.date)
        default:
            assert(false, "Unhandled timesheet date range option")
        }

        var startDate: Date? = startDatePicker.date
        var endDate: Date? = endDatePicker.date
        var isCustom = false

        switch rangeOption {
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
        startDatePicker.maximumDate = isCustom ? endDate : nil
        endDatePicker.date = endDate!
        endDatePicker.isEnabled = isCustom
        endDatePicker.minimumDate = isCustom ? startDate : nil
    }

    @IBAction func onStartDateChanged(_ sender: UIDatePicker) {
        if case let .custom(_, end) = rangeOption {
            let start = sender.date
            rangeOption = .custom(start, end)
            endDatePicker.minimumDate = start
        }
    }

    @IBAction func onEndDateChanged(_ sender: UIDatePicker) {
        if case let .custom(start, _) = rangeOption {
            let end = sender.date
            rangeOption = .custom(start, end)
            startDatePicker.maximumDate = end
        }
    }

    @IBAction func done(_ sender: Any) {
        delegate?.didSelectOptions(controller: self)
        dismiss(animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}
