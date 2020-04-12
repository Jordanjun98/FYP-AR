//
//  AppDelegate.swift
//  furnitureApp
//
//  Created by Jordan on 21/10/2019.
//  Copyright © 2019 Jordan. All rights reserved.
//

import UIKit
import Firebase
import Braintree
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "Ab7VGlCf6WBFM98ZVDGQF9js-u294PN2S7VLNU_g5i1P1LJrNK8ISSFukNmL8Y0ze6QwVNm0BRWjKyFr", PayPalEnvironmentSandbox: "Ab7VGlCf6WBFM98ZVDGQF9js-u294PN2S7VLNU_g5i1P1LJrNK8ISSFukNmL8Y0ze6QwVNm0BRWjKyFr"])
        
        
        BTAppSwitch.setReturnURLScheme("Jordan.furnitureApp.payments")
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("Jordan.furnitureApp.payments") == .orderedSame {
               return BTAppSwitch.handleOpen(url, options: options)
           }
           return false
    }
}

