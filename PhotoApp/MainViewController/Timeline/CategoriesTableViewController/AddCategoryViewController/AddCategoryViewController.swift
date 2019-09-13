//
//  AddCategoryViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/12/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import ColorSlider
import Firebase


class AddCategoryViewController: UIViewController {
    

    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSlideView: UIView!
    @IBOutlet weak var nameCategoryTextField: UITextField!
     var ref: DatabaseReference!
    
    var fRed : CGFloat = 0
    var fGreen : CGFloat = 0
    var fBlue : CGFloat = 0
    var fAlpha: CGFloat = 0
    
    weak var delegate: AddCategoryDelegate?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        let previewView = DefaultPreviewView.init()
        previewView.side = .top
        previewView.animationDuration = 0.2
        previewView.offsetAmount = 50

        //self.view.backgroundColor = UIColor.black
        let colorSlider = ColorSlider(orientation: .horizontal,previewView: previewView)
        colorSlider.gradientView.layer.borderWidth = 2.0
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        colorSlider.gradientView.automaticallyAdjustsCornerRadius = false
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    
       colorSlider.frame = self.colorSlideView.frame
       // colorSlider.bounds = self.colorSlideView.bounds
        let vview =  UIView.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: colorSlider.bounds.height+10))
        previewView.frame = vview.frame
        view.addSubview(colorSlider)
        //view.addSubview(previewView)
       
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([

          
            
            ])
        
        
        colorView.backgroundColor = UIColor.red
        
        
        
        
        
    }

    @objc func changedColor(_ slider: ColorSlider) {
        let a = slider
        var color = slider.color as UIColor
        
        
        
        color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        
        colorView.backgroundColor = UIColor.init(red: fRed, green: fGreen, blue: fBlue, alpha: fAlpha)
     
    
        
        
        
    }
    @IBAction func addTapped(_ sender: Any) {
        let category = CategoryModel.init(id: "", name: self.nameCategoryTextField.text!, fred: Float(fRed), fgreen: Float(fGreen), fblue: Float(fBlue), falpha: Float(fAlpha),isSelected: 0)
            guard let key = ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").childByAutoId().key else { return }
            //ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").childByAutoId().setValue(category.name)
        let categorysend = ["name":category.name,
                        "fred": category.fred,
                          "fgreen": category.fgreen,
                            "fblue": category.fblue,
                            "falpha": category.falpha,
                            "isSelected":category.isSelected      ] as [String : Any]
        let childUpdates = ["/\(String(describing: Auth.auth().currentUser!.uid))/categories/\(key)": categorysend]
        
        ref.updateChildValues(childUpdates)
        
        
      delegate?.addCategory(category: category)
        self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
