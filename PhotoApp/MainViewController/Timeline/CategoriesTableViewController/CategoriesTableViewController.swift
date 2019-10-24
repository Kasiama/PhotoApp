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
        
       var friendCategoriesArray = [FriendCategoryModel]()
    
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoriesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let red = categoriesArray[indexPath.row].fred
        let green = categoriesArray[indexPath.row].fgreen
        let blue = categoriesArray[indexPath.row].fblue
        let alpha = categoriesArray[indexPath.row].falpha
        let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))

        let cell: CategoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.color = color
        cell.cellTextLabel.textColor = color

        if cell.cirkleView == nil {

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
        }
        cell.cellTextLabel.text = categoriesArray[indexPath.row].name
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
//        else {
//            let a = UITableViewCell()
//            return a
//        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CategoryTableViewCell = tableView.cellForRow(at: indexPath)
        if  self.categoriesArray[indexPath.row].isSelected == 1 {
            self.categoriesArray[indexPath.row].isSelected = 0
            cell.fillCircle?.isHidden = true
        } else {
            self.categoriesArray[indexPath.row].isSelected = 1
            cell.fillCircle?.isHidden = false
        }

    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

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
            self.ref.child("\(String(describing: userID))/categories").child(category.id).removeValue()
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
        ref.child(userID).child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            for (categoryID, categoryInfo) in value ?? [:] {
                if  let categoryIn = categoryInfo as? NSDictionary,
                let catid = categoryID as? String,
                let name = categoryIn["name"] as? String,
                let fred = categoryIn["fred"] as? CGFloat,
                let fblue = categoryIn["fblue"] as? CGFloat,
                let fgreen = categoryIn["fgreen"] as? CGFloat,
                let falpha = categoryIn["falpha"] as? CGFloat,
                let isSelected = categoryIn["isSelected"] as? Int {

                let category = CategoryModel.init(id: catid, name: name, fred: fred,
                                                  fgreen: fgreen, fblue: fblue,
                                                  falpha: falpha, isSelected: isSelected)
                self.categoriesArray.append(category)
            }
        }
            self.tableView.reloadData()

        }) { (error) in
            print(error.localizedDescription)
        }
     }
    }

    func downloadFriendsCategories (){
        if let user = Auth.auth().currentUser{
            let userID = user.uid
            
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
        for category in self.categoriesArray {
            if category.id == "" {
            guard let key = ref.child("\(String(describing: userID))/categories").childByAutoId().key else { return }
                let categorysend = ["name": category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected": category.isSelected      ] as [String: Any]
                let childUpdates = ["/\(String(describing: userID))/categories/\(key)": categorysend]

                ref.updateChildValues(childUpdates)
                } else {
                 guard let key = ref.child("\(String(describing: userID))/categories").child(category.id).key else { return }
                let categorysend = ["name": category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected": category.isSelected      ] as [String: Any]
                let childUpdates = ["/\(String(describing: userID))/categories/\(key)": categorysend]

                ref.updateChildValues(childUpdates)
            }

        }

       self.navigationController?.popViewController(animated: true)
        }
    }
    

}
