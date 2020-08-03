//
//  MapsViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/29/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import MapKit



protocol locationDelegate {
    func sendLocation(location: CLLocation)
}




class MapsViewController: UIViewController {
    
    
    
    let manager      = CLLocationManager()
    let mkAnnotation = MKPointAnnotation()
    var myLocation     : CLLocation?
    var location     : CLLocation?
    var delegate     : locationDelegate?
    
    
    @IBOutlet weak var maps: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    
    
    
    
    
    
    
    // MARK:- Setup UI
    
    private func setupUI() {
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        longTapGesture.minimumPressDuration = 0.2
        maps.addGestureRecognizer(longTapGesture)
        
        manager.delegate = self
        maps.showsUserLocation = true
        setupUserLocation()
    }
    
    
    private func setupUserLocation() {
        if let location = manager.location?.coordinate {
            myLocation = manager.location
            self.location = myLocation
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 400, longitudinalMeters: 400)
            maps.setRegion(region, animated: true)
        }
    }
    
    
    
    
    
    
    
    // MARK:- Acions
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        delegate?.sendLocation(location: location!)
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func detectLocationPressed(_ sender: UIButton) {
        maps.removeAnnotation(mkAnnotation)
        setupUserLocation()
    }
    
}








// MARK:- Location manager delegate

extension MapsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.last!
        myLoadLocation(location: myLocation!)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    private func myLoadLocation(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mkAnnotation.coordinate = coordinate
        mkAnnotation.title = "You"
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        maps.addAnnotation(mkAnnotation)
        maps.setRegion(region, animated: true)
        activityIndecator.stopAnimating()
    }
    
    @objc func longTap(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            maps.removeAnnotation(mkAnnotation)
            let locationInView = sender.location(in: maps)
            let locationOnMap = maps.convert(locationInView, toCoordinateFrom: maps)
            mkAnnotation.coordinate = locationOnMap
            mkAnnotation.title = ""
            location = CLLocation(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            maps.addAnnotation(mkAnnotation)
            sender.state = .ended
        } else {
            sender.state = .ended
        }
    }
    
}
