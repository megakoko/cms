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
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setRecording(false)
    }
    
    func setRecording(_ recording: Bool) {
        recordButton.isHidden = !recording
    }
    
    @IBAction func recordClicked(_ sender: Any) {
        print("Tapped")
        delegate?.recordTapped(self)
    }
}
