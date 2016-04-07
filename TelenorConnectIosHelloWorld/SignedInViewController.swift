//
//  SignedInViewController.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Jørund Fagerjord on 11/03/16.
//  Copyright © 2016 Telenor Digital. All rights reserved.
//

import UIKit

import AeroGearHttp
import AeroGearOAuth2

class SignedInViewController: UIViewController {
    @IBOutlet weak var signedInInfo: UILabel!
    
    var userInfo: AnyObject?
    var oauth2Module: OAuth2Module?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oauth2Module?.isAuthorized()=\(oauth2Module?.isAuthorized())")
        
        // We can get information about the user from the SignInViewController…
        if let infoText = userInfo {
            signedInInfo.text = String(infoText)
            return
        }
        
        // The ID token payload…
        do {
            let idTokenPayload = try oauth2Module?.getIdTokenPayload()
            signedInInfo.text = String(idTokenPayload)
            return
        } catch {
            print("Failed to getIdTokenPayload: \(error)")
        }
        
        // Or the userInfoEndpoint.
        signedInInfo.text = "Fetching user info…"
        let http = Http()
        http.authzModule = oauth2Module
        guard let userInfoEndpoint = self.oauth2Module?.config.userInfoEndpoint else {
            self.signedInInfo.text = "Couldn't load userinfo"
            return
        }
        
        http.request(.GET, path: userInfoEndpoint, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                print("Got error when fetching userinfo. error=\(error)")
                return
            }
            
            self.signedInInfo.text = String(response)
        })
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
