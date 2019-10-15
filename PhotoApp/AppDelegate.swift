//
//  AppDelegate.swift
//  PhotoApp
//
//  Created by Ivan Zhurauski on 9/10/19.
//  Copyright © 2019 Ivan Zhurauski. All rights reserved.
//

import UIKit
import Firebase

 extension UIViewController {
    var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
           fatalError("Unable to make delegate as AppDelegate")
        }
        return delegate
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var rootViewController: UIViewController {
        get {
            return self.window?.rootViewController ?? UIViewController.init()
        }
        set(rootVC) {
            self.window?.rootViewController = rootVC
        }
    }
    static let test = 1

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.makeKeyAndVisible()
        }
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        FirebaseApp.configure()

        let loginVC = LoginViewController()

        if Auth.auth().currentUser != nil {
            setupNavBar()
        } else {
            let navLoginVC = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = navLoginVC
        }

        return true
    }
    func setupNavBar() {
        let mainVC = MainViewController()
          let timeVC = TimeLineViewController(ISsearhbar: true, message: "")
          let otherVC = OtherViewController()
          let navMainVC = UINavigationController.init(rootViewController: mainVC)
          let navTimeVC = UINavigationController.init(rootViewController: timeVC)

          let tabBarControllerr = UITabBarController()

          let mapItem = UITabBarItem()
          mapItem.title = "Map"
          mapItem.image = UIImage.init(imageLiteralResourceName: "map")

          let timeItem = UITabBarItem()
          timeItem.title = "Timeline"
          timeItem.image = UIImage.init(imageLiteralResourceName: "timeline")

          let otherItem = UITabBarItem()
          otherItem.title = "Other"
          otherItem.image = UIImage.init(imageLiteralResourceName: "dots")

          navMainVC.tabBarItem = mapItem
          navTimeVC.tabBarItem=timeItem
          otherVC.tabBarItem = otherItem

           tabBarControllerr.viewControllers = [navMainVC, navTimeVC, otherVC]
          self.window?.rootViewController = tabBarControllerr
    }

        func setLoginVCRootControler() {
            if let window = window {
                window.makeKeyAndVisible()
            }
            let loginVC = LoginViewController()
            let navLoginVC = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = navLoginVC
    }

    func setMainVCRoot() {
        if let window = window {
            window.makeKeyAndVisible()
        }
        setupNavBar()

    }

}
