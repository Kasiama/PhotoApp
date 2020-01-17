//
//  AdvancedLocationEstimatesHolder.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/15/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import Foundation
class AdvancedLocationEstimatesHolder: BasicLocationEstimatesHolder {
    
    //weak var delegate: ARNavigationViewControllerDelegate?
    override func add(_ locationEstimate: SceneLocationEstimate) {
        for estimate in estimates {
            guard !estimate.canReplace(locationEstimate) else { return }
        }
        super.add(locationEstimate)
        filter { !locationEstimate.canReplace($0) }
    }
}
