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



extension String {
    func findMentionText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
}




class PopupViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
   
    

    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var CancellButton: UIButton!
    var categoryPicker = UIPickerView()
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleview2: UIView!
    weak var delegate: PopupDelegate?
    var photoModel : Photomodel?
   static var categories: [CategoryModel]?
    var photomodel : Photomodel?
    var row = 0;
    var annotation = MKPointAnnotation()
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.circleView.backgroundColor = .clear
        self.circleView.layer.cornerRadius = 10
        
        if let model = self.photoModel{
            self.categoryTextField.text = model.category.name
            self.descriptionTextView.text = model.description
            self.circleView.backgroundColor = UIColor.init(red: model.category.fred, green: model.category.fgreen, blue: model.category.fblue, alpha: model.category.falpha)
            if let categories = PopupViewController.categories {
                var i = 0
                while(i<categories.count){
                    if categories[i].id == model.category.id {
                        self.row = i
                    }
                    i += 1
                }
            }
            
        }
        
        
        var toolbar = UIToolbar()
        let doneButton = UIBarButtonItem.init(title: "done", style: .plain, target: self, action: #selector(pickerViewDone))
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem.init(title: "cancel", style: .plain, target: self, action: #selector(pickerViewCancel))
        toolbar.items = [cancelButton,space,doneButton]
        self.categoryTextField.inputView = categoryPicker
        self.categoryTextField.inputAccessoryView = toolbar
        toolbar.sizeToFit()
        
       
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        self.categoryPicker.backgroundColor = .white
        if self.categoryPicker != nil{
            self.categoryPicker.bounds = CGRect.init(x: self.categoryPicker.frame.origin.x, y: self.categoryPicker.frame.origin.y, width: self.categoryPicker.frame.size.width, height: 100)
            
            
            
            
        // Do any additional setup after loading the view.
    }
    }
    @objc func pickerViewDone(){
        
        self.row = self.categoryPicker.selectedRow(inComponent:0)
        if let category = PopupViewController.categories?[self.row]{
        self.categoryTextField.text = category.name
        
            
        self.circleView.backgroundColor = UIColor.init(red: category.fred, green: category.fgreen, blue: category.fblue, alpha: category.falpha)
         //   self.circleview2.backgroundColor = UIColor.init(red: category.fred, green: category.fgreen, blue: category.fblue, alpha: category.falpha)
            
        self.categoryTextField.resignFirstResponder()
        }
    }
    
    @objc func pickerViewCancel(){
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
        let hashtags = self.descriptionTextView.text.findMentionText()
        
        if let model = self.photoModel{
            
            //guard let key = ref.child("\(String(describing: Auth.auth().currentUser!.uid))/photoModels").childByAutoId().key else { return }
            //photoModel = Photomodel.init(id: model, latitude: self.annotation.coordinate.latitude, longitude:self.annotation.coordinate.longitude, category: cat, date: "", hashtags: hashtags, description: self.descriptionTextView.text, image: UIImage.init())
            if let cat = PopupViewController.categories?[row]{
            let photomodelsend = [ "photoID":  model.id,
                                   "latitude": model.latitude,
                                   "longitude": model.longitude,
                                   "date": model.date,
                                   "hashtags": model.hashtags,
                                   "description": model.description,
                                   "categoryID": cat.id] as [String : Any]
            var childUpdates = ["/\(String(describing: Auth.auth().currentUser!.uid))/photomodels/\(model.id)": photomodelsend]
             ref.updateChildValues(childUpdates)
            }
            
        }
        else{
             if let cat = PopupViewController.categories?[row]{
             guard let key = ref.child("\(String(describing: Auth.auth().currentUser!.uid))/photoModels").childByAutoId().key else { return }
            photoModel = Photomodel.init(id: key, latitude: self.annotation.coordinate.latitude, longitude:self.annotation.coordinate.longitude, category: cat, date: "", hashtags: hashtags, description: self.descriptionTextView.text, image: UIImage.init())
            let photomodelsend = [ "photoID":  key,
                                   "latitude": photoModel!.latitude,
                                   "longitude": photoModel!.longitude,
                                   "date": photoModel!.date,
                                   "hashtags": photoModel!.hashtags,
                                   "description": photoModel!.description,
                                   "categoryID": cat.id] as [String : Any]
                var childUpdates = ["/\(String(describing: Auth.auth().currentUser!.uid))/photomodels/\(key)": photomodelsend]
                 ref.updateChildValues(childUpdates)
                let ref = storageRef.child("\(String(describing: Auth.auth().currentUser!.uid))/\(key)")
                
                
                let data = self.imageView.image?.jpegData(compressionQuality: 0.7)
                // Create a reference to the file you want to upload
                
                
                // Upload the file to the path "images/rivers.jpg"
                let uploadTask = ref.putData(data!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    // Metadata contains file metadata such as size, content-type.
                    let size = metadata.size
                    // You can also access to download URL after upload.
                    ref.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                    }
                }
            }
        }
        
        
        
            
            self.delegate?.addAnnotation(model: photoModel!,image:self.imageView.image ?? UIImage.init())
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



