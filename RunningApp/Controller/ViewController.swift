//
//  ViewController.swift
//  RunningApp
//
//  Created by Mohammad Shayan on 4/29/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MessageUI

class ViewController: UIViewController {

    @IBOutlet weak var unitsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var errorView: RoundErrorView!
    
    var units: Units!
    let unitsArray: [Units] = [.miles, .kilometers]
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var locationAccess = false
    
    var locationsPassed = [CLLocation]()
    var isRunning = false
    var route: MKPolyline?
    var distanceTraveled = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        reset()
        setup()
    }
    
    func setup() {
        disableAllButtons()
        runButton.setTitleColor(.green, for: .normal)
        errorView.isHidden = true
        distanceLabel.isHidden = true
        setupSegmentedControl()
        checkLocationServices()
    }
    
    func setupSegmentedControl() {
        unitsSegmentedControl.removeAllSegments()
        for i in 0..<(unitsArray.count) {
            let unit = unitsArray[i].rawValue
            unitsSegmentedControl.insertSegment(withTitle: unit, at: i, animated: false)
        }
        
        unitsSegmentedControl.selectedSegmentIndex = 0
        
        units = unitsArray[unitsSegmentedControl.selectedSegmentIndex]
    }
    
    func addLocationsToArray(_ locations: [CLLocation]) {
        for location in locations {
            if !locationsPassed.contains(location) {
                locationsPassed.append(location)
            }
        }
    }
    
    func calculateAndDisplayDistance() {
        var totalDistance = 0.0
        for i in 1..<locationsPassed.count {
            let previousLocation = locationsPassed[i-1]
            let currentLocation = locationsPassed[i]
            totalDistance += currentLocation.distance(from: previousLocation)
        }
        distanceTraveled = totalDistance
        
        let displayDistance: String
        switch units {
        case .miles:
            displayDistance = String(format: "Distance Travelled: %.2f miles", distanceTraveled * 0.0006213712)
        default:
            displayDistance = String(format: "Distance Travelled: %.2f kilometers", distanceTraveled * 0.001)
        }
        
        distanceLabel.text = displayDistance
    }
    
    func getAppleMapsURL() -> String? {
        guard let startLocation = locationsPassed.first?.coordinate, let endLocation = locationsPassed.last?.coordinate, locationsPassed.count > 1 else {
            return nil
        }
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: startLocation))
        source.name = "Start"
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: endLocation))
        destination.name = "End"
        
        let appleMapsURL = "http://maps.apple.com/maps?saddr=\(startLocation.latitude),\(startLocation.longitude)&daddr=\(endLocation.latitude),\(endLocation.longitude)"
        return appleMapsURL
    }
    
    func startRun() {
        reset()
        
        isRunning = true
        shareButton.isEnabled = false
        distanceLabel.isHidden = true
        distanceLabel.text = ""
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func stopRun() {
        isRunning = false
        shareButton.isEnabled = true
        distanceLabel.isHidden = false
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        displayRoute()
    }
    
    func enableButtons() {
        runButton.isEnabled = true
        shareButton.isEnabled = true
        locationButton.isEnabled = true
        
        runButton.isHidden = false
        shareButton.isHidden = false
        locationButton.isHidden = false
        
        runButton.layer.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.75)
        shareButton.layer.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.5)
        locationButton.layer.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.5)
    }
    
    func disableAllButtons() {
        runButton.isEnabled = false
        shareButton.isEnabled = false
        locationButton.isEnabled = false
        
        runButton.isHidden = true
        shareButton.isHidden = true
        locationButton.isHidden = true
    }
}

extension ViewController{
    @IBAction func locationButtonTapped(_ sender: Any) {
        centerViewOnUserLocation()
    }

    @IBAction func runButtonTapped(_ sender: Any) {
        if runButton.title(for: .normal) == "START RUN" {
            runButton.setTitle("STOP RUN", for: .normal)
            startRun()
            runButton.setTitleColor(.red, for: .normal)
        } else {
            runButton.setTitle("START RUN", for: .normal)
            stopRun()
            runButton.setTitleColor(.green, for: .normal)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        guard let appleMapsURL = getAppleMapsURL() else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let url = URL(string: appleMapsURL)!
        
        if UIApplication.shared.canOpenURL(url) {
            let mapAction = UIAlertAction(title: "Open in Apple Maps", style: .default) { (action) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(mapAction)
        }
        
        if MFMessageComposeViewController.canSendText() {
            let controller = getComposeMessageViewController(message: "Hey, this is the route I jogged: \(appleMapsURL)")
            let smsAction = UIAlertAction(title: "Send Route to Friend", style: .default) { (action) in
                self.present(controller, animated: true, completion: nil)
            }
            alert.addAction(smsAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func unitsChanged(_ sender: Any) {
        units = unitsArray[unitsSegmentedControl.selectedSegmentIndex]
        
        if !isRunning && locationsPassed.count > 0 {
            calculateAndDisplayDistance()
        }
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate {

    func getComposeMessageViewController(message: String) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = message
        controller.messageComposeDelegate = self
        return controller
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CustomAnnotation {
            let id = "pin"
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesDrop = true
            view.pinTintColor = annotation.coordinateType == .start ? .green : .red
            view.calloutOffset = CGPoint(x: -8, y: -3)
            
            return view
        }
        return nil
    }
    
    func displayRoute() {
        
        var routeCoordinates = [CLLocationCoordinate2D]()
        for location in locationsPassed {
            routeCoordinates.append(location.coordinate)
        }
        route = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        guard let route = route else { return }
        mapView.addOverlay(route)
        mapView.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        
        calculateAndDisplayDistance()
        setupAnnotations()
    }
    
    func setupAnnotations() {
        guard let startLocation = locationsPassed.first?.coordinate, let endLocation = locationsPassed.last?.coordinate, locationsPassed.count > 1 else {
            return
        }
        let startAnnotation = CustomAnnotation(coordinateType: .start, coordinate: startLocation)
        let endAnnotation = CustomAnnotation(coordinateType: .end, coordinate: endLocation)
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
    }
    
    func removeOverlays() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }
    
    func reset() {
        removeOverlays()
        distanceTraveled = 0
        locationsPassed.removeAll()
        route = nil
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        if isRunning {
            addLocationsToArray(locations)
        }
        
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("MSH: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            enableButtons()
            errorView.isHidden = true
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        } else {
            disableAllButtons()
            locationManager.stopUpdatingLocation()
            errorView.isHidden = false
            errorView.setErrorMessage("Location not found")
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            errorView.isHidden = true
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            disableAllButtons()
            errorView.isHidden = false
            errorView.setErrorMessage("Please enable Location Services")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            errorView.isHidden = true
            locationManager.requestLocation()
            centerViewOnUserLocation()
            break
        case .notDetermined:
           locationManager.requestAlwaysAuthorization()
        default:
            disableAllButtons()
            //Alert error
            locationManager.stopUpdatingLocation()
            errorView.isHidden = false
            errorView.setErrorMessageLocationAlways()
            break
        }
    }
}
