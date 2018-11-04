//
//  NewClientTableViewController.swift
//  cms
//
//  Created by Andy on 03/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit
import ContactsUI

class NewClientTableViewController: UITableViewController, CNContactPickerDelegate {
    @IBOutlet weak var clientTypeControl: UISegmentedControl!

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var middleNameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var entityNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var telephoneField: UITextField!

    private let clientTypes = [
        Client.ClientType.individual,
        Client.ClientType.limitedCompany,
        Client.ClientType.partnership,
        Client.ClientType.trust
    ]

    private var selectedIndividual = true

    private let clientTypeIndexPath = IndexPath(row: 0, section: 0)

    private let individualIndexPaths = [IndexPath(row: 1, section: 0),
                                        IndexPath(row: 2, section: 0),
                                        IndexPath(row: 3, section: 0)]
    private let entityIndexPaths = [IndexPath(row: 4, section: 0)]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onClientTypeChanged(_ sender: Any) {
        let index = clientTypeControl.selectedSegmentIndex
        let clientType = clientTypes[index]

        selectedIndividual = clientType == .individual

        switch clientType {
        case .limitedCompany:
            entityNameField.placeholder = "Company name..."
        case .partnership:
            entityNameField.placeholder = "Partnership name..."
        case .trust:
            entityNameField.placeholder = "Trust name..."
        default:
            break
        }

        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndividual && entityIndexPaths.contains(indexPath) ||
           !selectedIndividual && individualIndexPaths.contains(indexPath) {
            return 0
        }

        if clientTypeIndexPath == indexPath {
            return 62
        }

        return 45
    }

    @IBAction func importFromContacts(_ sender: Any) {

        askForContactAccess()

        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true) {

        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        firstNameField.text = contact.givenName
        middleNameField.text = contact.middleName
        surnameField.text = contact.familyName
        entityNameField.text = contact.organizationName

        emailField.text = String(contact.emailAddresses.first?.value ?? "")
        telephoneField.text = contact.phoneNumbers.first?.value.stringValue ?? ""

        var clientType = Client.ClientType.individual
        if contact.givenName.isEmpty && contact.middleName.isEmpty && contact.familyName.isEmpty {
            if contact.organizationName.range(of: "LLC") != nil {
                clientType = .limitedCompany
            } else if contact.organizationName.range(of: "LLP") != nil {
                clientType = .partnership
            }
        }
        clientTypeControl.selectedSegmentIndex = clientTypes.firstIndex(of: clientType)!
        clientTypeControl.sendActions(for: .valueChanged)
    }

    private func askForContactAccess() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        if authorizationStatus == .authorized {
            return
        }

        let contactStore = CNContactStore()
        contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { access, accessError in
            if !access {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Contacts", message: "Failed to get access to Contacts", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }

    private func clientDetails() -> Client {
        let clientType = clientTypes[clientTypeControl.selectedSegmentIndex]

        var client = Client(id: nil, type: clientType)
        client.foreNames = firstNameField.text
        client.middleNames = middleNameField.text
        client.surname = surnameField.text
        client.companyName = entityNameField.text
        client.email = emailField.text
        client.phoneNumber = telephoneField.text

        return client
    }

    private func saveClient(_ client: Client, completion: @escaping ((Bool) -> Void)) {
        let host = (Bundle.main.infoDictionary?["Server"] as? String) ?? ""
        let url = URL(string: "\(host)/client")

        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(client) else {
            completion(false)
            return
        }

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print("Failed to create new client: \(error!)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    print("Failed to create new client, status code: \(httpResponse.statusCode)")
                    completion(false)
                    return;
                }
            }

            completion(true)
        }

        dataTask.resume();
    }

    @IBAction func saveAndClose(_ sender: Any) {
        saveClient(clientDetails()) {
            ok in

            DispatchQueue.main.async {
                if ok {
                    self.dismiss(animated: true)
                } else {
                    let alertController = UIAlertController(title: "New Client", message: "Failed to create new Client", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}