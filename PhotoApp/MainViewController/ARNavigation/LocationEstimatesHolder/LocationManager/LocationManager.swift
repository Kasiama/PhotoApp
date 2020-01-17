//
//  LocationManager.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/14/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocationManager {
    var location: CLLocation? { get }

    func addListener(_ listener: LocationManagerListener)
    func removeListener(_ listener: LocationManagerListener)

    func suspend()
    func resume()
}

public protocol LocationManagerListener: class {
    func onLocationUpdate(_ location: CLLocation)
    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus)
}
