//
//  ARKitCoreLocationEngine.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/14/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import UIKit
import CoreLocation
import SceneKit
import ARKit
protocol ARKitCoreLocationEngine {
    /// Converts geo coordinate to 3D position
    ///
    /// - Parameter coordinate: position on earth
    /// - Returns: position on 3D scene with y = 0
    func convert(coordinate: CLLocationCoordinate2D) -> SCNVector3?
    func userLocationEstimate() -> SceneLocationEstimate?
}

class ARKitCoreLocationEngineClass: NSObject, ARKitCoreLocationEngine {
    func convert(coordinate: CLLocationCoordinate2D) -> SCNVector3? {
        guard let anchorEstimate = locationEstimatesHolder.bestLocationEstimate else { return nil }
               let location = anchorEstimate.location
               let position = anchorEstimate.position
               let translation = location.coordinate.translation(toCoordinate: coordinate)
               return SCNVector3(
                   x: position.x + Float(translation.longitudeTranslation),
                   y: 0.0,
                   z: position.z - Float(translation.latitudeTranslation)
               )
    }
    
    func userLocationEstimate() -> SceneLocationEstimate? {
        guard let bestEstimate = locationEstimatesHolder.bestLocationEstimate else { return nil }
               guard let position = currentScenePosition() else { return nil }
               let correctLocation = bestEstimate.translatedLocation(to: position)
               return SceneLocationEstimate(location: correctLocation, position: position)
    }
    
    
    private let scnView: SCNView
      private let locationManager: LocationManager
      private let locationEstimatesHolder: LocationEstimatesHolder
      private var filterLocationEstimatesAction: TimerAction? = nil
    
    init(view: SCNView, locationManager: LocationManager, locationEstimatesHolder: LocationEstimatesHolder) {
        self.scnView = view
        self.locationManager = locationManager
        self.locationEstimatesHolder = locationEstimatesHolder
        super.init()

        filterLocationEstimatesAction = TimerAction(timeInterval: 3.0, repeats: true) { [weak self] in
            self?.filterLocationEstimates()
        }
        locationManager.addListener(self)
    }
    
    
}


extension ARKitCoreLocationEngineClass {
    private func currentScenePosition() -> SCNVector3? {
        return scnView.pointOfView?.worldPosition
    }

    private func currentEulerAngles() -> SCNVector3? {
        return scnView.pointOfView?.eulerAngles
    }

    /// Filters locationEstimates
    func filterLocationEstimates() {
        guard let positionOnScene = currentScenePosition() else { return }
        let currentPoint = CGPoint(position: positionOnScene)
        locationEstimatesHolder.filter {
            let point = CGPoint(position: $0.position)
            return currentPoint.radiusContainsPoint(radius: GeometryConstants.sceneRadiusLimit, point: point)
        }
    }
}
extension ARKitCoreLocationEngineClass: LocationManagerListener {
    func onAuthorizationStatusUpdate(_ authorizationStatus: CLAuthorizationStatus) {
        
    }

    func onLocationUpdate(_ location: CLLocation) {
        guard let positionOnScene = currentScenePosition() else { return }
        let newLocationEstimate = SceneLocationEstimate(location: location, position: positionOnScene)
        locationEstimatesHolder.add(newLocationEstimate)
    }
}
