//
//  AppDelegate.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Jørund Fagerjord on 10/03/16.
//  Copyright © 2016 Telenor Digital. All rights reserved.
//

import UIKit

import AeroGearOAuth2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let config = TelenorConnectConfig(clientId: "telenordigital-connectexample-android",
            useStaging: true,
            scopes: ["profile", "openid", "email"],
            accountId: "telenor-connect-ios-hello-world")

        let oauth2Module = AccountManager.getAccountByConfig(config) ?? AccountManager.addAccount(config, moduleClass: TelenorConnectOAuth2Module.self)
        
        if (oauth2Module.isAuthorized()) {
            let controller: SignedInViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SignedInViewController") as! SignedInViewController
            controller.oauth2Module = oauth2Module
            self.window?.rootViewController = controller
        } else {
            let controller: SignInViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
            self.window?.rootViewController = controller
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification, object:nil, userInfo:[UIApplicationLaunchOptionsURLKey:url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        return true
    }
    
}

