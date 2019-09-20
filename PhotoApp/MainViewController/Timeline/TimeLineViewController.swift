//
//  TimeLineViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit

  struct CategoryModel {
    var id: String 
    var name: String
    var fred: CGFloat
    var fgreen: CGFloat
    var fblue: CGFloat
    var falpha: CGFloat
    var isSelected: Int
    
}

class TimeLineViewController: UIViewController {
 var searchBar:UISearchBar = UISearchBar(frame: CGRect.init(x: 0, y: 0, width: 180, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Category", style:UIBarButtonItem.Style.done, target: self, action: #selector(addTapped))
        self.navigationItem.hidesBackButton = true
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = ""
        self.navigationController?.navigationBar.topItem?.titleView = searchBar
        
      
      
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
          self.tabBarController?.tabBar.isHidden = false
         self.navigationController?.navigationBar.isHidden = false
         self.navigationItem.hidesBackButton = true

    }
    
    @objc func addTapped()  {
        let catecoriesTableVC = CategoriesTableViewController()
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
