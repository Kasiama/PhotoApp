//
//  TimeLineViewController.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

  struct CategoryModel {
    var id: String
    var name: String
    var fred: CGFloat
    var fgreen: CGFloat
    var fblue: CGFloat
    var falpha: CGFloat
    var isSelected: Int

}
struct FriendCategoryModel{
    var id: String
    var name: String
    var fred: CGFloat
    var fgreen: CGFloat
    var fblue: CGFloat
    var falpha: CGFloat
    var isSelected: Int
    var friendID: String
    var friendName: String
    
}

typealias PhotoModellcell = (id: String, category: FriendCategoryModel, photoDescription: String?, date: String, hastags: [String]?)
typealias FriendPhotoModellCell = (id: String, category: FriendCategoryModel, photoDescription: String?, date: String, hastags: [String]?)
var timeLineCellId = "PhotoTableViewCell"

class TimeLineViewController: UIViewController {

    @IBOutlet weak var photoTableView: UITableView!

    var storageRef: StorageReference = Storage.storage().reference()
    var ref: DatabaseReference = Database.database().reference()

    var searching = false
    var isSeaerchBar = false
    var imageForStatusBar: UIImage?
    var searchMessage = ""
     var searchbar = UISearchBar.init()

    let searchController = UISearchController(searchResultsController: nil)

    var selectedCategoriesArray = [CategoryModel]()
    var friendsSelectedCategoriesArray = [FriendCategoryModel]()
    
    var friendSelectedCategoriesDictionary = [String:[FriendCategoryModel]]()
    
    var photoModels = [PhotoModellcell]()
    var friendPhotoModels = [FriendPhotoModellCell]()
    
    var friendModelDictionary = [String:[FriendPhotoModellCell]]()
    
    var headers = [String]()
    var headers2 = [String]()
    var sections = [String: [PhotoModellcell]]()
    var sortedSections = [String: [PhotoModellcell]]()
    
    
    var allHashtags = Set<String>()
       let friendCategories = DispatchGroup()
        let friendModelsGroup = DispatchGroup()

