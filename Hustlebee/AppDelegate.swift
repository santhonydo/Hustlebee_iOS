//
//  AppDelegate.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/1/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        customizeAppearance()
        
        let userAuthenticated = UserDefaults.standard.bool(forKey: "userLoggedIn")
        
    
        if userAuthenticated {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        } else {
            let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = rootViewController
        }
        
        let cognitoIdentityPoolId = "us-east-1:c8bb575a-1995-4b55-a82c-9bf8e9c5cd23"
        let cognitoRegionType = AWSRegionType.usEast1
        let defaultServiceRegionType = AWSRegionType.usWest1
        
        let credentialProviders = AWSCognitoCredentialsProvider(regionType: cognitoRegionType, identityPoolId: cognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: defaultServiceRegionType, credentialsProvider: credentialProviders)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    
    func customizeAppearance() {
        let barTintColor = UIColor(red: 228/255, green: 187/255, blue: 22/255, alpha: 1)
        UISearchBar.appearance().barTintColor = barTintColor
        window!.tintColor = barTintColor
    }


}

