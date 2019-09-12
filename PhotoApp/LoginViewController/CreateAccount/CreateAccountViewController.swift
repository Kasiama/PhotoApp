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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
    }
    

    @IBAction func createBtnTapped(_ sender: Any) {
        
        if let email = emailTextfield.text, let password = passwordTextField.text, let repeatPassword = repeatPasswordTextField.text{
            if(password == repeatPassword){
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            print("\(user.email!) created")
            self.navigationController?.popViewController(animated: true)
        }
            }
            else {print("passwords are not the same")}
        }
        else{
            print("emptyFields")
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

}
