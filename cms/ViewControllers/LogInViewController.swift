//
//  LogInViewController.swift
//  cms
//
//  Created by Andrey on 16/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit
import LocalAuthentication

class LogInViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordRetrievalButton: UIButton!

    private let userNameKey = "userName"

    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        let ctx = LAContext()

        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch ctx.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return .touchID
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userName = UserDefaults.standard.string(forKey: userNameKey) {
            userNameField.text = userName
        }

        switch biometricType {
        case .none:
            passwordRetrievalButton.isHidden = true
        case .touchID:
            passwordRetrievalButton.setImage(UIImage(named: "TouchId"), for: .normal)
            passwordRetrievalButton.setTitle(nil, for: .normal)
        case .faceID:
            passwordRetrievalButton.setImage(UIImage(named: "FaceId"), for: .normal)
            passwordRetrievalButton.setTitle(nil, for: .normal)
        }

        onCredentialsChanged()
    }

    @IBAction func onCredentialsChanged() {
        let userName = userNameField.text ?? ""
        let password = passwordField.text ?? ""
        let validCredentials = !userName.isEmpty && !password.isEmpty
        loginButton.isEnabled = validCredentials

        let hasPasswordInKeychain = LoginController.password(for: userName) != nil
        passwordRetrievalButton.isEnabled = hasPasswordInKeychain
    }

    @IBAction func retrievePassword(_ sender: Any) {
        guard let userName = userNameField.text else { return }

        var biometricReason: String
        switch biometricType {
        case .touchID:
            biometricReason = "Use Touch ID to retrieve password from Keychain"
        case .faceID:
            biometricReason = "Use Face ID to retrieve password from Keychain"
        case .none:
            return
        }

        let ctx = LAContext()
        var authError: NSError?
        guard #available(iOS 8.0, *) else { return }

        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            print("Failed to evaluate auth biometric policy: \(authError?.localizedDescription ?? "")")
            return
        }

        ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: biometricReason) { success, evaluateError in
            guard success else {
                print("Failed to authenticate with biometrics")
                return
            }

            guard let password = LoginController.password(for: userName) else {
                return
            }

            DispatchQueue.main.async {
                self.passwordField.text = password
                self.tryToLogIn(self)
            }
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
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Failed to log in", message: "Please check internet connection and user credentials", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
