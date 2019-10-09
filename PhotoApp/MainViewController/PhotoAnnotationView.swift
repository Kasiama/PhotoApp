//
//  photoAnnotationView.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/20/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import MapKit
import Firebase



class PhotoAnnotationView: MKMarkerAnnotationView {
    
    
    
    
    
        var calloutView: CalloutView?
    weak var delegate: PhotoAnnotationDelegate?
   weak var calloutDelegate: CalloutDelegate?
    var photoModel : Photomodel?
    var storageRef: StorageReference!
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
            
        }
    }
    let animationDuration: TimeInterval = 0.25
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        canShowCallout = true
}
    convenience  init(annotation: MKAnnotation?, reuseIdentifier: String?,model:Photomodel) {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.photoModel = model
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard let annotationCoordinate = self.annotation?.coordinate else { return  }
        let zoomRegion = MKCoordinateRegion(center: annotationCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.delegate?.moveMap(zoomRegion: zoomRegion)
        if selected {
            self.calloutView?.removeFromSuperview()
            calloutView =  CalloutView.init(frame: CGRect.init(x: -70, y: -115  , width: 200, height:70),model: photoModel!)
            calloutView?.calloutDelegate = self.calloutDelegate
            self.calloutView?.add(to: self)
        if animated {
                self.calloutView?.alpha = 0
                UIView.animate(withDuration: animationDuration) {
                   self.calloutView?.alpha = 1
                }
            }
        } else {
            guard let calloutView = calloutView else { return }
                if animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    calloutView.alpha = 0
                }, completion: { _ in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        calloutView?.removeFromSuperview()
    }
    
}
