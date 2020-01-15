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

class ARKitCoreLocationEngineClass: NSObject {
    
    
}
