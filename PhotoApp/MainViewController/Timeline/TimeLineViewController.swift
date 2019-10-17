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

typealias PhotoModellcell = (id: String, category: CategoryModel, photoDescription: String?, date: String, hastags: [String]?)

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
    var photoModels = [PhotoModellcell]()
    var headers = [String]()
    var headers2 = [String]()
    var sections = [String: [PhotoModellcell]]()
    var sortedSections = [String: [PhotoModellcell]]()
    var allHashtags = Set<String>()

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
                        let photoModel: PhotoModellcell = (photomodelID, category, description, date, hastags)
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
            let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + cellls[indexPath.item].category.name.uppercased()
            cell.descriptionLabel.text = dateCatStr
                cell.hastagshLabel.text = item.photoDescription
            cell.photoImageView.loadImage(idString: item.id)
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
            let dateCatStr = formater.string(from: date ?? Date.init()) + "/" + cellls[indexPath.item].category.name.uppercased()
            cell.descriptionLabel.text = dateCatStr
            cell.photoImageView.loadImage(idString: item.id)
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
        let delete = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete") { (_, _, (Bool) -> Void) in
            if let userID = Auth.auth().currentUser?.uid {
            if self.searching {
                if let cellls = self.sections[self.headers2[indexPath.section]] {
                let item = cellls[indexPath.row]
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
        return UISwipeActionsConfiguration.init(actions: [delete])
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
