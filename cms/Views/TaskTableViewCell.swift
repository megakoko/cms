//
//  TaskTableViewCell.swift
//  cms
//
//  Created by Andrey on 17/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordButtonShadow: UIView!

    var delegate: TaskTableViewCellDelegate?
    let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()

        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"

        recordButtonShadow.alpha = 0.0
        recordButtonShadow.clipsToBounds = true
        recordButtonShadow.layer.cornerRadius = recordButtonShadow.frame.width / 2

        setRecording(false)
    }
    
    func setRecording(_ recording: Bool) {
        recordButton.setImage(UIImage(named: recording ? "Stop" : "Start"), for: .normal)
    }

    func setTask(_ task: Task) {
        name.text = task.name
        endDate.text = task.endDate == nil ? nil : (dateFormatter.string(from: task.endDate!))

        if task.endDate != nil && task.endDate! <= Date() {
            endDate.textColor = UIColor.red
        } else if task.endDateReminder != nil && task.endDateReminder! <= Date() {
            endDate.textColor = UIColor.orange
        } else {
            endDate.textColor = UIColor.black
        }

        let isRecording = (task.id == TimesheetController.shared.currentTimesheetEntry?.taskId)
        setRecording(isRecording)
        recordingTimeLabel.text = isRecording ? TimesheetController.shared.formatTimeInterval(interval: TimesheetController.shared.timeRecording) : nil
    }

    @IBAction func recordTouchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.recordButtonShadow.alpha = 0.5
        }
    }

    @IBAction func touchedUp(_ sender: Any) {
        delegate?.recordTapped(self)
        UIView.animate(withDuration: 0.3) {
            self.recordButtonShadow.alpha = 0.0
        }
    }

    @IBAction func touchCancel(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.recordButtonShadow.alpha = 0.0
        }
    }
}
