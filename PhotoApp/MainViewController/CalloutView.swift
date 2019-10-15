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

    convenience init(frame: CGRect, model: Photomodel ) {
        self.init(frame: frame)
        self.model = model
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("calloutView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addBackgroundButton(to: contentView)
        if let model = self.model {
        self.imageView.loadImage(idString: model.id)
        self.descriptionLabel.text = model.description
        let formater = DateFormatter()
        formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let date = formater.date(from: model.date ?? "")
        formater.dateFormat = "dd-MM-yyyy"
        self.dateLabel.text = formater.string(from: date ?? Date.init())

        self.layer.shadowPath =
            UIBezierPath(roundedRect: self.bounds ,
                         cornerRadius: 10 ).cgPath
        self.layer.shadowColor = UIColor.black.cgColor
          self.layer.shadowOpacity = 0.5
          self.layer.shadowOffset = CGSize(width: 10, height: 10)
          self.layer.shadowRadius = 1

        self.imageView.layer.cornerRadius = 10
    }
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
        if let img =  imageView.image {
       self.calloutDelegate?.addPopupVC(whithImage: img, model: self.model, date: nil)
        } else {

        }

    }
    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)

    }

}
