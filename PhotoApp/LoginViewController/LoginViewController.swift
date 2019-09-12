//
//  LoginViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func signInTaped(_ sender: Any) {
        
        let email:String! = emailTextField.text
        let password:String! = passwordTextField.text

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            //guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController(title: "Alert", message: ".", preferredStyle: .alert)
                return
            }
         let a = self?.appDelegate
            a?.setMainVCRoot()
        }
    }
        @IBAction func CreateTaped(_ sender: Any) {
        let vc = CreateAccountViewController()
        self.navigationController?.pushViewController(vc, animated: false)
        
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
