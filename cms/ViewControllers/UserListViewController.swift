//
//  UserListViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController {
    var emptySelectionOption: String? = nil

    private var users = [User] ()
    private var coreDataTask: URLSessionDataTask? = nil
    private var avatarDataTask: URLSessionDataTask? = nil

    private var avatars = [Int: UIImage]()

    var delegate: UserListViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        if delegate != nil {
            tableView.allowsSelection = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAssigneeSelection))
        }

        reloadUsers()
    }

    @IBAction private func onTablePulledToRefresh(_ sender: Any) {
        reloadUsers()
    }

    private func reloadUsers() {
        if coreDataTask != nil {
            coreDataTask?.cancel()
            coreDataTask = nil
        }

        NetworkManager.request(.users) {
            response in

            self.coreDataTask = nil

            if let error = response?.error {
                print("Failed to get users: \(error)")
            } else {
                self.users = response?.parsed([User].self) ?? [User]()

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }

        if avatarDataTask != nil {
            avatarDataTask?.cancel()
            avatarDataTask = nil
        }

        NetworkManager.request(.avatars) {
            response in

            self.avatarDataTask = nil

            if let error = response?.error {
                print("Failed to get avatars: \(error)")
            } else {
                struct AvatarData : Decodable {
                    let userId: Int
                    let avatar: String
                }

                var avatars = [Int: UIImage]()
                if let avatarDataList = response?.parsed([AvatarData].self) {
                    for avatarData in avatarDataList {
                        let base64string = avatarData.avatar.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil);
                        if let base64 = Data(base64Encoded: base64string) {
                            let img = UIImage(data: base64)
                            avatars[avatarData.userId] = img
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.avatars = avatars
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (emptySelectionOption != nil ? 1 : 0) + users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)

        if emptySelectionOption != nil && indexPath.row == 0 {
            cell.textLabel?.text = emptySelectionOption
            cell.detailTextLabel?.text = nil
        } else {
            let user = users[indexPath.row - (emptySelectionOption != nil ? 1 : 0)]
            cell.textLabel?.text = (user.id == LoginController.currentUserId) ? "Me (\(user.fullName))" : user.fullName
            cell.imageView?.image = avatars[user.id]
            cell.detailTextLabel?.text = user.loggedIn ? "logged in" : ""
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            var userId: Int? = nil
            var userName: String? = nil

            if indexPath.row != 0 {
                let user = users[indexPath.row-1]
                userId = user.id
                userName = user.fullName
            }

            delegate!.didSelect(userId: userId, userName: userName)

            dismiss(animated: true)
        }
    }

    @IBAction private func cancelAssigneeSelection() {
        dismiss(animated: true)
    }

    @IBAction func logOut(_ sender: Any) {
        LoginController.logOut()
        performSegue(withIdentifier: "loggedOutSegue", sender: self)
    }
}
