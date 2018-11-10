//
//  UserListViewControllerDelegate.swift
//  cms
//
//  Created by Andy on 10/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

protocol UserListViewControllerDelegate {
    func didSelect(userId: Int, userName: String)
}
