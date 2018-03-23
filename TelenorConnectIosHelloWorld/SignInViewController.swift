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
        webView:true,
        optionalParams: ["ui_locales": "no"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oauth2Module = AccountManager.getAccountBy(config: config) ?? AccountManager.addAccountWith(config: self.config, moduleClass: TelenorConnectOAuth2Module.self)
        print("oauth2Module!.oauth2Session.refreshToken != nil=\(oauth2Module!.oauth2Session.refreshToken != nil)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasAppeared = false
        performingingSegue = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Note: The method will be called after (Safari) WebView completes logging in the user
        if oauth2Module!.oauth2Session.refreshToken != nil && !performingingSegue {
            performingingSegue = true
            self.performSegue(withIdentifier: "signedIn", sender: nil)
        }
        hasAppeared = true
    }

    @IBAction func signInPressed(_ sender: AnyObject) {
        guard let oauth2Module = self.oauth2Module else {
            return
        }
        
        if oauth2Module.oauth2Session.refreshToken != nil {
            self.performSegue(withIdentifier: "signedIn", sender: nil)
            return
        }
        
        oauth2Module.requestAccess {(accessToken: AnyObject?, error: NSError?) -> Void in
            guard let accessToken = accessToken else {
                print("error=\(String(describing: error))")
                return
            }
            
            print("accessToken=\(accessToken)")
            if self.hasAppeared && !self.performingingSegue {
                self.performingingSegue = true
                self.performSegue(withIdentifier: "signedIn", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signedIn") {
            let signedInController = segue.destination as! SignedInViewController
            signedInController.oauth2Module = oauth2Module
        }
    }
}
