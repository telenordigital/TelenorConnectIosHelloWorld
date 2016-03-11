//
//  SignedInViewController.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Jørund Fagerjord on 11/03/16.
//  Copyright © 2016 Telenor Digital. All rights reserved.
//

import UIKit

import AeroGearOAuth2

class SignedInViewController: UIViewController {
    @IBOutlet weak var signedInInfo: UILabel!
    
    var infoText: String?
    var oauth2Module: OAuth2Module?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oauth2Module?.isAuthorized()=\(oauth2Module?.isAuthorized())")
        
        if let infoText = infoText {
            signedInInfo.text = infoText
        } else {
            signedInInfo.text = "Loading user info…"
            self.oauth2Module?.login { (accessToken: AnyObject?, userInfo: OpenIDClaim?, error: NSError?) -> Void in
                if let accessToken = accessToken {
                    print("accessToken=\(accessToken)")
                    self.signedInInfo.text = String(userInfo)
                }
                if let error = error {
                    print("error=\(error)")
                }
            }
        }
    }
    
    @IBAction func signOut(sender: AnyObject) {
        print("Signing out…")
        oauth2Module?.revokeAccess({ (response: AnyObject?, error: NSError?) -> Void in
            print("response=\(response)")
            print("error=\(error)")

            self.performSegueWithIdentifier("signedOut", sender: nil)
        })
    }
    
    
}
