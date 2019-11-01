//
//  Custom.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/23/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import MapKit

class Custom: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var photoModel: Photomodel?
    var color  = UIColor.clear
    var isFriendAnnotation = false
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
