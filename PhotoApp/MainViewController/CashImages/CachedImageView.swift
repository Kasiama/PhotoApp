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
    
    public static let imageCashe = NSCache<NSString,UIImage>()
    
    var idString: String?
   var storageRef: StorageReference = Storage.storage().reference()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    open func loadImage(idString: String){
        super.image = nil
        self.idString = idString
         let idkey = idString as NSString
        self.activityIndicator.center = self.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = .gray
        self.activityIndicator.startAnimating()
        self.addSubview(self.activityIndicator)
        if let cashImage = CachedImageView.imageCashe.object(forKey: idkey){
            self.activityIndicator.stopAnimating()
            super.image = cashImage
            return
        }
        else {
            
            let islandRef = storageRef.child("\(String(describing: Auth.auth().currentUser!.uid))/\(String(describing: idString))")
            islandRef.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                
                
                
                
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    
                    if   let image = UIImage(data: data!){
                        self.activityIndicator.stopAnimating()
                    super.image = image
                        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {self.image = image}, completion: nil)
                    CachedImageView.imageCashe.setObject(image , forKey: idkey)
                        return
                    }
                }
            }
            
        }
        
        
        
        
        
    }
    
    
}
