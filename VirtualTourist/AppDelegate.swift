//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        globalViewSetup()
        
        // Configure the app manager
        AppManager.main.configure()
        
        // Setup AutoSave of core data
        AppManager.main.coreDataStack.save(every: 60)
        
        // WARNING: ONLY UNCOMMENT FOLLOWING LINE IF YOU WANT TO DELETE ALL PERSISTED DATA FROM APP
        //try? AppManager.main.coreDataStack.removeAllData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AppManager.main.saveAppState()
        AppManager.main.coreDataStack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppManager.main.saveAppState()
        AppManager.main.coreDataStack.save()
    }

}

// MARK: Views Customization Methods

extension AppDelegate {
    
    func globalViewSetup() {
        
        // Navigation Bar
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.tintColor = .white
        navBarAppearance.barTintColor = ViewInterface.Constants.Colors.softRed
        navBarAppearance.isTranslucent = false
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navBarAppearance.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: ".SFUIText-Bold", size: 18) as Any
        ]
        
        // Toolbar
        let toolbarAppearance = UIToolbar.appearance()
        toolbarAppearance.tintColor = .white
        toolbarAppearance.barTintColor = ViewInterface.Constants.Colors.softRed
        toolbarAppearance.isTranslucent = false
        toolbarAppearance.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbarAppearance.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        // Search Bar
        let searchBarAppearance = UISearchBar.appearance()
        searchBarAppearance.barTintColor = ViewInterface.Constants.Colors.softRed
        searchBarAppearance.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBarAppearance.isTranslucent = false
        
        // Status Bar
        UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
}
