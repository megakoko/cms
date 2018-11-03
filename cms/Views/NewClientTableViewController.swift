//
//  NewClientTableViewController.swift
//  cms
//
//  Created by Andy on 03/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewClientTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveAndClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
