//
//  MapDetailsViewController.swift
//  cms
//
//  Created by Andy on 27/10/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit
import MapKit

class MapDetailsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    private var coordinate: CLLocationCoordinate2D!
    private var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let distance = CLLocationDistance(1000.0)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: distance, longitudinalMeters: distance)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation)
    }

    func setCoordinate(_ coordinate: CLLocationCoordinate2D, name: String?) {
        self.coordinate = coordinate
        self.name = name
    }

    @IBAction func openNavigation(_ sender: Any) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
