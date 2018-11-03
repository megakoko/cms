//
//  NewClientTableViewController.swift
//  cms
//
//  Created by Andy on 03/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit

class NewClientTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var clientTypePicker: UIPickerView!

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

        clientTypePicker.dataSource = self
        clientTypePicker.delegate = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return clientTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return clientTypes[row].1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let clientType = clientTypes[row].0

        selectedIndividual = clientType == .individual

        self.tableView.reloadData()
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
        print(clientTypePicker.selectedRow(inComponent: 0))

        navigationController?.popViewController(animated: true)
    }
}
