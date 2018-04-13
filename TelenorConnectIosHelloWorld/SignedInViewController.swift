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
        let oneMinuteIntoPast = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let authenticatedMoreThanAMinuteAgo = lastBioAuthStarted == nil || lastBioAuthStarted! < oneMinuteIntoPast
        guard authenticatedMoreThanAMinuteAgo else {
            return
        }
        let appWentIntoBackgroundMoreThanAMinuteAgo = enteredBackground == nil || enteredBackground! < oneMinuteIntoPast
        guard appWentIntoBackgroundMoreThanAMinuteAgo else {
            return
        }
        
        lastBioAuthStarted = Date()
        biometricAuthenticateUser()
    }
    
    func biometricAuthenticateUser() {
        let myContext = LAContext()
        let myLocalizedReasonString = "Please authenticate to prove you are the device owner"
        
        var authError: NSError?
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                self.signedInInfo.text = "Waiting for biometric auth..."
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    if success {
                        // User authenticated successfully, take appropriate action
                        print("success: \(success)")
                        self.main()
                    } else {
                        // User did not authenticate successfully, look at error and take appropriate action
                        print("evaluateError: \(evaluateError!)")
                        
                        DispatchQueue.main.async {
                            self.signedInInfo.text = "Sorry, biometrics auth failed"
                        }
                    }
                }
            } else {
                print("authError: \(authError!)")
                // Could not evaluate policy; look at authError and present an appropriate message to user
                self.signedInInfo.text = "Sorry, biometrics auth could not be done"
            }
        } else {
            // Fallback on earlier versions
            print("You're device is too old")
            // TODO use .deviceOwnerAuthentication instead
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
