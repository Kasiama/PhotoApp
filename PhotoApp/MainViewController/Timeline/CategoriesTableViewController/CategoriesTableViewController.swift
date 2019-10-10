//
//  CategoriesTableViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/12/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

protocol AddCategoryDelegate:AnyObject{
    func addCategory(category:CategoryModel)
    func editCategory(category:CategoryModel,row: Int)
}


class CategoriesTableViewController: UITableViewController, AddCategoryDelegate {
        let cellId = "cellId"
        var categoriesArray = [CategoryModel]()
        var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         ref = Database.database().reference()
        downloadCategories()
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style:UIBarButtonItem.Style.done, target: self, action: #selector(addTapped))
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveTaped))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.clearsSelectionOnViewWillAppear = false
        
        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
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

        let r = categoriesArray[indexPath.row].fred
        let g = categoriesArray[indexPath.row].fgreen
        let b = categoriesArray[indexPath.row].fblue
        let a = categoriesArray[indexPath.row].falpha
        let color = UIColor.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CategoryTableViewCell
        cell.color = color
        cell.cellTextLabel.textColor = color
        
        if(cell.cirkleView == nil){
        cell.cirkleView = CirkleView.init(frame: cell.cellView.bounds, color:color )
        cell.cellView.addSubview(cell.cirkleView!)
        cell.fillCircle = CircleFillView.init(frame: cell.cellView.bounds, color: color )
        if (categoriesArray[indexPath.row].isSelected == 1){
        cell.cellView.addSubview(cell.fillCircle!)
        }
        else{
            cell.cellView.addSubview(cell.fillCircle!)
            cell.fillCircle?.isHidden = true
            }
        }
        cell.cellTextLabel.text = categoriesArray[indexPath.row].name
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        if  (self.categoriesArray[indexPath.row].isSelected == 1){
            self.categoriesArray[indexPath.row].isSelected = 0
            cell.fillCircle?.isHidden = true
        }
        else{
            self.categoriesArray[indexPath.row].isSelected = 1
            cell.fillCircle?.isHidden = false
        }
        
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let edit = UIContextualAction.init(style: .normal, title: "Edit") { (UIContextualAction, UIView, (Bool) -> Void) in
            let category = self.categoriesArray[indexPath.row]
             let editVC = AddCategoryViewController()
           editVC.category = category
            editVC.row = indexPath.row
            editVC.delegate = self
            self.navigationController?.pushViewController(editVC, animated: true)
            
        }
            let delete = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete") { (UIContextualAction, UIView, (Bool) -> Void) in
            let category = self.categoriesArray[indexPath.row]
            if (category.id != ""){
            self.ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").child(category.id).removeValue()
            }
             self.categoriesArray.remove(at: indexPath.row)
            
            let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
                cell.cellView.removeFromSuperview()
            cell.cirkleView = nil
            cell.fillCircle = nil
            tableView.deleteRows(at: [indexPath], with: .none)
        tableView.reloadData()
            
        }
        edit.backgroundColor = UIColor.blue
        delete.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration.init(actions: [delete ,edit])
    }
    
    func addCategory(category: CategoryModel) {
        categoriesArray.append(category)
        tableView.reloadData()
    }
    
    func editCategory(category: CategoryModel, row: Int){
        categoriesArray[row] = category
        let cell = tableView.cellForRow(at: IndexPath.init(item: row, section: 0)) as! CategoryTableViewCell
        cell.cellView.removeFromSuperview()
        cell.cirkleView = nil
        cell.fillCircle = nil
        tableView.reloadData()
        }


    func downloadCategories()  {
        if let user  = Auth.auth().currentUser{
        let userID = user.uid
        ref.child(userID).child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
          let value = snapshot.value as? NSDictionary
            for (categoryID, categoryInfo) in value ?? [:]{
                if  let categoryIn = categoryInfo as? NSDictionary,
                let catid = categoryID as? String,
                let name = categoryIn["name"] as? String,
                let fred = categoryIn["fred"] as? CGFloat,
                let fblue = categoryIn["fblue"] as? CGFloat,
                let fgreen = categoryIn["fgreen"] as? CGFloat,
                let falpha = categoryIn["falpha"] as? CGFloat,
                let isSelected = categoryIn["isSelected"] as? Int{
                    
                let category = CategoryModel.init(id: catid, name: name, fred: fred, fgreen: fgreen, fblue: fblue, falpha: falpha, isSelected:isSelected)
                self.categoriesArray.append(category)
            }
        }
            self.tableView.reloadData()
        
        }) { (error) in
            print(error.localizedDescription)
        }
     }
    }
    
    @objc func addTapped()  {
        let catecoriesTableVC = AddCategoryViewController()
        catecoriesTableVC.delegate = self
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
    }
    
    @objc func saveTaped()  {
        if let user  = Auth.auth().currentUser{
        let userID = user.uid
        for category in self.categoriesArray{
            if (category.id == ""){
            guard let key = ref.child("\(String(describing: userID))/categories").childByAutoId().key else { return }
                let categorysend = ["name":category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected":category.isSelected      ] as [String : Any]
                let childUpdates = ["/\(String(describing: userID))/categories/\(key)": categorysend]
                
                ref.updateChildValues(childUpdates)
                }
            else{
                 guard let key = ref.child("\(String(describing: userID))/categories").child(category.id).key else { return }
                let categorysend = ["name":category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected":category.isSelected      ] as [String : Any]
                let childUpdates = ["/\(String(describing: userID))/categories/\(key)": categorysend]
                
                ref.updateChildValues(childUpdates)
            }
            
        }
        
        
        
       self.navigationController?.popViewController(animated: true)
        }
    }

    
}
