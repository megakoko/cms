//
//  TimesheetTableViewCell.swift
//  cms
//
//  Created by Andrey on 18/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TimesheetTableViewCell: UITableViewCell {
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var recordingTime: UILabel!
    @IBOutlet weak var recordButton: UIButton!

    var delegate: TimesheetTableViewCellDelegate?

    private static var taskTypeColors: [String: UIColor] {
        var colors = [String: UIColor]()

        for blueType in ["meeting"] {
            colors[blueType] = UIColor(red: 0.70, green: 0.80, blue: 1.00, alpha: 1.0)
        }
        for cyanType in ["taxReturn", "vatReturn"] {
            colors[cyanType] = UIColor(red: 0.80, green: 0.91, blue: 0.94, alpha: 1.0)
        }
        for purpleType in ["annualAccounts"] {
            colors[purpleType] = UIColor(red: 0.96, green: 0.90, blue: 0.95, alpha: 1.0)
        }
        for orangeType in ["companyIncorporation"] {
            colors[orangeType] = UIColor(red: 1.00, green: 0.93, blue: 0.91, alpha: 1.0)
        }

        return colors
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setRecording(false)
    }

    func setRecording(_ recording: Bool) {
        recordButton.isHidden = !recording
    }

    @IBAction func recordClicked(_ sender: Any) {
        delegate?.recordTapped(self)
    }

    func configure(for entry: TimesheetEntry) {
        let interval = (entry.end ?? Date()).timeIntervalSince(entry.start)

        let startDate = entry.start

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        taskName.text = entry.taskName
        recordingTime.text = TimesheetController.shared.formatTimeInterval(interval: interval) + " ‒ since " + dateFormatter.string(from: startDate)
        setRecording(entry.id == TimesheetController.shared.currentTimesheetEntry?.id)

        backgroundColor = TimesheetTableViewCell.taskTypeColors[entry.taskType ?? ""]
    }
}
