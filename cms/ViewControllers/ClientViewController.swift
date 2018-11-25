//
//  ClientViewController.swift
//  cms
//
//  Created by Andy on 10/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class ClientViewController : UITableViewController {
    @IBOutlet weak var mapView: MKMapView!

    private var client: Client? = nil
    private var relationships = [Relationship] ()
    private var attachments = [Attachment] ()
    private var addressCoordinate: CLLocationCoordinate2D? = nil

    private struct Field {
        enum SpecialType {
            case Address, Phone, Link, Relationship, Attachment, None
        }

        init(description: String, data: String?, specialType: SpecialType = .None) {
            self.description = description
            self.data = data
            self.specialType = specialType
        }
        let description: String
        let data: String?
        let specialType: SpecialType
    }
    private var fields = [Field]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView?.isHidden = true

        updateUi()

        if client?.id != nil {
            loadData()
            updateUi()
        }
    }

    func setClient(id: Int, type: Client.ClientType) {
        self.client = Client(id: id, type: type)
    }

    private func loadData() {
        NetworkManager.request(.client(id: client!.id!)) {
            response in

            if let error = response?.error {
                print("Failed to get client: \(error)")
            } else {
                if let client = response?.parsed(Client.self) {
                    self.client = client
                    self.updateClientAddressOnMap()
                }

                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        }

        NetworkManager.request(.relationships(clientId: client!.id!)) {
            response in

            if let error = response?.error {
                print("Failed to get client relationships: \(error)")
            } else {
                self.relationships = response?.parsed([Relationship].self) ?? [Relationship]()

                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        }

        NetworkManager.request(.attachments(clientId: client!.id!)) {
            response in

            if let error = response?.error {
                print("Failed to get client attachments: \(error)")
            } else {
                self.attachments = response?.parsed([Attachment].self) ?? [Attachment]()

                DispatchQueue.main.async {
                    self.updateUi()
                }
            }
        }
    }

    private func updateUi() {
        fields.removeAll()

        if let client = client {
            let isPerson = (client.type == .individual)

            fields.append(Field(description: "Client Code", data: client.code))
            if isPerson {
                fields.append(Field(description: "First name", data: client.foreNames))
                fields.append(Field(description: "Middle name", data: client.middleNames))
                fields.append(Field(description: "Surname", data: client.surname))
            } else {
                fields.append(Field(description: "Company name", data: client.companyName))
            }
            fields.append(Field(description: "UTR", data: client.utr))
            fields.append(Field(description: "Telephone", data: client.phoneNumber, specialType: .Phone))
            fields.append(Field(description: "Email", data: client.email, specialType: .Link))
            fields.append(Field(description: "Relationships", data: nil, specialType: .Relationship))
            fields.append(Field(description: "Attachments", data: nil, specialType: .Attachment))
            fields.append(Field(description: "Address", data: client.address, specialType: .Address))
        }

        tableView.reloadData()
    }

    private func updateClientAddressOnMap() {
        if client?.address != nil {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(client!.address!) {
                (placemarks, error) in
                if error != nil {
                    print("Failed to get client address: \(error!)")
                    return
                }
                
                if let coordinate = placemarks?.first?.location?.coordinate {
                    self.addressCoordinate = coordinate

                    let distance = CLLocationDistance(1000.0)
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance, longitudinalMeters: distance)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate

                    DispatchQueue.main.async {
                        self.mapView.setRegion(region, animated: false)
                        self.mapView.addAnnotation(annotation)
                        self.tableView.tableFooterView?.isHidden = false
                    }
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fields.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fields[section].description
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let field = fields[section]
        if field.specialType == .Relationship {
            return relationships.count
        } else if field.specialType == .Attachment {
            return attachments.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientViewCell", for: indexPath) as! ClientViewCell
        let field = fields[indexPath.section]
        
        if field.specialType == .Relationship {
            let relationship = relationships[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.textView.isUserInteractionEnabled = false
            cell.textView.text = relationship.relatedClientName
        } else if field.specialType == .Attachment {
            let attachment = attachments[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            cell.textView.isUserInteractionEnabled = false
            cell.textView.text = attachment.fileName
        } else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.textView.text = field.data
            switch field.specialType {
            case .Link:
                cell.textView.dataDetectorTypes = .link
            case .Phone:
                cell.textView.dataDetectorTypes = .phoneNumber
            default:
                cell.textView.dataDetectorTypes = UIDataDetectorTypes()
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = fields[indexPath.section]
        return field.specialType == .Address ? CGFloat(90) : CGFloat(40)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else { return false }
        switch fields[indexPath.section].specialType {
        case .Relationship, .Attachment:
            return true
        default:
            return false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapDetailsSegue" {
            let mapDetailsController = segue.destination as! MapDetailsViewController
            mapDetailsController.setCoordinate(addressCoordinate!, name: client?.name)
        } else if segue.identifier == "attachmentSegue" {
            guard let cell = sender as? UITableViewCell else { return }

            let indexPath = tableView.indexPath(for: cell)
            let attachment = attachments[indexPath!.row]

            let navigationController = segue.destination as! UINavigationController
            let attachmentViewController = navigationController.topViewController as! AttachmentViewController
            attachmentViewController.attachmentId = attachment.id
            attachmentViewController.title = attachment.fileName
        }
    }

    @IBAction private func openMapDetails(_ sender: Any) {
        performSegue(withIdentifier: "mapDetailsSegue", sender: mapView)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch fields[indexPath.section].specialType {
        case .Attachment:
            if let cell = tableView.cellForRow(at: indexPath) {
                performSegue(withIdentifier: "attachmentSegue", sender: cell)
            }
        case .Relationship:
            let clientViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientViewController") as! ClientViewController

            let relationship = relationships[indexPath.row]
            clientViewController.setClient(id: relationship.relatedClientId, type: relationship.relatedClientType)
            clientViewController.title = relationship.relatedClientName

            navigationController?.pushViewController(clientViewController, animated: true)
        default:
            break
        }
    }
}
