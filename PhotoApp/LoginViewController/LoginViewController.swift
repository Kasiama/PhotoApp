//
//  LoginViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var passwordAlerLabel: UILabel!

    override func viewDidLoad() {

        super.viewDidLoad()
         self.bottomConstraint.constant = UIScreen.main.bounds.height / 3
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
    }

    @objc func keyboardWillShow(notification: Notification) {
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
            if (keyboardHeight ?? 0) - 5 > self.bottomConstraint.constant {
            self.bottomConstraint.constant = keyboardHeight ?? 0 - view.safeAreaInsets.bottom+10
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

    @objc func textFieldDidChange(textField: UITextField) {
        self.passwordAlerLabel.text = ""
        self.passwordTextField.layer.borderWidth = 0
        self.emailTextField.layer.borderWidth = 0
    }

    @IBAction func signInTaped(_ sender: Any) {

        let email: String! = emailTextField.text
        let password: String! = passwordTextField.text

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                print(error.localizedDescription)
                self?.passwordAlerLabel.text = error.localizedDescription
                self?.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self?.passwordTextField.layer.borderWidth = 1.0
                self?.emailTextField.layer.borderColor =  UIColor.red.cgColor
                self?.emailTextField.layer.borderWidth = 1.0
                return
            }
            self?.view.endEditing(true)
            if let appDelegate = self?.appDelegate {
            appDelegate.setMainVCRoot()
            }
        }
    }
        @IBAction func createTaped(_ sender: Any) {
        self.view.endEditing(true)
        let vc = CreateAccountViewController()
        self.navigationController?.pushViewController(vc, animated: true)

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
