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

    @IBOutlet weak var entityNameField: UITextField!

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
        print(contact.emailAddresses.first?.value ?? "")
        print(contact.phoneNumbers.first?.value.stringValue ?? "")
        print(contact.givenName)
        print(contact.middleName)
        print(contact.familyName);
        print(contact.organizationName)
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
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }

    @IBAction func saveAndClose(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}
