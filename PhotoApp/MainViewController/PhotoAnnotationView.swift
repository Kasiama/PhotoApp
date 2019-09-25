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
    
    // MARK: - Initialization methods
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        canShowCallout = false
        // animatesDrop = true
}
    convenience  init(annotation: MKAnnotation?, reuseIdentifier: String?,model:Photomodel) {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.photoModel = model
        //self.imagee = UIImage.init(named: "map")
        

    }
    
    convenience  init(annotation: MKAnnotation?, reuseIdentifier: String?,model:Photomodel,image:UIImage) {
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.photoModel = model
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Show and hide callout as needed
    
    // If the annotation is selected, show the callout; if unselected, remove it
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let a = self.annotation?.coordinate
        let zoomRegion = MKCoordinateRegion(center: a as! CLLocationCoordinate2D, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.delegate?.moveMap(zoomRegion: zoomRegion)
        if selected {
            
            
            self.calloutView?.removeFromSuperview()
            
            calloutView =  CalloutView.init(frame: CGRect.init(x: -50, y: -100  , width: 200, height:70),model: photoModel!)
            calloutView?.calloutDelegate = self.calloutDelegate

             //calloutView?.imageView = cash
             //cash.loadImage(idString: photoModel!.id)
            
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
    
    // Make sure that if the cell is reused that we remove it from the super view.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        calloutView?.removeFromSuperview()
    }
    
    // MARK: - Detect taps on callout
    
    // Per the Location and Maps Programming Guide, if you want to detect taps on callout,
    // you have to expand the hitTest for the annotation itself.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) { return hitView }
        
        if let calloutView = calloutView {
            let pointInCalloutView = convert(point, to: calloutView)
            return calloutView.hitTest(pointInCalloutView, with: event)
        }
        
        return nil
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
