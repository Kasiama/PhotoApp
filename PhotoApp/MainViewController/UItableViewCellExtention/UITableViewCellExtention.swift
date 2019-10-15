//
//  UITableViewCellExtention.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 10/15/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import Foundation
import UIKit
protocol ReusableView {

    static var reuseIdentifier: String { get }

}
extension ReusableView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

}
extension UITableViewCell: ReusableView {}
extension UITableView {

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        return cell
    }
    
    func cellForRow<T: UITableViewCell>(at indexPath: IndexPath) -> T {
        
        guard let cell = cellForRow(at: indexPath) as? T else {
            fatalError("Unable to Dequeue Reusable Table View Cell")
        }
        return cell
    }
    
}
