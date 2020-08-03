//
//  Network.swift
//  Message Now
//
//  Created by Hazem Tarek on 6/27/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import Foundation
import Reachability

class Network {
    
    static let shared = Network()
    
    
    
    public var isReachable = false { didSet { updateConnectionStatus?(isReachable) } }
    private var reachability      : Reachability?
    
    
    
    
    var updateConnectionStatus: ((Bool)->())?
    
    
    init() {
        checkConnection()
    }
    
    
    
    
    
    
    
    
    // MARK:- Setup Reachability
    
    public func checkConnection() {
        stopNotifier()
        setupReachability()
        startNotifier()
        
    }
    
    
    private func setupReachability() {
        let reachable: Reachability?
        do {
            reachable = try Reachability()
            reachability = reachable
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } catch {
        }
        
        
    }
    
    // MARK:- Start and stop Notifier
    
    private func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            print( "Unable to start\nnotifier")
            return
        }
    }
    
    private func stopNotifier() {
        reachability?.stopNotifier()
    }
    
    private func updateLabelColourWhenReachable(_ reachability: Reachability) {
        isReachable = true
    }
    
    private func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
        isReachable = false
        
    }
    
    
}

