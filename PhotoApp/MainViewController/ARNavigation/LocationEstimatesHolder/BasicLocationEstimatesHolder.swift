//
//  BasicLocationEstimatesHolder.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 1/15/20.
//  Copyright © 2020 Ivan Zhurauski. All rights reserved.
//

import Foundation
class BasicLocationEstimatesHolder: LocationEstimatesHolder {
    weak var delegate: ARNavigationViewControllerDelegate?
    var isFirstBestlocationEstimate = false;
    private(set) var bestLocationEstimate: SceneLocationEstimate? = nil
    private(set) var estimates: [SceneLocationEstimate] = []

    func add(_ locationEstimate: SceneLocationEstimate) {
        estimates.append(locationEstimate)
        if let bestEstimate = bestLocationEstimate, bestEstimate < locationEstimate { return }
        bestLocationEstimate = locationEstimate
        if isFirstBestlocationEstimate == false{
            self.delegate?.update()
        }
        isFirstBestlocationEstimate = true
    }

    func filter(_ isIncluded: (SceneLocationEstimate) -> Bool) {
        let (passed, removed) = estimates.reduce(([SceneLocationEstimate](),[SceneLocationEstimate]())) { passedRemovedPair, estimate in
            let passed = isIncluded(estimate)
            return (passedRemovedPair.0 + (passed ? [estimate] : []),
                    passedRemovedPair.1 + (passed ? [] : [estimate]))
        }

        assert(passed.count + removed.count == estimates.count)

        estimates = passed
        if let bestEstimate = bestLocationEstimate, !removed.contains(bestEstimate) { return }
        bestLocationEstimate = estimates.sorted{ $0 < $1 }.first
    }
}
