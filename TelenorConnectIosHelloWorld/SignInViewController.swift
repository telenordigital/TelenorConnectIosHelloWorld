//
//  ViewController.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Jørund Fagerjord on 10/03/16.
//  Copyright © 2016 Telenor Digital. All rights reserved.
//

import UIKit

import AeroGearHttp
import TDConnectIosSdk

class SignInViewController: UIViewController {
    
    var hasAppeared = false
    var performingingSegue = false
    var oauth2Module: OAuth2Module?
    let config = TelenorConnectConfig(clientId: "telenordigital-connectexample-ios",
        redirectUrl: "telenordigital-connectexample-ios://oauth2callback",
        useStaging: true,
        scopes: ["profile", "openid", "email"],
        accountId: "telenor-connect-ios-hello-world",
        isPublicClient: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oauth2Module = AccountManager.getAccountByConfig(config) ?? AccountManager.addAccount(self.config, moduleClass: TelenorConnectOAuth2Module.self)
    }
    
    @IBAction func signInPressed(sender: AnyObject) {
        guard let oauth2Module = self.oauth2Module else {
            return
        }
        
        oauth2Module.requestAuthorizationCode {(authorizationCode: AnyObject?, error: NSError?) -> Void in
            guard let authorizationCode = authorizationCode else {
                print("error=\(error)")
                return
            }
            
            print("authorizationCode=\(authorizationCode)")
        }
    }
}