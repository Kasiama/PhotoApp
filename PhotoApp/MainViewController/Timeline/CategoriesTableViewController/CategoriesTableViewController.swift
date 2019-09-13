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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CategoryTableViewCell
        
        if (categoriesArray.count != 0){
        cell.cellTextLabel.text = categoriesArray[indexPath.row].name
        let r = categoriesArray[indexPath.row].fred
        let g = categoriesArray[indexPath.row].fgreen
        let b = categoriesArray[indexPath.row].fblue
        let a = categoriesArray[indexPath.row].falpha
        let color = UIColor.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
        cell.cellTextLabel.textColor = color
        cell.color = color
        let aa = CirkleView.init(frame: cell.cellView.bounds, color:color )
        cell.cellView.addSubview(aa)
            cell.fillCircle = CircleFillView.init(frame: cell.cellView.bounds, color: color )
            cell.cellView.addSubview(cell.fillCircle!)
            if (categoriesArray[indexPath.row].isSelected  == 1){
                cell.isSelected = true
           //     cell.fillCircle?.isHidden = false
            }
        // Configure the cell...
        }
        return cell
    }
    

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
    }

    @objc func addTapped()  {
        let catecoriesTableVC = AddCategoryViewController()
        catecoriesTableVC.delegate = self
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
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
    
}
