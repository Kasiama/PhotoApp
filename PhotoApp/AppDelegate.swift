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
        return UIApplication.shared.delegate as! AppDelegate
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?
    // var navigationController: UINavigationController?
   
    var rootViewController:UIViewController{
        get{
            return self.window!.rootViewController!
        }
        set(rootVC){
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
        FirebaseApp.configure()

        let loginVC = LoginViewController()
        
        if Auth.auth().currentUser != nil{
            
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
            
            let otherItem = UITabBarItem()
            otherItem.title = "Other"
            
            navMainVC.tabBarItem = mapItem
            navTimeVC.tabBarItem=timeItem
            otherVC.tabBarItem = otherItem
           
           
             tabBarControllerr.viewControllers = [navMainVC, navTimeVC, otherVC]
            
           // navigationController?.pushViewController(tabBarControllerr, animated: true)
            self.window?.rootViewController = tabBarControllerr
        }
        else {
            let navLoginVC = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = navLoginVC
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
        func setLoginVCRootControler(){
            if let window = window {
                window.makeKeyAndVisible()
            }
            let loginVC = LoginViewController()
            let navLoginVC = UINavigationController.init(rootViewController: loginVC)
            self.window?.rootViewController = navLoginVC
    }
    
    func setMainVCRoot(){
        if let window = window {
            window.makeKeyAndVisible()
        }
        
        let mainVC = MainViewController()
        let timeVC = TimeLineViewController()
        let otherVC = OtherViewController()
        let navMainVC = UINavigationController.init(rootViewController: mainVC)
        let navTimeVC = UINavigationController.init(rootViewController: timeVC)
        
        
        let tabBarControllerr = UITabBarController()
        
        let mapItem = UITabBarItem()
        mapItem.title = "Map"
        mapItem.image = UIImage.init(imageLiteralResourceName: "map")
        
        
        let timeItem = UITabBarItem()
        timeItem.title = "Timeline"
        
        let otherItem = UITabBarItem()
        otherItem.title = "Other"
        
        navMainVC.tabBarItem = mapItem
        navTimeVC.tabBarItem=timeItem
        otherVC.tabBarItem = otherItem
        
        
        tabBarControllerr.viewControllers = [navMainVC, navTimeVC, otherVC]
        self.window?.rootViewController = tabBarControllerr
      
    }
    
}

