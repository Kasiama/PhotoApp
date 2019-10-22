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
    @IBOutlet weak var userNameLabel: UILabel!
    
    let imagePickerController =  UIImagePickerController()
   let  storageRef = Storage.storage().reference()
    let ref = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      self.navigationItem.rightBarButtonItem =  UIBarButtonItem.init(title: "about", style: UIBarButtonItem.Style.done, target: self, action: #selector(aboutTaped))
        
        let newTap = UITapGestureRecognizer.init(target: self, action: #selector(imageViewTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(newTap)
        
          //let leadingConstraint = self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 35)
           // let topConstraint = self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height / 4.5)
            let xConstraint = self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
            let ylConstraint = self.imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -120)
           // let with = self.imageView.widthAnchor.constraint(equalToConstant: 180)
            //let height = self.imageView.heightAnchor.constraint(equalToConstant: 180)
        
        self.view.addConstraints([ xConstraint, ylConstraint])

        
        
        
        imagePickerController.delegate = self
        
        self.navigationItem.title = "User page"
        
        if let user = Auth.auth().currentUser{
            self.emailLaibel.text = user.email
            self.imageView.loadImage(idString: user.uid)
            let ref = Database.database().reference()
            ref.child(user.uid).child("Username").observe(.value) { (snapshot) in
                if  let value = snapshot.value as? String {
                    self.userNameLabel.text = value
                }
            
            }
                
          
            
        }
        else {
             self.emailLaibel.text = "cant check the user"
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    @objc func imageViewTap(){
      addPhoto()
    }
    @objc func aboutTaped(){
        let aboutVC = AboutViewController()
        self.navigationController?.pushViewController(aboutVC, animated: true)
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {

        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.ref.removeAllObservers()
          let appDelegate =  self.appDelegate
            appDelegate.setLoginVCRootControler()
            } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)

        }

    }
    
    func addPhoto() {
        let alert = UIAlertController.init(title: "Add photo", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            alert.addAction(UIAlertAction.init(title: "Take A Picture", style: UIAlertAction.Style.default, handler: { (_) in
            self.openCamera()
        }))}
        alert.addAction(UIAlertAction.init(title: "Choose From Gallery", style: UIAlertAction.Style.default, handler: { (_) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)

    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if status == .denied {
                let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)  }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                     self.present(alert, animated: true)
            } else {
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)

            }
        }
    }

    func openGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied {
            let alert = UIAlertController(title: "Galery", message: "Galery access is absolutely necessary to use this app", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)  }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                 self.present(alert, animated: true)
        } else {
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
    
    @IBAction func friendsTaped(_ sender: Any) {
        let  friendsVC = FriendsViewController()
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    @IBAction func changeNameTaped(_ sender: Any) {
        var changeNameVC = ChangeNameViewController()
        changeNameVC.userName = self.userNameLabel.text ?? ""
        self.navigationController?.pushViewController(changeNameVC, animated: true)
    }
    @IBAction func subscribesTaped(_ sender: Any) {
        let subscribesVC = SubskribesViewController()
        self.navigationController?.pushViewController(subscribesVC, animated: true)
    }
    
}
