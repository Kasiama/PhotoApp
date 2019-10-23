//
//  UserViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/21/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
enum Status {
    case Friend, youSubsribeForHim, heSubscribeForYou, user
}


class UserViewController: UIViewController {

    var status:Status?
    var user:User = User()
    @IBOutlet weak var avatarImageView: CachedImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendBtn: UIButton!
    var isFriend = false
    var isUser = false
    var isSubskribe = false
    var ref = Database.database().reference()
    
    
    convenience init (status:Status, user: User){
        self.init()
        self.user = user
        self.status = status
    }
    convenience init (isaFriend:Bool,user: User){
       self.init()
        self.status = .user
       if isaFriend{
            self.user = user
           self.status = .Friend
       }
       else{
         self.user = user
       
    }
    
   }
    
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        setupObservers()
    }
    
    func setupObservers(){
        if let userID = Auth.auth().currentUser?.uid{
            
                switch status {
                case .Friend:
                    self.ref.child(user.id).child("subscribes").child(userID).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) != nil {
                            self.ref.child(self.user.id).child("subscribes").child(userID).removeAllObservers()
                            self.status = .youSubsribeForHim
                            self.setupObservers()
                            self.setupDesign()
                            
                        }
                    }
                case .youSubsribeForHim:
                    self.ref.child(user.id).child("friends").child(userID).observe(.value) { (snapshot) in
                                       if (snapshot.value as? String) != nil {
                                        self.ref.child(self.user.id).child("friends").child(userID).removeAllObservers()
                                           self.status = .Friend
                                        self.setupObservers()
                                           self.setupDesign()
                                       }
                                   }
                case .heSubscribeForYou:
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == nil {
                            self.ref.child(userID).child("friends").child(self.user.id).observeSingleEvent(of: .value) { (snapshot) in
                                if (snapshot.value as? String) == nil {
                                    self.status = .user
                                    self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                    }
                    
                case .user:
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) != nil {
                            self.status = .heSubscribeForYou
                            self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                            self.setupObservers()
                            self.setupDesign()
                        }
                    }
                default:
                    print("kffk")
                }
            
        }
    }
    func setupDesign(){
        switch status {
        case .Friend:
            self.usernameLabel.text = self.user.username
            self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("In Friends", for: .normal)
            
            
            
        case .youSubsribeForHim:
            self.usernameLabel.text = self.user.username
            self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground-1")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("You subscribed", for: .normal)
            
        case .heSubscribeForYou:
            self.usernameLabel.text = self.user.username
            self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground-1")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("Subscribed", for: .normal)
            
        default:
            self.usernameLabel.text = self.user.username
            self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfrietintcolor")
            self.friendBtn.setTitleColor(UIColor.white, for: .normal)
            self.friendBtn.setTitle("Add to Friends", for: .normal)
        }
    }

    @IBAction func btnTaped(_ sender: Any) {
         if let userID = Auth.auth().currentUser?.uid {
        switch status {
        case .Friend:
                self.ref.child(userID).child("friends").child(user.id).removeValue()
                self.ref.child(user.id).child("friends").child(userID).removeValue()
                self.ref.child(userID).child("friends").child(user.id).removeAllObservers()
                self.ref.child(user.id).child("friends").child(userID).removeAllObservers()
                ref.child(userID).child("subscribes").child(user.id).setValue("")
                self.status = .heSubscribeForYou
                setupDesign()
                
            
        case .heSubscribeForYou:
            self.ref.child(userID).child("subscribes").child(user.id).removeValue()
            ref.child(userID).child("friends").child(user.id).setValue("")
            ref.child(user.id).child("friends").child(userID).setValue("")
            //changeCategories()
            self.status = .Friend
            setupDesign()
            
        
        case.youSubsribeForHim:
            self.ref.child(user.id).child("subscribes").child(userID).removeValue()
            self.status = .user
            setupDesign()
            
        case .user :
            ref.child(user.id).child("subscribes").child(userID).setValue("")
            self.status = .youSubsribeForHim
            setupDesign()
            
        default:
            print("rfufrhfreihfer")
        }
        }
        
        
        
        
    
        
    }
    func changeCategories() {
        if let user  = Auth.auth().currentUser {
        let userID = user.uid
        let selectedCategoriesRef = ref.child(userID).child("categories").queryOrdered(byChild: "isSelected").queryEqual(toValue: 1)
            selectedCategoriesRef.observe( .value, with: { (snapshot) in
                if  let value = snapshot.value as? NSDictionary{
                self.ref.child(self.user.id).child("friends").child(userID).setValue(value)
                }
        }) { (error) in
            print(error.localizedDescription)
        }
            
            let friendSelectedCategoriesRef = ref.child(self.user.id).child("categories").queryOrdered(byChild: "isSelected").queryEqual(toValue: 1)
            friendSelectedCategoriesRef.observe(.value, with: { (snapshot) in
                    if  let value = snapshot.value as? NSDictionary{
                        self.ref.child(userID).child("friends").child(self.user.id).setValue(value)
                    }
            }) { (error) in
                print(error.localizedDescription)
            }
    }
    }
    
    
}
