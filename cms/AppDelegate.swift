//
//  AppDelegate.swift
//  cms
//
//  Created by Andy on 09/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var taskNotificationController: TaskNotificationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (_,_) in }
            application.registerForRemoteNotifications()
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }

        taskNotificationController = TaskNotificationController()

        application.setMinimumBackgroundFetchInterval(TaskNotificationController.refreshInterval)

        NotificationCenter.default.addObserver(forName: TaskNotificationController.numberOfDueTasksNotification,
                                               object: nil,
                                               queue: nil)
        {
            notification in

            guard let numberOfTasks = notification.userInfo?[TaskNotificationController.numberOfDueTasksKey] as? Int else { return }

            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = numberOfTasks
            }
        }

        UIApplication.shared.delegate?.window??.tintColor = UIColor(red: 1.00, green: 0.00, blue: 0.40, alpha: 0.84)

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        taskNotificationController?.refreshData(with: completionHandler)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        taskNotificationController?.stopRefreshing()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        taskNotificationController?.startRefreshing()
    }
}
