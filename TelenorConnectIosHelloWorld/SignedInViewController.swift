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
    var http: Http?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Signed in view controller did load");
        // We can get information about the user from The ID token payload…
        let idTokenPayload = oauth2Module?.getIdTokenPayload()
        if idTokenPayload != nil {
            let sub = idTokenPayload!["sub"] as? String
            signedInInfo.text = "User id: \(sub ?? "missing")"
            return;
        }
        print("-------------------------");
        print(idTokenPayload);
        // Or the userInfoEndpoint.
        signedInInfo.text = "Fetching user info…"
        http = Http()
        http!.authzModule = oauth2Module
        print(oauth2Module!.oauth2Session.accessToken);
        print(oauth2Module!.oauth2Session.refreshToken);
        print(oauth2Module!.oauth2Session.idToken);
        print("-------------------------");

        if !oauth2Module!.isAuthorized() {
            oauth2Module?.refreshAccessToken(completionHandler: { (accessToken, error) in
                guard error == nil else {
                    print("Got error when refreshing: \(String(describing: error))")
                    return
                }
                self.getUserInfoAndSetText()
            })
            return
        }
        
        getUserInfoAndSetText()
    }
    
    func getUserInfoAndSetText() -> Void {
        http?.request(method: .get, path: self.oauth2Module!.config.userInfoEndpoint!, completionHandler: { (response, error) in
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
