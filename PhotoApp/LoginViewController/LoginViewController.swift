//
//  LoginViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailAlertLabel: UILabel!
    @IBOutlet weak var passwordAlerLabel: UILabel!
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
         self.bottomConstraint.constant = UIScreen.main.bounds.height / 3
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
       // return
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        let keyboardHeight = keyboardSize?.height
        
            if (keyboardHeight!-5 > self.bottomConstraint.constant){
            self.bottomConstraint.constant = keyboardHeight! - view.safeAreaInsets.bottom+10
            }
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
            }
        
        
    }
    
    @objc func keyboardWillHide(notification: Notification){
        //return
        self.bottomConstraint.constant =  UIScreen.main.bounds.height / 3 // or change according to your logic
        
        UIView.animate(withDuration: 0.5){
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    @IBAction func signInTaped(_ sender: Any) {
        
        let email:String! = emailTextField.text
        let password:String! = passwordTextField.text

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            //guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self?.passwordAlerLabel.text = error.localizedDescription
                self?.passwordTextField.layer.borderColor = UIColor.red.cgColor
                self?.passwordTextField.layer.borderWidth = 1.0;
                self?.emailTextField.layer.borderColor =  UIColor.red.cgColor
                self?.emailTextField.layer.borderWidth = 1.0;
                let alert = UIAlertController(title: "Alert", message: ".", preferredStyle: .alert)
                return
            }
            self?.view.endEditing(true)
         let a = self?.appDelegate
            a?.setMainVCRoot()
        }
    }
        @IBAction func CreateTaped(_ sender: Any) {
        self.view.endEditing(true)
        let vc = CreateAccountViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view{
            self.view.endEditing(true)
        }
        else {
            return
        }
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        self.passwordAlerLabel.text = ""
        self.passwordTextField.layer.borderWidth = 0;
        self.emailTextField.layer.borderWidth = 0;
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
