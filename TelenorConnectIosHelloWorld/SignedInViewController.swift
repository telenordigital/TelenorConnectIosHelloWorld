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
    var lastBioAuthStarted: Date?
    var enteredBackground: Date?
    var bioAuthCompleted: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(notification:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(notification:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        applicationDidBecomeActive(notification: nil)
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification?) {
        enteredBackground = Date()
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification?) {
        let timedelta = abs(Double(enteredBackground?.timeIntervalSinceNow ?? 0))
        guard enteredBackground == nil || timedelta < 5 else {
            self.dismiss(animated: true, completion: nil)
            print("Sent back to front page because the app had been closed for \(timedelta) seconds")
            return
        }
        main()
        
    }
    
    
    func main() -> Void {
        // We can get information about the user from The ID token payload…
        let idTokenPayload = oauth2Module?.getIdTokenPayload()
        if idTokenPayload != nil {
            let sub = idTokenPayload!["sub"] as? String
            DispatchQueue.main.async {
                self.signedInInfo.text = "User id: \(sub ?? "missing")"
            }
            return;
        }
        
        // Or the userInfoEndpoint.
        DispatchQueue.main.async {
            self.signedInInfo.text = "Fetching user info…"
        }
        http = Http()
        http!.authzModule = oauth2Module
        
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
            DispatchQueue.main.async {
                self.signedInInfo.text = String(describing: response)
            }
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
