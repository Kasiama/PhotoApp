//
//  CategoriesTableViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/12/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

protocol AddCategoryDelegate: AnyObject {
    func addCategory(category: CategoryModel)
    func editCategory(category: CategoryModel, row: Int)
}

let categoryCellId = "CategoryTableViewCell"
class CategoriesTableViewController: UITableViewController, AddCategoryDelegate {

        var categoriesArray = [CategoryModel]()
        var ref: DatabaseReference!

       var friendCategoriesArray = [CategoryModel]()
        var friendNames = [String]()
        var freindsDict = [String: [CategoryModel]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        downloadCategories()

        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: UIBarButtonItem.Style.done,
                                                                      target: self, action: #selector(addTapped))

        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain,
                                            target: self, action: #selector(saveTaped))

        self.navigationItem.leftBarButtonItem = newBackButton
        self.clearsSelectionOnViewWillAppear = false

        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: categoryCellId)
        tableView.tableFooterView = UIView()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.categoriesArray.count}
        else {
            return self.freindsDict[self.friendNames[section-1]]?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        let red = categoriesArray[indexPath.row].fred
        let green = categoriesArray[indexPath.row].fgreen
        let blue = categoriesArray[indexPath.row].fblue
        let alpha = categoriesArray[indexPath.row].falpha
        let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))

        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.color = color
        cell.cellTextLabel.textColor = color

        let circle = CirkleView.init(frame: cell.cellView.bounds, color: color )
        cell.cirkleView = circle
        cell.cellView.addSubview(circle)
         let fillCircle =  CircleFillView.init(frame: cell.cellView.bounds, color: color )
        cell.fillCircle = fillCircle

        if categoriesArray[indexPath.row].isSelected == 1 {
        cell.cellView.addSubview(fillCircle)
        } else {
            cell.cellView.addSubview(fillCircle)
            cell.fillCircle?.isHidden = true
            }

        cell.cellTextLabel.text = categoriesArray[indexPath.row].name
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
        } else {
            let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let key = friendNames[indexPath.section - 1]
            if  let arr = self.freindsDict[key] {

            let red = arr [indexPath.row ].fred
            let green = arr[indexPath.row ].fgreen
            let blue = arr[indexPath.row ].fblue
            let alpha = arr[indexPath.row].falpha
            let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
            cell.cirkleView?.removeFromSuperview()
            cell.fillCircle?.removeFromSuperview()
            cell.cirkleView = nil
            cell.color = color
            cell.cellTextLabel.textColor = color

            if cell.cirkleView == nil {

                let circle = CirkleView.init(frame: cell.cellView.bounds, color: color )
                cell.cirkleView = circle
                cell.cellView.addSubview(circle)
                let fillCircle =  CircleFillView.init(frame: cell.cellView.bounds, color: color )
                cell.fillCircle = fillCircle

                if arr[indexPath.row ].isSelected == 1 {
                    cell.cellView.addSubview(fillCircle)
                } else {
                    cell.cellView.addSubview(fillCircle)
                    cell.fillCircle?.isHidden = true
                    }
            }
            cell.cellTextLabel.text = arr[indexPath.row].name
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell: CategoryTableViewCell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
        if  self.categoriesArray[indexPath.row].isSelected == 1 {
            self.categoriesArray[indexPath.row].isSelected = 0
            cell.fillCircle?.isHidden = true
        } else {
            self.categoriesArray[indexPath.row].isSelected = 1
            cell.fillCircle?.isHidden = false
        }
        } else {
           let key = friendNames[indexPath.section - 1]
            if  var arr = self.freindsDict[key] {
                if  arr[indexPath.row].isSelected == 1 {
                    arr[indexPath.row].isSelected = 0
                    cell.fillCircle?.isHidden = true
                    self.freindsDict[key] = arr
                } else {
                    arr[indexPath.row].isSelected = 1
                    cell.fillCircle?.isHidden = false
                     self.freindsDict[key] = arr
                }
            }

        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == 0 {
        let edit = UIContextualAction.init(style: .normal, title: "Edit") { (_, _, (Bool) -> Void) in
            let category = self.categoriesArray[indexPath.row]
             let editVC = AddCategoryViewController()
            editVC.category = category
            editVC.row = indexPath.row
            editVC.delegate = self
            self.navigationController?.pushViewController(editVC, animated: true)

        }
            let delete = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete") { (_, _, (Bool) -> Void) in
            let category = self.categoriesArray[indexPath.row]
            if category.id != "" {
                if let userID = Auth.auth().currentUser?.uid {
            self.ref.child("\(String(describing: userID))/categories/user").child(category.id).removeValue()
            }
                }
             self.categoriesArray.remove(at: indexPath.row)
            let cell: CategoryTableViewCell = tableView.cellForRow(at: indexPath)

            cell.cellView.removeFromSuperview()
            cell.cirkleView = nil
            cell.fillCircle = nil
            tableView.deleteRows(at: [indexPath], with: .none)
        tableView.reloadData()

        }
        edit.backgroundColor = UIColor.blue
        delete.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration.init(actions: [delete, edit])
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Me"
        }else {
            return friendNames[section-1]
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return friendNames.count + 1
    }

    func addCategory(category: CategoryModel) {
        categoriesArray.append(category)
        tableView.reloadData()
    }

    func editCategory(category: CategoryModel, row: Int) {
        categoriesArray[row] = category
        let cell: CategoryTableViewCell = tableView.cellForRow(at: IndexPath.init(item: row, section: 0))
        cell.cirkleView?.removeFromSuperview()
        cell.fillCircle?.removeFromSuperview()
        cell.cirkleView = nil
        cell.fillCircle = nil
        let red = categoriesArray[row].fred
        let green = categoriesArray[row].fgreen
        let blue = categoriesArray[row].fblue
        let alpha = categoriesArray[row].falpha
        let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        let circle = CirkleView.init(frame: cell.cellView.bounds, color: color )
               cell.cirkleView = circle
               cell.cellView.addSubview(circle)
                let fillCircle =  CircleFillView.init(frame: cell.cellView.bounds, color: color )
               cell.fillCircle = fillCircle

               if categoriesArray[row].isSelected == 1 {
               cell.cellView.addSubview(fillCircle)
               } else {
                   cell.cellView.addSubview(fillCircle)
                   cell.fillCircle?.isHidden = true
                   }

        tableView.reloadData()
        }

    func downloadCategories() {
        if let user  = Auth.auth().currentUser {
        let userID = user.uid
            ref.child(userID).child("categories").child("user").observe( .value, with: { (snapshot) in
                self.categoriesArray.removeAll()
                let value = snapshot.value as? NSDictionary
                for (categoryID, categoryInfo) in value ?? [:] {
                    if  let categoryIn = categoryInfo as? NSDictionary,
                    let catid = categoryID as? String,
                    let name = categoryIn["name"] as? String,
                    let fred = categoryIn["fred"] as? CGFloat,
                    let fblue = categoryIn["fblue"] as? CGFloat,
                    let fgreen = categoryIn["fgreen"] as? CGFloat,
                    let falpha = categoryIn["falpha"] as? CGFloat,
                    let isSelected = categoryIn["isSelected"] as? Int,
                    let friendID = categoryIn["friendID"] as? String,
                    let friendName = categoryIn["friendName"] as? String {
                        let category = CategoryModel.init(id: catid, name: name, fred: fred,
                                                      fgreen: fgreen, fblue: fblue,
                                                      falpha: falpha, isSelected: isSelected, friendID: friendID, friendName: friendName)
                    self.categoriesArray.append(category)
                }
            }
            for category in self.categoriesArray {
                if self.freindsDict[category.friendName] == nil {
                    self.freindsDict[category.friendName] = [category]
                } else {
                    self.freindsDict[category.friendName]?.append(category)
                }
            }
                self.downloadFriendsCategories()
        }) { (error) in
            print(error.localizedDescription)
        }
     }
    }

    func downloadFriendsCategories () {
        if let user = Auth.auth().currentUser {
            let userID = user.uid
            self.ref.child(userID).child("categories").child("friends").observe(.value) { (snapshot) in
                self.friendCategoriesArray.removeAll()
                self.friendNames.removeAll()
                self.freindsDict.removeAll()
                var arr = [CategoryModel]()
                if let friendcatsDict  = snapshot.value as? NSDictionary {
                    for (_, catDict) in friendcatsDict {
                        if let catdict = catDict as? NSDictionary {
                            for (categoryID, categoriesDict) in catdict {
                                if  let catid = categoryID as? String,
                                let categoriesDict = categoriesDict as? NSDictionary {
                                 if let name = categoriesDict["name"] as? String,
                                    let fred = categoriesDict["fred"] as? CGFloat,
                                    let fblue = categoriesDict["fblue"] as? CGFloat,
                                    let fgreen = categoriesDict["fgreen"] as? CGFloat,
                                    let falpha = categoriesDict["falpha"] as? CGFloat,
                                    let isSelected = categoriesDict["isSelected"] as? Int,
                                    let friendID = categoriesDict["friendID"] as? String,
                                    let friendName = categoriesDict["friendName"] as? String {
                                        let friendCategory = CategoryModel.init(id: catid, name: name, fred: fred, fgreen: fgreen,
                                                                                        fblue: fblue, falpha: falpha, isSelected: isSelected, friendID: friendID, friendName: friendName)
                                        arr.append(friendCategory)

                                    }
                                }
                            }
                        }
                    }
                }
                for category in arr {
                    if self.freindsDict[category.friendName] == nil {
                        self.freindsDict[category.friendName] = [category]
                    } else {
                        self.freindsDict[category.friendName]?.append(category)
                            }
                        }

                self.friendNames.removeAll()
                for (key, _) in self.freindsDict {
                    self.friendNames.append(key)
                }
                self.tableView.reloadData()
            }
        }
    }

    @objc func addTapped() {
        let catecoriesTableVC = AddCategoryViewController()
        catecoriesTableVC.delegate = self
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
    }

    @objc func saveTaped() {
        if let user  = Auth.auth().currentUser {
            let userID = user.uid
            let categoriesDictionary = NSMutableDictionary()
            for category in self.categoriesArray {
                if category.id == "" {
                    guard let key = ref.child("\(String(describing: userID))/categories/user").childByAutoId().key else { return }
                    let categorysend = ["name": category.name,
                                        "fred": category.fred,
                                        "fgreen": category.fgreen,
                                        "fblue": category.fblue,
                                        "falpha": category.falpha,
                                        "isSelected": category.isSelected,
                                        "friendID": userID,
                                        "friendName": "Me"] as [String: Any]
                    categoriesDictionary[key] = categorysend
                } else if category.friendID == userID {
                    guard let key = ref.child("\(String(describing: userID))/categories/user").child(category.id).key else { return }
                    let categorysend = ["name": category.name,
                                        "fred": category.fred,
                                        "fgreen": category.fgreen,
                                        "fblue": category.fblue,
                                        "falpha": category.falpha,
                                        "isSelected": category.isSelected,
                                        "friendID": userID,
                                        "friendName": "Me"] as [String: Any]
                    categoriesDictionary[category.id] = categorysend
                }
            }
            let childUpdates = ["/\(String(describing: userID))/categories/user/": categoriesDictionary]
            ref.updateChildValues(childUpdates)
            saveFriendsCategories()
            self.navigationController?.popViewController(animated: true)
        }
    }

    func saveFriendsCategories() {
        if let userID = Auth.auth().currentUser?.uid {
            for key in self.friendNames {
                if let arr = self.freindsDict[key] {
                    for category in arr {
                        let categorysend = ["name": category.name,
                                                "fred": category.fred,
                                                "fgreen": category.fgreen,
                                                "fblue": category.fblue,
                                                "falpha": category.falpha,
                                                "isSelected": category.isSelected,
                                                "friendID": category.friendID,
                                                "friendName": category.friendName
                                                                ] as [String: Any]
                        let childUpdates = ["/\(String(describing: userID))/categories/friends/\(category.friendID)/\(category.id)": categorysend]
                        ref.updateChildValues(childUpdates)
                    }
                }
            }
        }
    }
}
