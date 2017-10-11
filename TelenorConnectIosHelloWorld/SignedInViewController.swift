//
//  SignedInViewController.swift
//  TelenorConnectIosHelloWorld
//
//  Created by Jørund Fagerjord on 11/03/16.
//  Copyright © 2016 Telenor Digital. All rights reserved.
//

import UIKit

import AeroGearHttp
import TDConnectIosSdk

class SignedInViewController: UIViewController {
    @IBOutlet weak var signedInInfo: UILabel!
    
    var userInfo: AnyObject?
    var oauth2Module: OAuth2Module?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("oauth2Module?.isAuthorized()=\(String(describing: oauth2Module?.isAuthorized()))")
        
        // We can get information about the user from the SignInViewController…
        if let infoText = userInfo {
            signedInInfo.text = String(describing: infoText)
            return
        }
        
        // The ID token payload…
        do {
            let idTokenPayload = try oauth2Module?.getIdTokenPayload()
            signedInInfo.text = String(describing: idTokenPayload)
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
        
        http.request(method: .get, path: userInfoEndpoint, completionHandler: { (response, error) in
            if let error = error {
                print("Got error when fetching userinfo. error=\(error)")
                return
            }
            
            self.signedInInfo.text = String(describing: response)
        })
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        print("Signing out…")
        oauth2Module?.revokeAccess(completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
            print("response=\(String(describing: response))")
            print("error=\(String(describing: error))")

            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
}
