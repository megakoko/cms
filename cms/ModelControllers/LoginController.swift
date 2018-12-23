//
//  LoginController.swift
//  cms
//
//  Created by Andrey on 09/12/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

class LoginController {
    static private(set) var currentUserId: Int? = 1

    private init() {
        
    }

    class func tryToLogIn(userName: String, password: String, handler: @escaping (Bool) -> (Void)) {
        NetworkManager.request(.logIn(userName: userName, password: password)) {
            response in

            if let error = response?.error {
                print("Failed to log in:", error)
                handler(false)
            } else if let data = response?.parsed(LoginData.self),
                      let userId = data.userId {
                LoginController.currentUserId = userId
                handler(true)
            } else {
                print("Failed to log in, error in parsing data")
                handler(false)
            }
        }
    }

    class func logOut() {
        guard let userId = currentUserId else { return }
        NetworkManager.request(.logOut(userId: userId)) {
            response in

            if let error = response?.error {
                print("Failed to log out from the DB: \(error)")
            }
        }
        currentUserId = nil
    }

    class func savePassword(_ password: String, for userName: String) {
        let passwordData = password.data(using: String.Encoding.utf8)!
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: userName]
        SecItemDelete(query as CFDictionary)

        query[kSecValueData as String] = passwordData
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return print("save error") }
    }

    class func password(for userName: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: userName,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue]


        var retrivedData: AnyObject? = nil
        let _ = SecItemCopyMatching(query as CFDictionary, &retrivedData)


        guard let data = retrivedData as? Data else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
