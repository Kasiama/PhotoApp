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
}


class CategoriesTableViewController: UITableViewController, AddCategoryDelegate {
        let cellId = "cellId"
        let names = ["red","green","blue"]
        var categoriesArray = [CategoryModel]()
        let colors = [UIColor.red, UIColor.green, UIColor.blue]
    
         var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         ref = Database.database().reference()
        downloadCategories()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Category", style:UIBarButtonItem.Style.done, target: self, action: #selector(addTapped))
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
       
        //self.navigationItem.rightBarButtonItem 
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        let nib = UINib.init(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
          let userID = Auth.auth().currentUser!.uid
        ref.child(userID).child("categories").observe(DataEventType.value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
           // postDict.
        }
    }

    // MARK: - Table view data source

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
        // Configure the cell...
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        let a = categoriesArray[indexPath.row].isSelected
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
        let delete = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete") { (UIContextualAction, UIView, (Bool) -> Void) in
            let category = self.categoriesArray[indexPath.row]
            if (category.id != ""){
            self.ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").child(category.id).removeValue()
            }
             self.categoriesArray.remove(at: indexPath.row)
            
            let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
            cell.cellView.subviews.map({ $0.removeFromSuperview() })
            cell.cirkleView = nil
            cell.fillCircle = nil
            
            
            tableView.deleteRows(at: [indexPath], with: .none)
        
            tableView.reloadData()
            
        }
        return UISwipeActionsConfiguration.init(actions: [delete])
    }
    
    
    func addCategory(category: CategoryModel) {
        categoriesArray.append(category)
      // downloadCategories()
        tableView.reloadData()
    }


    func downloadCategories()  {
        let userID = Auth.auth().currentUser!.uid
        ref.child(userID).child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
    
        let value = snapshot.value as? NSDictionary
            
            for (categoryID, categoryInfo) in value ?? [:]{
                let categoryIn = categoryInfo as! NSDictionary
                let catid = categoryID as! String
                let name = categoryIn["name"] as! String
                let fred = categoryIn["fred"] as! Float
                let fblue = categoryIn["fblue"] as! Float
                let fgreen = categoryIn["fgreen"] as! Float
                let falpha = categoryIn["falpha"] as! Float
                let isSelected = categoryIn["isSelected"] as! Int
                let category = CategoryModel.init(id: catid  , name: name , fred: fred, fgreen: fgreen, fblue: fblue, falpha: falpha,isSelected:isSelected)
                self.categoriesArray.append(category)
            }
            
            
            
            self.tableView.reloadData()
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func addTapped()  {
        let catecoriesTableVC = AddCategoryViewController()
        catecoriesTableVC.delegate = self
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
    }
    
    @objc func back()  {
        
        for category in self.categoriesArray{
            if (category.id == ""){
            guard let key = ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").childByAutoId().key else { return }
                let categorysend = ["name":category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected":category.isSelected      ] as [String : Any]
                let childUpdates = ["/\(String(describing: Auth.auth().currentUser!.uid))/categories/\(key)": categorysend]
                
                ref.updateChildValues(childUpdates)
                }
            else{
                 guard let key = ref.child("\(String(describing: Auth.auth().currentUser!.uid))/categories").child(category.id).key else { return }
                let categorysend = ["name":category.name,
                                    "fred": category.fred,
                                    "fgreen": category.fgreen,
                                    "fblue": category.fblue,
                                    "falpha": category.falpha,
                                    "isSelected":category.isSelected      ] as [String : Any]
                let childUpdates = ["/\(String(describing: Auth.auth().currentUser!.uid))/categories/\(key)": categorysend]
                
                ref.updateChildValues(childUpdates)
            }
            
        }
        
        
        
       self.navigationController?.popViewController(animated: true)
    }
    
}
