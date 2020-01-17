//
//  LocationEstimatesHolder.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/15/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationEstimatesHolder {
    var bestLocationEstimate: SceneLocationEstimate? { get }
    var estimates: [SceneLocationEstimate] { get }

    func add(_ locationEstimate: SceneLocationEstimate)
    func filter(_ isIncluded: (SceneLocationEstimate) -> Bool)
}
