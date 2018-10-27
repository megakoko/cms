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

    private struct Field {
        enum SpecialType {
            case Address, Phone, Link, Relationship, None
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
        let host = ProcessInfo.processInfo.environment["host"] ?? ""
        let url = URL(string: "\(host)/client?id=eq.\(client!.id)")!

        let coreDataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in

            if error != nil {
                print("Failed to get client: \(error!)")
                return
            }

            if let clients = try? JSONDecoder().decode([Client].self, from: data!) {
                self.client = clients.first
                self.updateClientAddressOnMap()
            }

            DispatchQueue.main.async {
                self.updateUi()
            }
        }
        coreDataTask.resume()

        let relationshipUrl = URL(string: "\(host)/clientrelationship?clientId=eq.\(client!.id)")!
        let relationshipsDataTask = URLSession.shared.dataTask(with: relationshipUrl) {
            data, response, error in

            if error != nil {
                print("Failed to get relationships: \(error!)")
                return
            }

            if let relationships = try? JSONDecoder().decode([Relationship].self, from: data!) {
                self.relationships = relationships
            }

            DispatchQueue.main.async {
                self.updateUi()
            }
        }

        relationshipsDataTask.resume()
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
                    let distance = CLLocationDistance(exactly: 1000.0)
                    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance!, longitudinalMeters: distance!)

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
        } else {
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
        return field.specialType == .Address ? CGFloat(90) : CGFloat(45)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let indexPath = tableView.indexPathForSelectedRow else { return false }
        return fields[indexPath.section].specialType == .Relationship
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell else { return }

        let indexPath = tableView.indexPath(for: cell)

        let relationship = relationships[indexPath!.row]

        let clientViewController = segue.destination as! ClientViewController
        clientViewController.setClient(id: relationship.relatedClientId, type: relationship.relatedClientType)
        clientViewController.title = relationship.relatedClientName
    }
}
