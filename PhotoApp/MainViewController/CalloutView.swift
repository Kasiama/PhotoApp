//
//  calloutView.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/20/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import MapKit


class CalloutView: UIView {

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var contentView: UIView!
    @IBOutlet  var imageView: CachedImageView!
       weak var calloutDelegate: CalloutDelegate?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var model: Photomodel?
    
    convenience init(frame:CGRect, model:Photomodel ){
        self.init(frame: frame)
        self.model = model
        commonInit()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //commonInit()
    }
    private func commonInit(){
        Bundle.main.loadNibNamed("calloutView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addBackgroundButton(to: contentView)
     //   self.imageView = CachedImageView()
        self.imageView.loadImage(idString: model!.id)
        
        
          let a = self.imageView.image
        
    }
    fileprivate func addBackgroundButton(to view: UIView) {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        button.addTarget(self, action: #selector(didTouchUpInCallout(_:)), for: .touchUpInside)
    }
    @objc func didTouchUpInCallout(_ sender: Any) {
        if imageView.image != nil {
       self.calloutDelegate?.addPopupVC(whithImage: imageView.image!,model: self.model)
        }
    
    }
    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)
        
        // constraints for this callout with respect to its superview
        
        //        NSLayoutConstraint.activate([
        //            bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: annotationView.calloutOffset.y),
        //            centerXAnchor.constraint(equalTo: annotationView.centerXAnchor, constant: annotationView.calloutOffset.x)
        //            ])
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

}
