//
//  CachedImageView.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/25/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

 open class CachedImageView: UIImageView {

    public static let imageCashe = NSCache<NSString, UIImage>()

     var dict = [String: StorageDownloadTask?]()
    var idString = ""
   var storageRef: StorageReference = Storage.storage().reference()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var task: StorageDownloadTask?

    open func loadImage(idString: String) {
        super.image = nil
        self.idString = idString
         let idkey = idString as NSString
        self.activityIndicator.center = self.center

        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .medium
        self.activityIndicator.startAnimating()
        self.addSubview(self.activityIndicator)

        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
              self.activityIndicator.widthAnchor.constraint(equalToConstant: 20),
            self.activityIndicator.heightAnchor.constraint(equalToConstant: 20)

            ])

        super.contentMode = .scaleAspectFill
        if let cashImage = CachedImageView.imageCashe.object(forKey: idkey) {
            self.activityIndicator.stopAnimating()
            super.image = cashImage
            return
        } else {

                if let pausedTask = dict[idString] {
                    if let task = pausedTask {
                        task.resume()
                        return
                    }

                }

            if let userID = Auth.auth().currentUser?.uid {

            let islandRef = storageRef.child("\(String(describing: userID ))/\(String(describing: idString))")

            self.dict[idString] = islandRef.getData(maxSize: 1024 * 1024 * 1024) { data, error in

                if let error = error {
                    print(error.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.image = UIImage.init(named: "close-2")
                    return
                } else {

                    if let dataImage = data {

                    if   let image = UIImage(data: dataImage) {
                        self.activityIndicator.stopAnimating()
                    super.image = image
                        self.dict[idString] = nil
                        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve,
                                          animations: {self.image = image}, completion: nil)
                    CachedImageView.imageCashe.setObject(image, forKey: idkey)
                        return
                    }
                }
                }
            }
        }
    }

    }

    open func cancelTask(id: String) {
        print("pause  " + id)
        self.idString = id
        dict[id]??.pause()
    }
}
