//
//  AddCategoryViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/12/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import ColorSlider
class AddCategoryViewController: UIViewController {
    

    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSlideView: UIView!
    @IBOutlet weak var nameCategoryTextField: UITextField!
    
    var fRed : CGFloat = 0
    var fGreen : CGFloat = 0
    var fBlue : CGFloat = 0
    var fAlpha: CGFloat = 0
    
    weak var delegate: AddCategoryDelegate?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let colorSlider = ColorSlider(orientation: .horizontal, previewSide: .bottom)
        colorSlider.frame = colorSlideView.frame
        colorSlider.gradientView.layer.borderWidth = 2.0
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        colorSlider.gradientView.automaticallyAdjustsCornerRadius = false
        view.addSubview(colorSlider)
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
        
        
        
        colorView.backgroundColor = UIColor.red
    }

    @objc func changedColor(_ slider: ColorSlider) {
        let a = slider
        var color = slider.color as UIColor
        
        
        
        color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        
        colorView.backgroundColor = UIColor.init(red: fRed, green: fGreen, blue: fBlue, alpha: fAlpha)
     
    
        
        
        
    }
    @IBAction func addTapped(_ sender: Any) {
        let category = CategoryModel.init(name: self.nameCategoryTextField.text!, fred: Float(fRed), fgreen: Float(fGreen), fblue: Float(fBlue), falpha: Float(fAlpha))
      delegate?.addCategory(category: category)
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