    convenience init(ISsearhbar: Bool, message: String) {
        self.init()
       if ISsearhbar {
            searchbar.sizeToFit()
            searchbar.placeholder = ""
            searchbar.delegate = self
            self.navigationItem.titleView = searchbar
            isSeaerchBar = true
        } else {
            self.navigationItem.title = "#" + message
              isSeaerchBar = false
            searchMessage = "#" + message
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Category", style: UIBarButtonItem.Style.done, target: self, action: #selector(adddTaped))

        let nib = UINib.init(nibName: "PhotoTableViewCell", bundle: nil)
        self.photoTableView.register(nib, forCellReuseIdentifier: timeLineCellId)
        self.photoTableView.dataSource = self
        self.photoTableView.delegate = self
        self.photoTableView.rowHeight = 100
        self.photoTableView.delegate = self
        self.photoTableView.tableFooterView = UIView()

        downloadCategories()
        downloadFriendsCategories()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
    }

    @objc func adddTaped(_ sender: Any) {
        let catecoriesTableVC = CategoriesTableViewController()
        self.navigationController?.pushViewController(catecoriesTableVC, animated: true)
    }

    func downloadCategories() {
        if let user  = Auth.auth().currentUser {
        let userID = user.uid
        let selectedCategoriesRef = ref.child(userID).child("categories").queryOrdered(byChild: "isSelected").queryEqual(toValue: 1)
       selectedCategoriesRef.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.selectedCategoriesArray.removeAll()
            for (categoryID, categoryInfo) in value ?? [:] {
                if let categoryData = categoryInfo as? NSDictionary,
                let catid = categoryID as? String,
                let name = categoryData["name"] as? String,
                let fred = categoryData["fred"] as? CGFloat,
                let fblue = categoryData["fblue"] as? CGFloat,
                let fgreen = categoryData["fgreen"] as? CGFloat,
                let falpha = categoryData["falpha"] as? CGFloat,
                let isSelected = categoryData["isSelected"] as? Int {

                let category = CategoryModel.init(id: catid, name: name, fred: fred, fgreen: fgreen, fblue: fblue, falpha: falpha, isSelected: isSelected)
                self.selectedCategoriesArray.append(category)
                } else {print("Cant make dictionary from dataCategory")}
            }
            self.downloadPhotoModels()

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    }

    func downloadPhotoModels() {
        let formater = DateFormatter()
        formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let formater2 = DateFormatter()
        formater2.dateFormat = "MMMM-yyyy"

       if let user  = Auth.auth().currentUser {
        let userID = user.uid
        self.ref.child(userID).child("photomodels").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.sections.removeAll()
            self.sortedSections.removeAll()
            for (photomodelID, photomodelInfo) in value ?? [:] {
                if  let photomodelData = photomodelInfo as? NSDictionary,
                    let photomodelID = photomodelID as? String,
                    let catid = photomodelData["categoryID"] as? String,
                    let date = photomodelData["date"] as? String {

                let hastags = photomodelData["hashtags"] as? [String]
                let description = photomodelData["description"] as? String

                    for category in self.selectedCategoriesArray {
                    if category.id == catid {
                        if let  hastags = hastags {
                            for hashtag in hastags {
                                self.allHashtags.insert(hashtag)
                            }
                        }
                        
                        let friendCat = FriendCategoryModel.init(id: category.id, name: category.name, fred: category.fred, fgreen: category.fgreen, fblue: category.fblue, falpha: category.falpha, isSelected: category.isSelected, friendID: userID, friendName: "Me")
                        let photoModel: PhotoModellcell = (photomodelID, friendCat, description, date, hastags)
                        let date = formater.date(from: photoModel.date)
                        let dateStr = formater2.string(from: date ?? Date.init())
                        if self.sections.index(forKey: dateStr) != nil {
                            self.sections[dateStr]?.append(photoModel)
                        } else {
                            self.sections[dateStr] = [photoModel]
                        }
                    }
                }
            } else {print("Cant make dictionary from DataPhotomodel")}
            }
            let sortSections = self.sections.sorted {
            if let first = formater2.date(from: $0.key), let second = formater2.date(from: $1.key) {return first > second} else {return true}
                }
            self.headers.removeAll()
            for(key, value) in sortSections {
                let sortedArrforKey = value.sorted {
                    if let first =  formater.date(from: $0.date), let second =  formater.date(from: $1.date) {
                        return first>second} else {return true}
                }
                self.headers.append(key)
                self.sortedSections[key] = sortedArrforKey

            }
            self.sections.removeAll()
            if self.isSeaerchBar {
            self.photoTableView.reloadData()
            } else {
                self.changeTable(whithSearchText: self.searchMessage)
            }
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    }
    
    func setuplala(){
       if let user = Auth.auth().currentUser{
        let userId = user.uid
        self.ref.child(userId).child("friends").observe(.childAdded) { (snaphot) in
            self.downloadFriendsCategories()
        }
        self.ref.child(userId).child("friends").observe(.childRemoved) { (snaphot) in
            self.downloadFriendsCategories()
        }
        
        
        }
    }
    
    
    func downloadFriendsCategories(){
    if let user = Auth.auth().currentUser{
        let userID = user.uid
    
        self.ref.child(userID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
            if let friendsDict = snapshot.value as? NSDictionary{
                for (friendID,categoriesDict) in friendsDict{
                    if let friendID = friendID as? String {
                        self.ref.child(friendID).child("Username").observeSingleEvent(of: .value) { (data) in
                            if let friendName = data.value as? String{
                                let selectedCatRef = self.ref.child(userID).child("friends").child(friendID)
                              
                                selectedCatRef.observe( .value) { (snap) in
                                    if let categoryDict = snap.value as? NSDictionary{
                                        self.friendSelectedCategoriesDictionary[friendID] = nil
                                        for (categoryID,catInfo) in categoryDict{
                                            if let categoryID = categoryID as? String,
                                                let catInfo = catInfo as? NSDictionary,
                                                let falpha = catInfo["falpha"] as? CGFloat,
                                                let fgreen = catInfo["fgreen"] as? CGFloat,
                                                let fred = catInfo["fred"] as? CGFloat,
                                                let fblue = catInfo["fblue"] as? CGFloat,
                                                let name = catInfo["name"] as? String,
                                                let isSelected = catInfo["isSelected"] as? Int,
                                                    (isSelected == 1){
                                                let friendcat = FriendCategoryModel.init(id: categoryID, name: name, fred: fred, fgreen: fgreen, fblue: fblue, falpha: falpha, isSelected: isSelected, friendID: friendID, friendName: friendName)
                                                if self.friendSelectedCategoriesDictionary[friendID] == nil{
                                                    self.friendSelectedCategoriesDictionary[friendID] = [friendcat]
                                                        }
                                                        else{
                                                    self.friendSelectedCategoriesDictionary[friendID]!.append(friendcat)
                                                                                  }
                                                
                                        }
                                    }

                                }
                                    DispatchQueue.global().async(group: self.friendCategories){
                                        print ("enter")
                                        self.friendCategories.enter()
                                    self.downloadFriendsPhotoModels()
                                    }
                                   
                            }
                        }
                         
                    }

                }
            }
        }
           
    }


       
        
    }
    }
    
    func downloadFriendsPhotoModels(){
        if let userID = Auth.auth().currentUser?.uid{
        for (friendID,category) in self.friendSelectedCategoriesDictionary {
            
            self.ref.child(friendID).child("photomodels").observe(.value) { (snapshot) in
                print("photomodel")
                self.friendModelDictionary[friendID] = nil
                
                if  self.friendSelectedCategoriesDictionary[friendID]?.count ?? 0 > 0{
                
                if let modelsDict = snapshot.value as? NSDictionary{
                    for (photoID, photoDict) in modelsDict{
                        if let photoID = photoID as? String,
                            let photoDictionary = photoDict as? NSDictionary,
                            let catID = photoDictionary["categoryID"] as? String,
                            let date = photoDictionary["date"] as? String,
                            let description = photoDictionary["description"] as? String,
                            let hastags = photoDictionary["hashtags"] as? [String]
                                                                                {
                            for selectedCategory in category{
                                if selectedCategory.id == catID{
                                     let friendPhotoModel: FriendPhotoModellCell = (photoID,selectedCategory,description,date,hastags)
                                    if self.friendModelDictionary[friendID] == nil{
                                   
                                        self.friendModelDictionary[friendID] = [friendPhotoModel]
                                    }
                                    else{
                                        self.friendModelDictionary[friendID]!.append(friendPhotoModel)
                                    }
                                    
                                   
                                }
                            }
                            
                            
                            
                        }
                    }
                }
                
                
            }
               // self.frienGroup.leave()
                //self.sortAllSections()
                self.friendCategories.notify(queue: DispatchQueue.main){
                    
                    print("execute")
                }
            }
        }
    }
    }
    
    func sortAllSections(){
        let formater = DateFormatter()
        formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let formater2 = DateFormatter()
        formater2.dateFormat = "MMMM-yyyy"
        
        for (friendID,photoModelarr) in self.friendModelDictionary{
            for photoModel in photoModelarr{
            let date = formater.date(from: photoModel.date)
            let dateStr = formater2.string(from: date ?? Date.init())
            if self.sections.index(forKey: dateStr) != nil {
                self.sections[dateStr]?.append(photoModel)
            } else {
                self.sections[dateStr] = [photoModel]
            }
        }
        }
        let sortSections = self.sections.sorted {
                   if let first = formater2.date(from: $0.key), let second = formater2.date(from: $1.key) {return first > second} else {return true}
                       }
                   self.headers.removeAll()
                   for(key, value) in sortSections {
                       let sortedArrforKey = value.sorted {
                           if let first =  formater.date(from: $0.date), let second =  formater.date(from: $1.date) {
                               return first>second} else {return true}
                       }
                       self.headers.append(key)
                       self.sortedSections[key] = sortedArrforKey

                   }
                   self.sections.removeAll()
                   if self.isSeaerchBar {
                   self.photoTableView.reloadData()
                   } else {
                       self.changeTable(whithSearchText: self.searchMessage)
                   }
        
        
    }
    
    
    func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }

}

extension TimeLineViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTap))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view?.addGestureRecognizer(tapRecognizer)
        if searching {
        let str = self.headers2[section]
        view?.textLabel?.text = str
        } else {
            let str = self.headers[section]
            view?.textLabel?.text = str
        }
        return view

    }
    @objc func headerTap(gestureRecognizer: UIGestureRecognizer) {
        self.searchbar.endEditing(true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching {return self.headers2[section]} else { return self.headers[section]}
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if searching {return self.headers2.count} else { return self.headers.count}

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            let key = self.headers2[section]
         return sections[key]?.count ?? 0
        } else {
            let key = self.headers[section]
            return sortedSections[key]?.count ?? 0

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: PhotoTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if searching {
            if let cellls = self.sections[self.headers2[indexPath.section]] {
            let item = cellls[indexPath.row]

            cell.id = item.id
            cell.descriptionLabel?.numberOfLines = 2
            let formater = DateFormatter()
            formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let date = formater.date(from: cellls[indexPath.item].date )
            formater.dateFormat = "yy-MM-dd"
           if item.category.friendName == "Me"{
             let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + cellls[indexPath.item].category.name.uppercased()
             cell.descriptionLabel.text = dateCatStr
           cell.photoImageView.loadImage(idString: item.id)
                          }
                          else{
                     let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + item.category.friendName + "/" + cellls[indexPath.item].category.name.uppercased()
             cell.descriptionLabel.text = dateCatStr
             cell.photoImageView.loadImageWhithoutUser(idString: "\(item.category.friendID)/\(item.id)")
                          }
            } else {
                print("Cant Find cells of sections")
            }
        } else {
            if  let cellls = self.sortedSections[self.headers[indexPath.section]] {
            let item = cellls[indexPath.row]
             cell.id = item.id
            cell.descriptionLabel?.numberOfLines = 2
            let formater = DateFormatter()
            formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let date = formater.date(from: cellls[indexPath.item].date )
            formater.dateFormat = "yy-MM-dd"
                if item.category.friendName == "Me"{
            let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + cellls[indexPath.item].category.name.uppercased()
            cell.descriptionLabel.text = dateCatStr
          cell.photoImageView.loadImage(idString: item.id)
                         }
                         else{
                    let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + item.category.friendName + "/" + cellls[indexPath.item].category.name.uppercased()
            cell.descriptionLabel.text = dateCatStr
            cell.photoImageView.loadImageWhithoutUser(idString: "\(item.category.friendID)/\(item.id)")
                         }
            cell.hastagshLabel.text = item.photoDescription

            } else {print("Cant Find cells of sortedSection")}
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.searchbar.endEditing(true)
        if searching {
            if let cellls = self.sections[self.headers2[indexPath.section]] {
            let item = cellls[indexPath.row]
            let fullImageVC  = FullImageViewController(id: item.id, description: item.photoDescription)
            self.navigationController?.pushViewController(fullImageVC, animated: true)
            } else {print("Cant Find cells of sections")}
        } else {
            if let cellls = self.sortedSections[self.headers[indexPath.section]] {
            let item = cellls[indexPath.row]
            let fullImageVC  = FullImageViewController(id: item.id, description: item.photoDescription)
            self.navigationController?.pushViewController(fullImageVC, animated: true)
            } else {print("Cant Find cells of sortedSections")}
        }

    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var isFriend = false
        let delete = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete") { (_, _, (Bool) -> Void) in
            if let userID = Auth.auth().currentUser?.uid {
            if self.searching {
                if let cellls = self.sections[self.headers2[indexPath.section]] {
                let item = cellls[indexPath.row]
                                  if item.category.friendID == userID{
                                      isFriend = false
                                  }
                                  else {
                                      isFriend = true
                                  }
                self.ref.child(userID).child("photomodels").child(item.id).removeValue()
                self.storageRef.child(userID).child(item.id).delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                        } else {}
                    }
                }
            } else {
                if let cellls = self.sortedSections[self.headers[indexPath.section]] {
                let item = cellls[indexPath.row]
                    if item.category.friendID == userID{
                                                        isFriend = false
                                                    }
                                                    else {
                                                        isFriend = true
                                                    }
                 self.ref.child(userID).child("photomodels").child(item.id).removeValue()
                self.storageRef.child(userID).child(item.id).delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {}
                }
            }
            }
        }
        }
        self.searchbar.endEditing(true)
        delete.backgroundColor = UIColor.red
        if isFriend{
        return UISwipeActionsConfiguration.init(actions: [delete])
        }
        else {return nil}
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchbar.endEditing(true)
    }
    
    

}
extension TimeLineViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        changeTable(whithSearchText: searchText)
    }
    func changeTable(whithSearchText searchText: String) {
        if searchText == "" || searchText == "#" {
            searching = false
            self.photoTableView.reloadData()
            return
        } else {
            searching = true
        }

        sections.removeAll()
        let searchHashtags: [String] = searchText.findMentionText()
        var predictedHashtags = Set<String>()

        for allhashtag in allHashtags {
            for searchhashtag in searchHashtags {

                if allhashtag.contains(searchhashtag) {
                    predictedHashtags.insert(allhashtag)
                }
            }
        }
        for allhashtag in allHashtags {
            for searchhashtag in searchHashtags {
                if searchhashtag == allhashtag {
                    predictedHashtags.removeAll()
                    break
                }
            }
        }
        for allhashtag in allHashtags {
            for searchhashtag in searchHashtags {
                if searchhashtag == allhashtag {
                    predictedHashtags.insert(allhashtag)
                  //  break
                }
            }
        }

        headers2.removeAll()
        for (key, value) in self.sortedSections {
            var arr = [PhotoModellcell]()
            for model in value {
                if let hashtags = model.hastags {
                    let modSet = Set(hashtags)
                    for predictedHashtag in predictedHashtags {
                        if modSet.contains(predictedHashtag) {
                            arr.append(model)
                            break
                        }
                    }
                }
            }
            if arr.isEmpty {} else {
                sections[key]=arr
                headers2.append(key)
            }
        }
        headers2 = headers2.reversed()
        self.photoTableView.reloadData()
    }

}
