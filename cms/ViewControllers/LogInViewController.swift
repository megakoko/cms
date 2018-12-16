//
//  LogInViewController.swift
//  cms
//
//  Created by Andrey on 16/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tryToLogIn(_ sender: Any) {
        performSegue(withIdentifier: "loggedInSegue", sender: self)
    }
}
