//
//  OtherViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
import Photos
class OtherViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

 
    @IBOutlet weak var imageView: CachedImageView!
    @IBOutlet weak var emailLaibel: UILabel!
    
    let imagePickerController =  UIImagePickerController()
   let  storageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newTap = UITapGestureRecognizer.init(target: self, action: #selector(imageViewTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(newTap)
        
        imagePickerController.delegate = self
        
        if let user = Auth.auth().currentUser{
            self.emailLaibel.text = user.email
            self.imageView.loadImage(idString: user.uid)
        }
        else {
             self.emailLaibel.text = "cant check the user"
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    @objc func imageViewTap(){
      addPhoto()
    }
    @IBAction func signOutButtonTapped(_ sender: Any) {

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
          let appDelegate =  self.appDelegate
            appDelegate.setLoginVCRootControler()
            } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)

        }

    }
    
    func addPhoto() {
        let alert = UIAlertController.init(title: "Add photo", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "Take A Picture", style: UIAlertAction.Style.default, handler: { (_) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction.init(title: "Choose From Gallery", style: UIAlertAction.Style.default, handler: { (_) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .denied {} else {
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)

            }
        }
    }

    func openGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied {} else {
            self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let img = image {
            self.imageView.image = img
            if let userID = Auth.auth().currentUser?.uid{
                   let ref = storageRef.child("\(userID)/\(userID)")
                CachedImageView.imageCashe.setObject(img, forKey: userID as NSString)
                    if  let data = img.jpegData(compressionQuality: 0.7) {
                    ref.putData(data, metadata: nil) { (metadata, _) in
                        guard metadata != nil else {
                        return
                    }
                    ref.downloadURL { (url, _) in
                        guard url != nil else {
                            return
                        }
                    }
              }
                }
        }
        }
        self.dismiss(animated: true, completion: nil)
    }
    

}
