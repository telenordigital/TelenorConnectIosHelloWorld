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
    
    var userInfo: AnyObject?
    var oauth2Module: OAuth2Module?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oauth2Module?.isAuthorized()=\(oauth2Module?.isAuthorized())")
        
        do {
            try print("oauth2Module.getIdTokenPayload()=\(oauth2Module?.getIdTokenPayload())")
        } catch {
            print("Failed to getIdTokenPayload: \(error)")
        }
        
        if let infoText = userInfo {
            signedInInfo.text = String(infoText)
            return
        }
        
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
    
    @IBAction func signOut(sender: AnyObject) {
        print("Signing out…")
        oauth2Module?.revokeAccess({ (response: AnyObject?, error: NSError?) -> Void in
            print("response=\(response)")
            print("error=\(error)")

            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    
}
