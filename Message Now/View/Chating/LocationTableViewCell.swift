//
//  LocationTableViewCell.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/13/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {
    
    var msgVM = MessageViewModel() { didSet {
        setLocationOnMap(latitude: msgVM.latitude!, longitude: msgVM.longitude!)
        }}
    
    let map = MKMapView(frame: .init(x: 0, y: 0, width: 260, height: 280))
    
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationStack: UIStackView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        locationImage.isUserInteractionEnabled = true
        locationImage.layer.cornerRadius = 15
    }
    
    
    
    
    
    
    func setLocationOnMap(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        map.setRegion(region, animated: true)
        
        // Snapshotting Map View
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        mapSnapshotOptions.region = map.region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = map.frame.size
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        //Start Snapshotter
        snapShotter.start { [weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let snap = snapshot else { return }
            
            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, 0)
            snap.image.draw(at: .zero)
            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pinView.image
            var point = snap.point(for: coordinate)
            if self.locationImage.bounds.contains(point) {
                let pinCenterOffset = pinView.centerOffset
                point.x -= pinView.bounds.size.width / 2
                point.y -= pinView.bounds.size.height / 2
                point.x += pinCenterOffset.x
                point.y += pinCenterOffset.y
                pinImage?.draw(at: point)
            }
            
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                self.locationImage.image = finalImage
            }
        }
    }
    
    
}
