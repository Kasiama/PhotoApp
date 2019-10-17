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

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorSlideView: UIView!
    @IBOutlet weak var nameCategoryTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!

    var row: Int?
    var category: CategoryModel?
    var ref: DatabaseReference!

    var fRed: CGFloat = 0
    var fGreen: CGFloat = 0
    var fBlue: CGFloat = 0
    var fAlpha: CGFloat = 0

    weak var delegate: AddCategoryDelegate?
    override func viewDidLoad() {

        super.viewDidLoad()
          ref = Database.database().reference()

        self.bottomConstraint.constant = UIScreen.main.bounds.height / 3
        self.view.layoutIfNeeded()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        nameCategoryTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)),
                                        for: UIControl.Event.editingChanged)

        let previewView = DefaultPreviewView.init()
        previewView.side = .top
        previewView.animationDuration = 0.2
        previewView.offsetAmount = 50
        previewView.colorView.backgroundColor = UIColor.white

        let colorSlider = ColorSlider(orientation: .horizontal, previewView: previewView)
        colorSlider.gradientView.layer.borderWidth = 2.0
        colorSlider.gradientView.layer.borderColor = UIColor.white.cgColor
        colorSlider.gradientView.automaticallyAdjustsCornerRadius = false
        colorSlider.backgroundColor = UIColor.white
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)

        let vview =  UIView.init(frame: CGRect.init(x: 0, y: 0, width: 25, height: colorSlider.bounds.height+10))
        previewView.frame = vview.frame
        view.addSubview(colorSlider)

        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        let trailing =  colorSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50)
        let leading =   colorSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50)
        let top = colorSlider.topAnchor.constraint(equalTo: self.colorView.bottomAnchor, constant: 65)
        let bottom =  colorSlider.bottomAnchor.constraint(equalTo: self.addButton.topAnchor, constant: -20)
        let height = colorSlider.heightAnchor.constraint(equalToConstant: 10)
        NSLayoutConstraint.activate([leading, trailing, top, height, bottom])
        colorView.backgroundColor = UIColor.white

        if self.row != nil {
            self.nameCategoryTextField.text = category?.name
            self.fAlpha = category?.falpha ?? 1
            self.fBlue = category?.fblue ?? 0
            self.fGreen = category?.fgreen ?? 0
            self.fRed = category?.fred ?? 0
            colorView.backgroundColor = UIColor.init(red: CGFloat(self.fRed ), green: CGFloat(fGreen),
                                                     blue: CGFloat(fBlue), alpha: CGFloat(Float(fAlpha)))
            self.addButton.setTitle("Edit", for: .normal)
            } else {
        self.addButton.setTitle("Add", for: .normal)
        }
    }

    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        if (keyboardHeight ?? 0) - 5 > self.bottomConstraint.constant {
            self.bottomConstraint.constant = (keyboardHeight ?? 0) - view.safeAreaInsets.bottom+10
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant =  UIScreen.main.bounds.height / 3
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            self.view.endEditing(true)
        } else {
            return
        }
    }

    @objc func textFieldDidChange(textField: UITextField) {
        self.alertLabel.text = ""
        self.nameCategoryTextField.layer.borderWidth = 0
    }

    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color as UIColor
        color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        colorView.backgroundColor = UIColor.init(red: fRed, green: fGreen, blue: fBlue, alpha: fAlpha)
    }

    @IBAction func addTapped(_ sender: Any) {
        if self.nameCategoryTextField.text == "" {
            self.alertLabel.text = "Enter the name of Category"
            self.nameCategoryTextField.layer.borderColor = UIColor.red.cgColor
            self.nameCategoryTextField.layer.borderWidth = 1
            return
        }

        let category = CategoryModel.init(id: "", name: self.nameCategoryTextField.text ?? "",
                                          fred: fRed, fgreen: fGreen, fblue: fBlue, falpha: fAlpha, isSelected: 0)
        if self.row == nil {
      delegate?.addCategory(category: category)
        } else {
            if var cat = self.category {
                cat.name = self.nameCategoryTextField.text ?? ""
                cat.fred = fRed
                cat.fgreen = fGreen
                cat.fblue = fBlue
                cat.falpha = fAlpha
                if let row = self.row {
            delegate?.editCategory(category: cat, row: row)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
