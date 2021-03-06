//
//  CreateAccountViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
class CreateAccountViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bottomConstraint.constant = UIScreen.main.bounds.height / 3
        self.view.layoutIfNeeded()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailTextfield.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
         repeatPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        userNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)

    }

    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        if (keyboardHeight ?? 0) - 5 > self.bottomConstraint.constant {
            self.bottomConstraint.constant = keyboardHeight ?? 0 - view.safeAreaInsets.bottom + 15
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = UIScreen.main.bounds.height / 3
        UIView.animate(withDuration: 0.5) {
        self.view.layoutIfNeeded()

        }

    }

    @objc func textFieldDidChange(textField: UITextField) {
           self.alertLabel.text = ""
           self.passwordTextField.layer.borderWidth = 0
           self.emailTextfield.layer.borderWidth = 0
           self.repeatPasswordTextField.layer.borderWidth = 0
        self.userNameTextField.layer.borderWidth = 0
       }

    @IBAction func createBtnTapped(_ sender: Any) {

        if let email = emailTextfield.text, let password = passwordTextField.text, let repeatPassword = repeatPasswordTextField.text {

            if(password == repeatPassword)  && (self.emailTextfield.text != "") && (self.userNameTextField.text != "") {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard let _ = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                self.alertLabel.text = error?.localizedDescription
                self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self.passwordTextField.layer.borderWidth = 1.0
                self.repeatPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.repeatPasswordTextField.layer.borderWidth = 1.0
                self.emailTextfield.layer.borderColor =  UIColor.red.cgColor
                self.emailTextfield.layer.borderWidth = 1.0
                self.userNameTextField.layer.borderColor =  UIColor.red.cgColor
                self.userNameTextField.layer.borderWidth = 1.0
                return
            }
            if let user  = Auth.auth().currentUser {

                   let userID = user.uid
                    let ref = Database.database().reference()

                guard ref.child("\(String(describing: userID))").key != nil else { return }
                let usernameSend = ["Username": self.userNameTextField.text!] as [String: Any]
                           let childUpdates = ["/\(String(describing: userID))": usernameSend]

                           ref.updateChildValues(childUpdates)

            self.navigationController?.popViewController(animated: true)
                }
        }
            } else {
                if(password != repeatPassword) {
                print("passwords are not the same")
                self.alertLabel.text = "password are not the same"
                self.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self.passwordTextField.layer.borderWidth = 1.0
                self.repeatPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.repeatPasswordTextField.layer.borderWidth = 1.0
            }
                if(self.userNameTextField.text == "") {
                                    self.alertLabel.text = "username cant be empty"
                                   self.userNameTextField.layer.borderColor = UIColor.red.cgColor
                                   self.userNameTextField.layer.borderWidth = 1.0
                    self.passwordTextField.layer.borderWidth = 0.0
                                       self.repeatPasswordTextField.layer.borderWidth = 0.0

                }
                if (self.emailTextfield.text == "") {
                    self.alertLabel.text = "email cant be empty"
                    self.emailTextfield.layer.borderColor = UIColor.red.cgColor
                    self.emailTextfield.layer.borderWidth = 1.0
                    self.passwordTextField.layer.borderWidth = 0.0
                    self.repeatPasswordTextField.layer.borderWidth = 0.0
                    self.userNameTextField.layer.borderWidth = 0.0
                }

            }
        } else {
            print("emptyFields")
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
