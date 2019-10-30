//
//  FriendsViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/18/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

struct User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.username < rhs.username
    }
    static func ==(lhs: User, rhs: User) -> Bool {
        if lhs.id == rhs.id, lhs.username == lhs.username {
            return true
        }
        return false
       }

    var id: String = ""
    var username: String = ""
    var isFriend = false
}

    var friendCellId = "FriendTableViewCell"

class FriendsViewController: UIViewController {

    @IBOutlet weak var friendsTableView: UITableView!

    var storageRef: StorageReference = Storage.storage().reference()
    var ref: DatabaseReference = Database.database().reference()

    var searchMessage = ""
    var searchbar = UISearchBar.init()

    var friends = [User]()
    var friendsId = [String]()

    var allUsers = [User]()

    var subscribesID = [String]()

    var isAllUsers = false
    var isSubskribes = false
    var isSearching = false

    var sortedFriends = [User]()
    var sortedAllUsers = [User]()

    convenience init (isAllFriends: Bool) {
        self.init()
        self.isAllUsers = isAllFriends
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchbar.sizeToFit()
        searchbar.placeholder = ""
        searchbar.delegate = self
        self.navigationItem.titleView = searchbar

        if (self.isAllUsers == false) {
         self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "AllUsers", style: UIBarButtonItem.Style.done, target: self, action: #selector(allFriendsTaped))
        }

        let nib = UINib.init(nibName: "FriendTableViewCell", bundle: nil)
        self.friendsTableView.register(nib, forCellReuseIdentifier: friendCellId)
        self.friendsTableView.dataSource = self
        self.friendsTableView.delegate = self
        self.friendsTableView.rowHeight = 105
        self.friendsTableView.delegate = self
        self.friendsTableView.tableFooterView = UIView()

        if isAllUsers {
            downloadAllUsers()
        } else {
             downloadFriendsID()
        }

    }

    @objc func allFriendsTaped() {
         let allFriendsVC = FriendsViewController(isAllFriends: true)
        self.navigationController?.pushViewController(allFriendsVC, animated: true)

    }

    func downloadFriendsID() {
        if let user = Auth.auth().currentUser {
            let userId = user.uid
            self.ref.child(userId).child("friends").observe( .value) { (snapshot) in
                 self.friendsId.removeAll()
                if let value = snapshot.value as? NSDictionary {
                   for (friendId, _) in value {
                        if let frienfID = friendId as? String {
                        self.friendsId.append(frienfID)
                        }
                    }
                }
                self.downloadFriendsNames()
            }
        }
    }

    func downloadFriendsIDWithoutObserver() {
           if let user = Auth.auth().currentUser {
               let userId = user.uid
            self.ref.child(userId).child("friends").observeSingleEvent( of: .value) { (snapshot) in
                    self.friendsId.removeAll()
                   if let value = snapshot.value as? NSDictionary {
                      for (friendId, _) in value {
                           if let frienfID = friendId as? String {
                           self.friendsId.append(frienfID)
                           }
                       }
                   }
                   self.downloadFriendsNames()
               }
           }
       }

    func downloadFriendsNames () {
         self.friends.removeAll()

        let frienGroup = DispatchGroup()

         for friendID in self.friendsId {

            DispatchQueue.global().async(group: frienGroup) {
                frienGroup.enter()
               self.ref.child(friendID).child("Username").observeSingleEvent(of: .value) { (snapshot) in
                    if let username = snapshot.value as? String {
                        self.friends.append(User.init(id: friendID, username: username, isFriend: true))
                        frienGroup.leave()
                    }
                }
            }

        }

        frienGroup.notify(queue: DispatchQueue.main) {
            self.sortFriends()
            if self.isAllUsers == false {
            self.friendsTableView.reloadData()
            }
            print("execute")
        }

    }

    func sortFriends() {
        friends.sort {$0.username < $1.username}
    }

    func downloadAllUsers() {
        downloadFriendsIDWithoutObserver()
        if let user = Auth.auth().currentUser {
            self.ref.observeSingleEvent(of: .value) { (snapshot) in
                if let users  = snapshot.value as? NSDictionary {
                    for (userID, userInfo) in users {
                        if let userIDstr = userID as? String, userIDstr != user.uid, let userInfo = userInfo as? NSDictionary, let username = userInfo["Username"] as? String {
                            self.allUsers.append(User(id: userIDstr, username: username))
                        }
                    }
                }
                self.sortAllUsers()
            }
        }
    }

