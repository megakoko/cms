//
//  LogInViewController.swift
//  cms
//
//  Created by Andrey on 16/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tryToLogIn(_ sender: Any) {
        guard let userName = userNameField.text,
            let password = passwordField.text else {

            return
        }

        LoginController.tryToLogIn(userName: userName, password: password) {
            ok in

            if ok {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let tabViewController = storyboard.instantiateViewController(withIdentifier: "tabViewController")
                    UIApplication.shared.keyWindow?.rootViewController = tabViewController
                }
            } else {

            }
        }
    }
}
