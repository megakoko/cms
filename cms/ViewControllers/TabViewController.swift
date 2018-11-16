//
//  TabViewController.swift
//  cms
//
//  Created by Andy on 14/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: TaskNotificationController.numberOfDueTasksNotification, object: nil, queue: nil) {
            notification in
            guard let numberOfTasks = notification.userInfo?[TaskNotificationController.numberOfDueTasksKey] as? Int else { return }

            DispatchQueue.main.async {
                let taskListViewControllerIndex = 0
                if let taskListController = self.tabBar.items?[taskListViewControllerIndex] {
                    taskListController.badgeValue = numberOfTasks > 0 ? String(numberOfTasks) : nil
                }
            }
        }
    }
}