    func sortAllUsers() {
        var noFriends = [User]()
        for  user in allUsers {
            if friends.contains(user) {
               } else {
                noFriends.append(user)
            }
        }
        noFriends.sort {$0<$1}
        self.allUsers = self.friends + noFriends
        if isAllUsers {
        self.friendsTableView.reloadData()
        }
    }

}
extension FriendsViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAllUsers {
            if isSearching { return self.sortedAllUsers.count} else {
           return self.allUsers.count
            }
        } else {
            if isSearching {
              return  self.sortedFriends.count
            } else {
       return self.friends.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: FriendTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if isSearching {
            if self.isAllUsers {
                       let uid = self.sortedAllUsers[indexPath.row].id
                              cell.friendId = self.sortedAllUsers[indexPath.row].id
                              cell.friendUserName.text = self.sortedAllUsers[indexPath.row].username
                              cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")
                   } else {
                   let uid = self.sortedFriends[indexPath.row].id
                   cell.friendId = self.sortedFriends[indexPath.row].id
                   cell.friendUserName.text = self.sortedFriends[indexPath.row].username
                   cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")
                   }
        } else {
        if self.isAllUsers {
            let uid = self.allUsers[indexPath.row].id
                   cell.friendId = self.allUsers[indexPath.row].id
                   cell.friendUserName.text = self.allUsers[indexPath.row].username
                   cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")
        } else {
        let uid = self.friends[indexPath.row].id
        cell.friendId = self.friends[indexPath.row].id
        cell.friendUserName.text = self.friends[indexPath.row].username
        cell.friendImageView.loadImageWhithoutUser(idString: "\(uid)/\(uid)")

        }
    }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if self.isAllUsers {
                let user  = self.sortedAllUsers[indexPath.row]
                var status = Status.user
                if self.friends.contains(user) {
                    let userVC = UserViewController(status: .friend, user: user)
                    self.navigationController?.pushViewController(userVC, animated: true)
                } else {
                if let userID = Auth.auth().currentUser?.uid {
                           self.ref.child(userID).child("subscribes").child(user.id).observeSingleEvent(of: .value) { (snapshot) in
                               if (snapshot.value as? String) != nil {
                                   status = .heSubscribeForYou
                                let userVC = UserViewController(status: status, user: user)
                                self.navigationController?.pushViewController(userVC, animated: true)
                               } else {
                                   self.ref.child(user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                                       if (snapshot.value as? String) != nil {
                                           print("fiorerfp")
                                           status = .youSubsribeForHim
                                        let userVC = UserViewController(status: status, user: user)
                                        self.navigationController?.pushViewController(userVC, animated: true)
                                       } else {
                                        let userVC = UserViewController(status: status, user: user)
                                        self.navigationController?.pushViewController(userVC, animated: true)
                                    }
                                   }

                                }
                               }
                           }
                       }
            } else {

                let friend  = sortedFriends[indexPath.row]
                let userVC = UserViewController(status: .friend, user: friend)
                self.navigationController?.pushViewController(userVC, animated: true)

            }
        }
            ///// no searching
            else {
        if self.isAllUsers {
            let user  = self.allUsers[indexPath.row]
            var status = Status.user
            if self.friends.contains(user) {
                let userVC = UserViewController(status: .friend, user: user)
                self.navigationController?.pushViewController(userVC, animated: true)
            } else {
            if let userID = Auth.auth().currentUser?.uid {
                       self.ref.child(userID).child("subscribes").child(user.id).observeSingleEvent(of: .value) { (snapshot) in
                           if (snapshot.value as? String) != nil {
                               status = .heSubscribeForYou
                            let userVC = UserViewController(status: status, user: user)
                            self.navigationController?.pushViewController(userVC, animated: true)
                           } else {
                               self.ref.child(user.id).child("subscribes").child(userID).observeSingleEvent(of: .value) { (snapshot) in
                                   if (snapshot.value as? String) != nil {
                                       print("fiorerfp")
                                       status = .youSubsribeForHim
                                    let userVC = UserViewController(status: status, user: user)
                                    self.navigationController?.pushViewController(userVC, animated: true)
                                   } else {
                                    let userVC = UserViewController(status: status, user: user)
                                    self.navigationController?.pushViewController(userVC, animated: true)
                                }
                               }

                            }
                           }
                       }
                   }
        } else {

            let friend  = friends[indexPath.row]
            let userVC = UserViewController(status: .friend, user: friend)
            self.navigationController?.pushViewController(userVC, animated: true)

        }
    }

    }

   }

extension FriendsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == " " || searchText == ""{
            isSearching = false
            self.friendsTableView.reloadData()
            return
        }
        if isAllUsers {
            searcAllUsers(searchtext: searchText)
        } else {
            searchFriends(searchtext: searchText)
        }
        self.friendsTableView.reloadData()
    }

    func searchFriends(searchtext: String) {
        isSearching = true
        sortedFriends.removeAll()
        for friend in friends {
            if friend.username.contains(searchtext) {
                self.sortedFriends.append(friend)
            }
        }
    }
    func searcAllUsers(searchtext: String) {
        isSearching = true
        sortedAllUsers.removeAll()
        for user in allUsers {
            if user.username.contains(searchtext) {
                self.sortedAllUsers.append(user)
            }
        }
    }

}
