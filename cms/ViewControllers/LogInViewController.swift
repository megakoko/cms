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

    private let userNameKey = "userName"

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userName = UserDefaults.standard.string(forKey: userNameKey) {
            userNameField.text = userName
            passwordField.text = LoginController.password(for: userName)
        }
    }
    
    @IBAction func tryToLogIn(_ sender: Any) {
        guard let userName = userNameField.text,
            let password = passwordField.text else {

            return
        }

        LoginController.tryToLogIn(userName: userName, password: password) {
            ok in

            if ok {
                UserDefaults.standard.set(userName, forKey: self.userNameKey)
                LoginController.savePassword(password, for: userName)

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
