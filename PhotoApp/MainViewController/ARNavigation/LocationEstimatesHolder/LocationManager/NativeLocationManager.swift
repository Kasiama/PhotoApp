//
//  NativeLocationManager.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/14/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import Foundation
import CoreLocation

public class NativeLocationManager: NSObject {

    public class var sharedInstance: NativeLocationManager { return Static.instance }

    // MARK: Initialization

    public override init() {
        self.locationManager = CLLocationManager()

        super.init()

        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location, isLocationViable(location) {
            self.lastLocation = location
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    deinit {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }

    // MARK: Private

    fileprivate let locationManager: CLLocationManager
    fileprivate let listeners = WeakObjectCollection<LocationManagerListener>()
    fileprivate var lastLocation: CLLocation? = nil

}

extension NativeLocationManager: LocationManager {

    public var location: CLLocation? {
        return lastLocation
    }

    public var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }



    public func addListener(_ listener: LocationManagerListener) {
        assert(Thread.isMainThread)
        listeners.insert(listener)
    }

    public func removeListener(_ listener: LocationManagerListener) {
        assert(Thread.isMainThread)
        listeners.remove(listener)
    }

    public func suspend() {
        locationManager.stopUpdatingLocation()
    }

    public func resume() {
        locationManager.startUpdatingLocation()
    }
}

extension NativeLocationManager: CLLocationManagerDelegate {

    @objc public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isLocationViable(location) else { return }

        for l in listeners.array() {
            l.onLocationUpdate(location)
        }
    }

    @objc public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for l in listeners.array() {
            l.onAuthorizationStatusUpdate(status)
        }
    }
}

fileprivate extension NativeLocationManager {

    struct Static {
        static let instance = NativeLocationManager()
        static let maxTimeSinceLastUpdate: TimeInterval = 30.0
    }

    func isLocationViable(_ location: CLLocation?) -> Bool {
        guard let location = location else { return false }
        guard Date().timeIntervalSince(location.timestamp) < Static.maxTimeSinceLastUpdate else { return false }
        if let lastLocation = self.lastLocation, lastLocation.timestamp > location.timestamp {
            return false
        }
        self.lastLocation = location
        return true
    }

}
