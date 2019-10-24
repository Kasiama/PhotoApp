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
        self.usernameLabel.text = self.user.username
        self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
        setupDesign()
        setupObservers()
    }
    
    
    func setupObservers(){
        if let userID = Auth.auth().currentUser?.uid{
            self.ref.child(userID).child("subscribes").child(user.id).removeAllObservers()
            self.ref.child(user.id).child("subscribes").child(userID).removeAllObservers()
            
                switch status {
                case .Friend:
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == "1" {
                            self.ref.child(self.user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (dataSnapshot) in
                                if (dataSnapshot.value as? String) != "1" {
                                    self.status = .heSubscribeForYou
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                        else{
                            self.ref.child(self.user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (dataSnapshot) in
                                if (dataSnapshot.value as? String) == "1" {
                                    self.status = .youSubsribeForHim
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                                else{
                                    self.status = .user
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                        
                    }
                    self.ref.child(user.id).child("subscribes").child(userID).observe(.value) { (snapshot) in
                                           if (snapshot.value as? String) == "1" {
                                               self.ref.child(userID).child("subscribes").child(self.user.id).observeSingleEvent(of: .value) { (dataSnapshot) in
                                                   if (dataSnapshot.value as? String) != "1" {
                                                       self.status = .heSubscribeForYou
                                                       self.setupObservers()
                                                       self.setupDesign()
                                                   }
                                               }
                                           }
                                           else{
                                               self.ref.child(userID).child("subscribes").child(self.user.id).observeSingleEvent(of: .value) { (dataSnapshot) in
                                                   if (dataSnapshot.value as? String) == "1" {
                                                       self.status = .youSubsribeForHim
                                                       self.setupObservers()
                                                       self.setupDesign()
                                                   }
                                                   else{
                                                       self.status = .user
                                                       self.setupObservers()
                                                       self.setupDesign()
                                                   }
                                               }
                                           }
                                           
                                       }
                case .youSubsribeForHim:
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                                           if (snapshot.value as? String) == "1" {
                                               self.ref.child(self.user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                                                   if (snapshot.value as? String) == "1" {
                                                       print(self.status)
                                                       self.status = .Friend
                                                       self.ref.child(self.user.id).child("friends").child(userID).setValue("1")
                                                       self.ref.child(userID).child("friends").child(self.user.id).setValue("1")
                                                       self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                                       self.setupObservers()
                                                       self.setupDesign()
                                                   }
                                                else{
                                                            self.status = .heSubscribeForYou
                                                            self.setupObservers()
                                                            self.setupDesign()
                                                                               }
                                               }
                                           }
                        
                                       }
                    
                    self.ref.child(user.id).child("subscribes").child(userID).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == "1" {
                            self.ref.child(userID).child("subscribes").child(self.user.id).observeSingleEvent(of: .value) { (snapshot) in
                                if (snapshot.value as? String) == "1" {
                                    print(self.status)
                                    self.status = .Friend
                                    self.ref.child(self.user.id).child("friends").child(userID).setValue("1")
                                    self.ref.child(userID).child("friends").child(self.user.id).setValue("1")
                                    self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                        else{
                            self.status = .user
                            self.setupObservers()
                            self.setupDesign()
                        }
                    }
                    
                    
                    
                case .heSubscribeForYou:
                    self.ref.child(user.id).child("subscribes").child(userID).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == "1" {
                            self.ref.child(userID).child("subscribes").child(self.user.id).observeSingleEvent(of: .value) { (snapshot) in
                                if (snapshot.value as? String) == "1" {
                                    print(self.status)
                                    self.status = .Friend
                                    self.ref.child(self.user.id).child("friends").child(userID).setValue("1")
                                    self.ref.child(userID).child("friends").child(self.user.id).setValue("1")
                                    self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                                else{
                                    self.status = .youSubsribeForHim
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                        
                    }
                    
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == "1" {
                            self.ref.child(self.user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                                if (snapshot.value as? String) == "1" {
                                    print(self.status)
                                    self.status = .Friend
                                    self.ref.child(self.user.id).child("friends").child(userID).setValue("1")
                                    self.ref.child(userID).child("friends").child(self.user.id).setValue("1")
                                    self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                    self.setupObservers()
                                    self.setupDesign()
                                }
                            }
                        }
                        else{
                        self.status = .user
                        self.setupObservers()
                        self.setupDesign()
                        }
                    }
                    
                    
                    
                    
                case .user:
                    self.ref.child(user.id).child("subscribes").child(userID).observe(.value) { (snapshot) in
                        if (snapshot.value as? String) == "1" {
                            print(self.status)
                            self.status = .youSubsribeForHim
                            self.ref.child(self.user.id).child("subscribes").child(userID).removeAllObservers()
                            //self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                            self.setupObservers()
                            self.setupDesign()
                        }
                    }
                    self.ref.child(userID).child("subscribes").child(user.id).observe(.value) { (snapshot) in
                                           if (snapshot.value as? String) == "1" {
                                               print(self.status)
                                               self.status = .heSubscribeForYou
                                               self.ref.child(userID).child("subscribes").child(self.user.id).removeAllObservers()
                                               // self.ref.child(self.user.id).child("subscribes").child(userID).removeAllObservers()
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
            
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("In Friends", for: .normal)
            
            
            
        case .youSubsribeForHim:
           // self.usernameLabel.text = self.user.username
            //self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground-1")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("You subscribed", for: .normal)
            
        case .heSubscribeForYou:
           // self.usernameLabel.text = self.user.username
           // self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
            self.friendBtn.backgroundColor = UIColor.init(named: "subfribackground-1")
            self.friendBtn.setTitleColor(UIColor.init(named: "subfrietintcolor"), for: .normal)
            self.friendBtn.setTitle("Subscribed", for: .normal)
            
        default:
           // self.usernameLabel.text = self.user.username
           // self.avatarImageView.loadImageWhithoutUser(idString: "\(user.id)/\(user.id)")
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
                self.ref.child(user.id).child("subscribes").child(userID).removeValue()
               
                
            
        case .heSubscribeForYou:
            self.ref.child(user.id).child("subscribes").child(userID).setValue("1")
            
        
        case.youSubsribeForHim:
            self.ref.child(user.id).child("subscribes").child(userID).removeValue()
           
            
        case .user :
            ref.child(user.id).child("subscribes").child(userID).setValue("1")
            
        default:
            print("rfufrhfreihfer")
        }
        }
        
        
        
        
    
        
    }

    
    
}
