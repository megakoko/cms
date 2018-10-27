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
    private var region: MKCoordinateRegion!
    private var annotations = [MKAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setRegion(region, animated: false)
        mapView.addAnnotations(annotations)
    }

    func setRegion(_ region: MKCoordinateRegion) {
        self.region = region
    }

    func setAnnotations(_ annotations: [MKAnnotation]) {
        self.annotations = annotations
    }
}
