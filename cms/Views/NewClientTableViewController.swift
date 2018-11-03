//
//  NewClientTableViewController.swift
//  cms
//
//  Created by Andy on 03/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewClientTableViewController: UITableViewController {
    @IBOutlet weak var clientTypeControl: UISegmentedControl!

    @IBOutlet weak var entityNameField: UITextField!

    private let clientTypes = [
        (Client.ClientType.individual, "Individual"),
        (Client.ClientType.limitedCompany, "Limited Company"),
        (Client.ClientType.partnership, "Partnership"),
        (Client.ClientType.trust, "Trust")
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
        let clientType = clientTypes[index].0

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

    @IBAction func saveAndClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
