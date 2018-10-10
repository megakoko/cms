//
//  ClientViewController.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation
import UIKit

class ClientViewController : UIViewController {
    private var model: ClientModel? = nil
    var id: Int? = nil

    @IBOutlet weak var utrLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        model = ClientModel()
        model?.load(id: id!)

        NotificationCenter.default.addObserver(forName: ClientModel.clientUpdateNotification,
                                               object: nil,
                                               queue: nil) {
            _ in
            self.reloadData()
        }
    }

    func reloadData() {
        utrLabel.text = model?.utr
    }
}
