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
   var id : String
    var latitude : CLLocationDegrees
    var longitude : CLLocationDegrees
    var category : CategoryModel
    var date : String
    var hashtags : [String]
    var description : String
    var image : UIImage?{
        willSet{
        }
    }
    }

protocol PhotoAnnotationDelegate :AnyObject{
    func moveMap(zoomRegion:MKCoordinateRegion)
    
}
protocol PopupDelegate : AnyObject{
    func addAnnotation(model: Photomodel,image: UIImage)
    func movePopupVC()
}
protocol CalloutDelegate : AnyObject {
    func addPopupVC(whithImage image:UIImage, model:Photomodel?, date: Date?)
}


class MainViewController: UIViewController,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CalloutDelegate {
    
    

    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var ref: DatabaseReference!
    var selectedCategoriesArray = [CategoryModel]()
    let imagePickerController =  UIImagePickerController()
    
    private var currentCoordinate: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()
    
    var popupVC : PopupViewController?
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = Database.database().reference()
        downloadCategories()
        
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
   

    private func beginLocationUpdates(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction func currentLocationTapped(_ sender: Any) {
        if (self.currentCoordinate != nil){
        zoomToLatestLocation(with: self.currentCoordinate! )
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
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)   {
        if sender.state == UIGestureRecognizer.State.began{
            addPhoto()
            let point = sender.location(in: self.mapView)
            let view = self.mapView.hitTest(point, with: nil)
            if (self.children.count != 0){
                popupVC!.removeFromParent()
                popupVC?.view = nil
                popupVC = nil
                return
            }
            
            if view is MKAnnotationView{
                print("anot")
            }
            else{
                let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
                let ann = MKPointAnnotation()
                ann.coordinate = coordinate
               self.annotation = ann
                
            }
        }
    }
    
    
    func downloadCategories()  {
        let userID = Auth.auth().currentUser!.uid
        let selectedCategories = ref?.child(userID).child("categories") .queryOrdered(byChild: "isSelected").queryEqual(toValue: 1);
        selectedCategories?.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.selectedCategoriesArray.removeAll()
            for (categoryID, categoryInfo) in value ?? [:]{
                if let categoryIn = categoryInfo as? NSDictionary {
                let catid = categoryID as? String
                let name = categoryIn["name"] as? String
                let fred = categoryIn["fred"] as? CGFloat
                let fblue = categoryIn["fblue"] as? CGFloat
                let fgreen = categoryIn["fgreen"] as? CGFloat
                let falpha = categoryIn["falpha"] as? CGFloat
                let isSelected = categoryIn["isSelected"] as? Int
                     if (catid != nil &&  name != nil && fred != nil && fblue != nil && fgreen != nil && falpha != nil && isSelected != nil){
                let category = CategoryModel.init(id: catid!  , name: name! , fred: fred!, fgreen: fgreen!, fblue: fblue!, falpha: falpha!,isSelected:isSelected!)
                        self.selectedCategoriesArray.append(category)
                    }
            }
        }
            self.downloadPhotoModels()
            
          
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func downloadPhotoModels(){
        let userID = Auth.auth().currentUser!.uid
        self.ref?.child(userID).child("photomodels").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.mapView.removeAnnotations(self.mapView.annotations)
            for (photomodelID, photomodelInfo) in value ?? [:]{
                if  let photoIn = photomodelInfo as? NSDictionary {
                //let catid = photomodelID as! String
                let catid = photoIn["categoryID"] as? String
                let date = photoIn["date"] as? String
                let hastags = photoIn["hashtags"] as? [String]
                let latitude = photoIn["latitude"] as? CLLocationDegrees
                let longitude = photoIn["longitude"] as? CLLocationDegrees
                let photoID = photoIn["photoID"] as? String
                let description = photoIn["description"] as? String
                
                
                
                var cat:CategoryModel?
                for category in self.selectedCategoriesArray{
                    if category.id == catid{
                     cat = category
                    }
                }
                if (cat != nil && photoID != nil && latitude != nil && longitude != nil && date != nil){
                    

                    let model = Photomodel.init(id: photoID!, latitude: latitude!, longitude: longitude!, category:cat!, date: date!, hashtags: hastags ?? [""], description: description ?? "", image: UIImage.init())
                
                let a = Custom(coordinate: CLLocationCoordinate2D.init(latitude: latitude!, longitude: longitude!))
                a.color = UIColor.init(red: cat!.fred, green: cat!.fgreen, blue: cat!.fblue, alpha: cat!.falpha)
                a.photoModel = model
                self.mapView.addAnnotation(a)
                }
            
            }
          }
        })
        
        
    }
    
    func moveMap(zoomRegion: MKCoordinateRegion) {
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    func addPhoto(){
        let alert = UIAlertController.init(title:"Add photo", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction.init(title: "Take A Picture", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction.init(title: "Choose From Gallery", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
       
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == .denied){}
            else{
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func openGallery(){
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .denied){}
        else{
            self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePickerController.allowsEditing = false
                self.present(self.imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        var currentdate:Date!
        if (picker.sourceType == .camera){
            let metadata = info[UIImagePickerController.InfoKey.mediaMetadata] as! NSDictionary
            let metaDate = metadata.object(forKey: "{TIFF}") as! NSDictionary
            let dateString = metaDate.object(forKey: "DateTime") as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            currentdate = dateFormatter.date(from: dateString) ?? Date.init()
        } else {
                let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                currentdate = asset?.creationDate ?? Date.init()
        }
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if (image != nil){
            addPopupVC(whithImage: image!, model: nil, date: currentdate )
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func addPopupVC(whithImage image:UIImage,model:Photomodel?,date: Date?){
            popupVC = PopupViewController()
        PopupViewController.categories = self.selectedCategoriesArray
        let childrens = self.children
        if (childrens.count == 0){
            popupVC?.photoModel = model
            popupVC?.date = date
            self.addChild(popupVC!)
            popupVC?.view.frame = self.view.frame(forAlignmentRect: CGRect.zero)
            popupVC?.imageView.image = image
            popupVC?.imageView.contentMode = .scaleAspectFill
            popupVC?.annotation = self.annotation
            popupVC?.delegate = self
            self.view.addSubview(popupVC!.view)
            popupVC?.view.translatesAutoresizingMaskIntoConstraints = false
            let leadingConstraint = popupVC?.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40)
            let topConstraint = popupVC?.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120)
            let xConstraint = popupVC?.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
            let ylConstraint = popupVC?.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,constant: -40)
            
            if (leadingConstraint != nil && topConstraint != nil && xConstraint != nil && ylConstraint != nil  ){
            self.view.addConstraints([leadingConstraint!, topConstraint!, xConstraint!, ylConstraint!])
            }
            popupVC!.didMove(toParent: self)
        }
    }

    @IBAction func makePhotoIncurrentLocation(_ sender: Any) {
        addPhoto()
        let point = currentCoordinate
    let ann = MKPointAnnotation()
        ann.coordinate = point!
            self.annotation = ann
            }
    
}

extension MainViewController: CLLocationManagerDelegate, MKMapViewDelegate,PhotoAnnotationDelegate,PopupDelegate {
    
    
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
        if let photoModel = annotation.photoModel{
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
