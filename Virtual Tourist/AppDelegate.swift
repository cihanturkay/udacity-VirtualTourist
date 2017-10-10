//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 06.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "VirtualTourist")!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        stack.autoSave(10)
        return true
    }    
    
}

