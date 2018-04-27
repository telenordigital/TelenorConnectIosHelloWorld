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
import LocalAuthentication

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
        print("enteredBackground!: \(enteredBackground!)")
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification?) {
        let calendar = Calendar.current
        let _5secondsAgo = calendar.date(byAdding: .second, value: -5, to: Date())!
        guard bioAuthCompleted == nil || bioAuthCompleted! < _5secondsAgo else {
            return
        }
        guard lastBioAuthStarted == nil || lastBioAuthStarted! < _5secondsAgo else {
            return
        }
        guard enteredBackground == nil || enteredBackground! < _5secondsAgo else {
            return
        }
        
        lastBioAuthStarted = Date()
        biometricAuthenticateUser()
    }
    
    func biometricAuthenticateUser() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Please authenticate to prove you are the device owner"
        
        var authError: NSError?
        guard myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            print("authError: \(authError!)")
            // Could not evaluate policy; look at authError and present an appropriate message to user
            self.signedInInfo.text = "Sorry, biometrics auth could not be done"
            return
        }
        
        self.signedInInfo.text = "Waiting for biometric auth..."
        myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
            self.bioAuthCompleted = Date()
            guard success else {
                // User did not authenticate successfully, look at error and take appropriate action
                print("evaluateError: \(evaluateError!)")
                
                DispatchQueue.main.async {
                    self.signedInInfo.text = "Sorry, biometrics auth failed"
                }
                return
            }
            
            // User authenticated successfully, take appropriate action
            print("bioAuth success")
            self.main()
        }
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
