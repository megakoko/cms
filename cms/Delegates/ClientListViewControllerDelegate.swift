//
//  ClientListViewControllerDelegate.swift
//  cms
//
//  Created by Andy on 11/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation

protocol ClientListViewControllerDelegate {
    func didSelect(clientId: Int?, clientName: String?)
}
