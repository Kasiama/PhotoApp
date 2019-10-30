//
//  SubskribesViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/22/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase
class SubskribesViewController: UIViewController {

    @IBOutlet weak var subscribesTableView: UITableView!

    var storageRef: StorageReference = Storage.storage().reference()
    var ref: DatabaseReference = Database.database().reference()

    var searchbar = UISearchBar.init()

    var subscribers = [User]()
    var subscribersID = [String]()
    var friends = [User]()
    var friendsID = [String]()
    var isSearching = false

    var sortedSubscribes = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.sizeToFit()
      searchbar.placeholder = ""
      self.navigationItem.titleView = searchbar

      let nib = UINib.init(nibName: "FriendTableViewCell", bundle: nil)
      self.subscribesTableView.register(nib, forCellReuseIdentifier: friendCellId)
      self.subscribesTableView.dataSource = self
      self.subscribesTableView.delegate = self
      self.subscribesTableView.rowHeight = 100
      self.subscribesTableView.delegate = self
      self.subscribesTableView.tableFooterView = UIView()

       downloadSubscribesID()
    }
    func downloadSubscribesID() {
        if let user = Auth.auth().currentUser {
            let userId = user.uid
            self.ref.child(userId).child("subscribes").observe( .value) { (snapshot) in
                 self.subscribersID.removeAll()
                if let value = snapshot.value as? NSDictionary {
                   for (friendId, _) in value {
                        if let frienfID = friendId as? String {
                        self.subscribersID.append(frienfID)
                        }
                    }
                }
                self.downloadFriendsID()
            }
        }
    }

    func downloadSubscribeNames () {
         self.subscribers.removeAll()

        let subscribeGroup = DispatchGroup()

         for subscribeID in self.subscribersID {

            DispatchQueue.global().async(group: subscribeGroup) {
                subscribeGroup.enter()
               self.ref.child(subscribeID).child("Username").observeSingleEvent(of: .value) { (snapshot) in
                    if let username = snapshot.value as? String {
                        self.subscribers.append(User.init(id: subscribeID, username: username, isFriend: true))
                        subscribeGroup.leave()
                    }
                }
            }

        }

        subscribeGroup.notify(queue: DispatchQueue.main) {
            self.subscribers.sort {$0.username < $1.username}
            self.subscribesTableView.reloadData()
            print("execute")
        }

    }
    func downloadFriendsID() {
           if let user = Auth.auth().currentUser {
               let userId = user.uid
               self.ref.child(userId).child("friends").observe( .value) { (snapshot) in
                    self.friendsID.removeAll()
                   if let value = snapshot.value as? NSDictionary {
                      for (friendId, _) in value {
                           if let frienfID = friendId as? String {
                           self.friendsID.append(frienfID)
                           }
                       }
                   }
                self.subscribersID =  self.subscribersID.filter { !self.friendsID.contains($0) }
                self.downloadSubscribeNames()
               }
           }
       }

}
extension SubskribesViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
           return self.sortedSubscribes.count
        } else {
           return self.subscribers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FriendTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if isSearching {
            let uid = self.sortedSubscribes[indexPath.row].id
                   cell.friendId = self.sortedSubscribes[indexPath.row].id
                   cell.friendUserName.text = self.sortedSubscribes[indexPath.row].username
                   cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")
        } else {
            let uid = self.subscribers[indexPath.row].id
            cell.friendId = self.subscribers[indexPath.row].id
            cell.friendUserName.text = self.subscribers[indexPath.row].username
            cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            let user  = self.sortedSubscribes[indexPath.row]
            if self.subscribers.contains(user) {
                let userVC = UserViewController(status: .heSubscribeForYou, user: user)
                self.navigationController?.pushViewController(userVC, animated: true)
        }
        } else {
            let user  = self.subscribers[indexPath.row]
            let userVC = UserViewController(status: .heSubscribeForYou, user: user)
                self.navigationController?.pushViewController(userVC, animated: true)

        }
    }

}
