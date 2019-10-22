//
//  ChangeNameViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/18/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

class ChangeNameViewController: UIViewController {

    var userName = ""
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var usernametextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        usernametextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        usernametextField.text = userName
        // Do any additional setup after loading the view.
    }
    @objc func textFieldDidChange(textField: UITextField) {
              self.alertLabel.text = ""
           self.usernametextField.layer.borderWidth = 0
          }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func saveBtnTaped(_ sender: Any) {
        if let newusername = self.usernametextField.text {
            if newusername != "" {
        if let user = Auth.auth().currentUser{
            let userID = user.uid
            let ref = Database.database().reference()
             let childUpdates = ["/\(String(describing: userID))/Username": newusername]
            ref.updateChildValues(childUpdates)
            
        self.navigationController?.popViewController(animated: true)
        }
            }
            else {
                self.usernametextField.layer.borderColor = UIColor.red.cgColor
                self.usernametextField.layer.borderWidth = 1.0
                alertLabel.text = "Cant be empty username"
            }
        }
    }
}
