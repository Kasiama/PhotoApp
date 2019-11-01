//
//  PopupViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/23/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class PopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var imageView: CachedImageView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var cancellButton: UIButton!
    var categoryPicker = UIPickerView()

    @IBOutlet weak var circleView: UIView!
    weak var delegate: PopupDelegate?
    var photoModel: Photomodel?
    var date: Date?
    static var categories: [CategoryModel]?
    var row = -1
    var annotation = MKPointAnnotation()

    var ref: DatabaseReference!
    var storageRef: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()

        self.circleView.backgroundColor = .clear
        self.circleView.layer.cornerRadius = 11

        let formater = DateFormatter()
        formater.dateFormat = "MMMM dd'th,' yyyy - hh:mm a"
        self.dateLabel.text = formater.string(from: date ?? Date.init())

        if let model = self.photoModel {
            let formater = DateFormatter()
            formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let date = formater.date(from: model.date )
            formater.dateFormat = "MMMM dd'th,' yyyy - hh:mm a"
            self.dateLabel.text = formater.string(from: date ?? Date.init())

            self.categoryTextField.text = model.category.name
            self.descriptionTextView.text = model.description
            self.circleView.backgroundColor = UIColor.init(red: model.category.fred, green: model.category.fgreen, blue: model.category.fblue, alpha: model.category.falpha)
            PopupViewController.categories?.enumerated().forEach({ (index, element) in
                if element.id == model.category.id {
                    self.row = index
                }
            })

        }

        if PopupViewController.categories?.count ?? 0 > 0 {
            self.setupCategoryTextField()
        } else {
            self.categoryTextField.isEnabled = false

        }
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.categoryPicker.backgroundColor = .white

        let image = self.imageView.image
        let resizebleImage = image?.resizableImage(withCapInsets: UIEdgeInsets.init(top: self.imageView.frame.origin.y,
                                                                                        left: self.imageView.frame.origin.x,
                                                                                        bottom: self.imageView.frame.height,
                                                                                        right: self.view.frame.width))
        self.imageView.image = resizebleImage
        addBackgroundButton()
            }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layer.shadowPath =
            UIBezierPath(roundedRect: self.view.bounds ,
                         cornerRadius: self.view.layer.cornerRadius ).cgPath
        self.view.layer.shadowColor = UIColor.black.cgColor
          self.view.layer.shadowOpacity = 0.5
          self.view.layer.shadowOffset = CGSize(width: 10, height: 10)
          self.view.layer.shadowRadius = 1
        imageView.layer.cornerRadius = 5

    }

    func setupCategoryTextField() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem.init(title: "done", style: .plain, target: self, action: #selector(pickerViewDone))
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem.init(title: "cancel", style: .plain, target: self, action: #selector(pickerViewCancel))
        toolbar.items = [cancelButton, space, doneButton]
        self.categoryTextField.inputView = categoryPicker
        self.categoryTextField.inputAccessoryView = toolbar
        toolbar.sizeToFit()
    }

    fileprivate func addBackgroundButton() {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor)
            ])
        button.addTarget(self, action: #selector(didTouchUpInCallout(_:)), for: .touchUpInside)
    }

    @objc func didTouchUpInCallout(_ sender: Any) {
        if let photomodel = self.photoModel {
            let chVC = FullImageViewController(id: photomodel.id, description: photoModel?.description)
            chVC.photoDescription = photomodel.description
            chVC.hastags = self.photoModel?.hashtags
            chVC.date = self.dateLabel.text
            self.parent?.navigationController?.pushViewController(chVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Save Photo", message: "To continue please save this photo", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                                self.present(alert, animated: true)
        }
        }

    @objc func pickerViewDone() {
        self.row = self.categoryPicker.selectedRow(inComponent: 0)
        if let category = PopupViewController.categories?[self.row] {
        self.categoryTextField.text = category.name
        self.circleView.backgroundColor = UIColor.init(red: category.fred, green: category.fgreen, blue: category.fblue, alpha: category.falpha)
        self.categoryTextField.resignFirstResponder()
        }
    }

    @objc func pickerViewCancel() {
        self.categoryTextField.resignFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PopupViewController.categories?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PopupViewController.categories?[row].name ?? ""
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.delegate?.movePopupVC()
    }

    @IBAction func doneTapped(_ sender: Any) {
        if self.row == -1 {
            let alert = UIAlertController(title: "Choose Category", message: "To save please choose category", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                                self.present(alert, animated: true)
            return
        }

        if let user  = Auth.auth().currentUser {
               let userID = user.uid
        let hashtags = self.descriptionTextView.text.findMentionText()
        self.photoModel?.hashtags = hashtags
        self.photoModel?.description = self.descriptionTextView.text
        if let model = self.photoModel {
            if let cat = PopupViewController.categories?[row] {
            let photomodelsend = [ "photoID": model.id,
                                   "latitude": model.latitude,
                                   "longitude": model.longitude,
                                   "date": model.date,
                                   "hashtags": model.hashtags,
                                   "description": model.description,
                                   "categoryID": cat.id] as [String: Any]
                let childUpdates = ["/\(String(describing: userID))/photomodels/user/\(model.id)": photomodelsend]
             ref.updateChildValues(childUpdates)
            }
            } else if let cat = PopupViewController.categories?[row] {
             guard let key = ref.child("\(String(describing: userID))/photoModels/user").childByAutoId().key else { return }
                var stringDate = ""
                if let date = self.date {
                let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy:MM:dd hh:mm:ss"
                 stringDate = dateformatter.string(from: date)
                }

                let model = Photomodel.init(id: key, latitude: self.annotation.coordinate.latitude,
                                            longitude: self.annotation.coordinate.longitude, category: cat,
                                            date: stringDate, hashtags: hashtags,
                                            description: self.descriptionTextView.text, image: UIImage.init())
                self.photoModel = model
                let photomodelsend = [ "photoID": key,
                                   "latitude": model.latitude,
                                   "longitude": model.longitude,
                                   "date": model.date,
                                   "hashtags": model.hashtags,
                                   "description": model.description,
                                   "categoryID": cat.id] as [String: Any]
                let childUpdates = ["/\(String(describing: userID))/photomodels/user/\(key)": photomodelsend]
                 ref.updateChildValues(childUpdates)
                let ref = storageRef.child("\(String(describing: userID))/\(key)")

                if let image = self.imageView.image, let key = photoModel?.id {
                CachedImageView.imageCashe.setObject(image, forKey: key as NSString)
                    if  let data = image.jpegData(compressionQuality: 0.7) {
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
            if let photoModel = self.photoModel {
        self.delegate?.addAnnotation(model: photoModel, image: self.imageView.image ?? UIImage.init())
            }
        }
        }

}
