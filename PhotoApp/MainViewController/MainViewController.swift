//
//  MainViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import MapKit
import Photos
import Firebase

struct Photomodel {
   var id: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var category: CategoryModel
    var date: String
    var hashtags: [String]
    var description: String
    var image: UIImage? {
        willSet {
        }
    }
    }

protocol PhotoAnnotationDelegate: AnyObject {
    func moveMap(zoomRegion: MKCoordinateRegion)

}
protocol PopupDelegate: AnyObject {
    func addAnnotation(model: Photomodel, image: UIImage)
    func movePopupVC()
}
protocol CalloutDelegate: AnyObject {
    func addPopupVC(whithImage image: UIImage, model: Photomodel?, date: Date?)
}

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CalloutDelegate {

    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var ref: DatabaseReference!
    var selectedCategoriesArray = [CategoryModel]()
    let imagePickerController =  UIImagePickerController()

    private var currentCoordinate: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    var popupVC: PopupViewController?
    var annotation = MKPointAnnotation()

    var ylConstraint: NSLayoutConstraint?
    var topConstraint: NSLayoutConstraint?

    var upsize: CGFloat = 0
    var uosize: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        downloadCategories()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.mapView.delegate = self
        let long = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressed(sender:)) )
        self.mapView.addGestureRecognizer(long)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        imagePickerController.delegate = self
        }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func keyboardWillShow(notification: Notification) {
        print("appear")
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        uosize = UIScreen.main.bounds.height / 2 - (ylConstraint?.constant ?? 0)
        uosize -=  ( (self.popupVC?.view.bounds.height ?? 0) / 2 )

        if (keyboardHeight ?? 0) > uosize {
            self.upsize = (keyboardHeight ?? 0) - uosize
            self.topConstraint?.constant =  (self.topConstraint?.constant ?? upsize) - upsize
            self.ylConstraint?.constant =  (self.ylConstraint?.constant ?? upsize) - upsize
            }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            }
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.topConstraint?.constant =  (self.topConstraint?.constant ?? -upsize) + upsize
        self.ylConstraint?.constant =  (self.ylConstraint?.constant ?? -upsize) +  upsize
        UIView.animate(withDuration: 0.5) {
        self.view.layoutIfNeeded()
        }

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first

        if touch?.view != self.popupVC?.descriptionTextView {

            self.view.endEditing(true)

        } else {
            //self.view.endEditing(true)
            return
        }
    }

    private func beginLocationUpdates(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }

    @IBAction func currentLocationTapped(_ sender: Any) {
        if let currentCoordinate = self.currentCoordinate {
        zoomToLatestLocation(with: currentCoordinate)
        }
        let annotations = self.mapView.annotations
        let coordinate = Custom.init(coordinate: annotations[0].coordinate)
        self.mapView.removeAnnotation(coordinate)
    }

    let geocoder = CLGeocoder()
    func addAnnotation(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = placemark.name
                annotation.subtitle = placemark.locality
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            addPhoto()
            let point = sender.location(in: self.mapView)
            let view = self.mapView.hitTest(point, with: nil)
            if self.children.count != 0 {
                popupVC?.removeFromParent()
                popupVC?.view = nil
                popupVC = nil
                return
            }

            if view is MKAnnotationView {
                print("anot")
            } else {
                let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
                let ann = MKPointAnnotation()
                ann.coordinate = coordinate
               self.annotation = ann

            }
        }
    }

    func downloadCategories() {
       if let user  = Auth.auth().currentUser {
               let userID = user.uid
        let selectedCategories = ref?.child(userID).child("categories") .queryOrdered(byChild: "isSelected").queryEqual(toValue: 1)
        selectedCategories?.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.selectedCategoriesArray.removeAll()
            for (categoryID, categoryInfo) in value ?? [:] {
                if let categoryIn = categoryInfo as? NSDictionary,
                    let catid = categoryID as? String,
                    let name = categoryIn["name"] as? String,
                    let fred = categoryIn["fred"] as? CGFloat,
                    let fblue = categoryIn["fblue"] as? CGFloat,
                    let fgreen = categoryIn["fgreen"] as? CGFloat,
                    let falpha = categoryIn["falpha"] as? CGFloat,
                    let isSelected = categoryIn["isSelected"] as? Int {
               let category = CategoryModel.init(id: catid, name: name, fred: fred, fgreen: fgreen, fblue: fblue, falpha: falpha, isSelected: isSelected)
                        self.selectedCategoriesArray.append(category)
            }
        }
            self.downloadPhotoModels()

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    }

    func downloadPhotoModels() {
        if let user  = Auth.auth().currentUser {
        let userID = user.uid
        self.ref?.child(userID).child("photomodels").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.mapView.removeAnnotations(self.mapView.annotations)
            for (_, photomodelInfo) in value ?? [:] {
                if  let photoIn = photomodelInfo as? NSDictionary,
                    let latitude = photoIn["latitude"] as? CLLocationDegrees,
                    let longitude = photoIn["longitude"] as? CLLocationDegrees,
                    let catid = photoIn["categoryID"] as? String,
                    let date = photoIn["date"] as? String,
                    let photoID = photoIn["photoID"] as? String {

                    let hastags = photoIn["hashtags"] as? [String]
                    let description = photoIn["description"] as? String
                for category in self.selectedCategoriesArray {
                    if category.id == catid {
                    let model = Photomodel.init(id: photoID, latitude: latitude,
                                                longitude: longitude, category: category,
                                                date: date, hashtags: hastags ?? [""],
                                                description: description ?? "", image: UIImage.init())
                let customAnnotation = Custom(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude))
                customAnnotation.color = UIColor.init(red: category.fred, green: category.fgreen, blue: category.fblue, alpha: category.falpha)
                customAnnotation.photoModel = model
                self.mapView.addAnnotation(customAnnotation)
                    }
                }
            }
          }
        })

        }
    }

    func moveMap(zoomRegion: MKCoordinateRegion) {
        mapView.setRegion(zoomRegion, animated: true)
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

        var currentdate: Date!
        if picker.sourceType == .camera {
            let metadata = info[UIImagePickerController.InfoKey.mediaMetadata] as? NSDictionary
            let metaDate = metadata?.object(forKey: "{TIFF}") as? NSDictionary
            let dateString = metaDate?.object(forKey: "DateTime") as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            currentdate = dateFormatter.date(from: dateString ?? "") ?? Date.init()
        } else {
                let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                currentdate = asset?.creationDate ?? Date.init()
        }
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let img = image {
            addPopupVC(whithImage: img, model: nil, date: currentdate )
        }
        self.dismiss(animated: true, completion: nil)
    }

    func addPopupVC(whithImage image: UIImage, model: Photomodel?, date: Date?) {
            popupVC = PopupViewController()

        PopupViewController.categories = self.selectedCategoriesArray
        let childrens = self.children
        if childrens.count == 0 {

            popupVC?.photoModel = model
            popupVC?.date = date
            self.addChild(popupVC ?? UIViewController())
            popupVC?.view.frame = self.view.frame(forAlignmentRect: CGRect.zero)
            popupVC?.imageView.image = image
            popupVC?.imageView.contentMode = .scaleAspectFill
            popupVC?.annotation = self.annotation
            popupVC?.descriptionTextView.layer.borderWidth = 1
            popupVC?.descriptionTextView.layer.borderColor = UIColor.black.cgColor
            popupVC?.delegate = self
            popupVC?.view.layer.cornerRadius = 10
            popupVC?.view.clipsToBounds = true

            popupVC?.view.layer.masksToBounds = false

            self.view.addSubview(popupVC?.view ?? UIView())
            popupVC?.view.translatesAutoresizingMaskIntoConstraints = false
            if let leadingConstraint = popupVC?.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 35),
                let topConstraint = popupVC?.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.height / 4.5),
            let xConstraint = popupVC?.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
                let ylConstraint = popupVC?.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20) {

                self.ylConstraint = ylConstraint
                self.topConstraint = topConstraint
            self.view.addConstraints([leadingConstraint, topConstraint, xConstraint, ylConstraint])

            }
            popupVC?.didMove(toParent: self)

        }
    }

    @IBAction func makePhotoIncurrentLocation(_ sender: Any) {
        addPhoto()
        if let point = currentCoordinate {
    let ann = MKPointAnnotation()
        ann.coordinate = point
            self.annotation = ann
        }
            }

}

extension MainViewController: CLLocationManagerDelegate, MKMapViewDelegate, PhotoAnnotationDelegate, PopupDelegate {

    func addAnnotation(model: Photomodel, image: UIImage) {
        let cat = model.category
        let annotation = Custom(coordinate: self.annotation.coordinate)
        annotation.image = image
        annotation.color = UIColor.init(red: cat.fred, green: cat.fgreen, blue: cat.fblue, alpha: cat.falpha)
        annotation.photoModel = model
        self.mapView.addAnnotation(annotation)
        self.popupVC?.removeFromParent()
        popupVC?.view = nil
        popupVC = nil

    }

    func movePopupVC() {
        self.popupVC?.removeFromParent()
        popupVC?.view = nil
        popupVC = nil
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         guard let annotation = annotation as? Custom else { return nil }

        let customAnnotationViewIdentifier = "MyAnnotation"

        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier) as? PhotoAnnotationView
        if let photoModel = annotation.photoModel {
                pin = PhotoAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier, model: photoModel)
                pin?.delegate = self
                pin?.calloutDelegate = self
                }

        pin?.markerTintColor = annotation.color
        pin?.glyphText = ""
        return pin
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")

        guard let latestLocation = locations.first else { return }

        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}
