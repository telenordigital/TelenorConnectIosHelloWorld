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
        accountId: "telenor-connect-ios-hello-world")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oauth2Module = AccountManager.getAccountByConfig(config) ?? AccountManager.addAccount(self.config, moduleClass: TelenorConnectOAuth2Module.self)
        print("oauth2Module!.isAuthorized()=\(oauth2Module!.isAuthorized())")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hasAppeared = false
        performingingSegue = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Note: The method will be called after (Safari) WebView completes logging in the user
        if oauth2Module!.isAuthorized() && !performingingSegue {
            performingingSegue = true
            self.performSegueWithIdentifier("signedIn", sender: nil)
        }
        hasAppeared = true
    }

    @IBAction func signInPressed(sender: AnyObject) {
        guard let oauth2Module = self.oauth2Module else {
            return
        }
        
        if oauth2Module.isAuthorized() {
            self.performSegueWithIdentifier("signedIn", sender: nil)
            return
        }
        
        oauth2Module.requestAccess {(accessToken: AnyObject?, error: NSError?) -> Void in
            guard let accessToken = accessToken else {
                print("error=\(error)")
                return
            }
            
            print("accessToken=\(accessToken)")
            if self.hasAppeared && !self.performingingSegue {
                self.performingingSegue = true
                self.performSegueWithIdentifier("signedIn", sender: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "signedIn") {
            let signedInController = segue.destinationViewController as! SignedInViewController
            signedInController.oauth2Module = oauth2Module
        }
    }
}