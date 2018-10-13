//
//  UserListViewController.swift
//  cms
//
//  Created by Andy on 12/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class UserListViewController: UITableViewController {
    var users = [User] ()

    var avatars = [Int: UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadUsers()
    }

    @IBAction func onTablePulledToRefresh(_ sender: Any) {
        reloadUsers()
    }

    func reloadUsers() {
        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let coreRequest = URLRequest(url: URL(string: "\(host)/users")!)
        let coreDataTask = URLSession.shared.dataTask(with: coreRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get users: \(error!)")
                return
            }

            if let users = try? JSONDecoder().decode([User].self, from: data!) {
                self.users = users
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
        coreDataTask.resume()

        let avatarRequest = URLRequest(url: URL(string: "\(host)/avatars")!)
        let avatarDataTask = URLSession.shared.dataTask(with: avatarRequest) {
            data, response, error in

            if error != nil {
                print("Failed to get avatars: \(error!)")
                return
            }

            struct AvatarData : Decodable {
                let userId: Int
                let avatar: String
            }

            
            var avatars = [Int: UIImage]()
            if let avatarDataList = try? JSONDecoder().decode([AvatarData].self, from: data!) {
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
        avatarDataTask.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)

        let user = users[indexPath.row]
        cell.textLabel?.text = user.fullName
        cell.imageView?.image = avatars[user.id]
        cell.detailTextLabel?.text = user.loggedIn ? "logged in" : ""

        return cell
    }
}