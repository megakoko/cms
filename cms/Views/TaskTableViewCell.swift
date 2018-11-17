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
    
    var delegate: TaskTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setRecording(false)
    }
    
    func setRecording(_ recording: Bool) {
        recordButton.setImage(UIImage(named: recording ? "Stop" : "Start"), for: .normal)
    }

    @IBAction func recordClicked(_ sender: Any) {
        delegate?.recordTapped(self)
    }
}
