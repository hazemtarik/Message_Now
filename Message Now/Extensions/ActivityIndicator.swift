//
//  ActivityIndecator.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/7/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit


struct ActivityIndicator {
    
    private static let activityIndicator = UIActivityIndicatorView()
    
    public static func initActivityIndecator(view: UIView) {
        activityIndicator.color = UIColor(named: "ActivityIndecatorColor")
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    public static func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    public static func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
}

