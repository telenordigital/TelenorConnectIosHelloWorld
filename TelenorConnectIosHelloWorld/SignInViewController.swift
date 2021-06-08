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
import AuthenticationServices

class SignInViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    var hasAppeared = false
    var performingSegue = false
    var oauth2Module: OAuth2Module?
    var viewControllerContext: Any? = nil
    
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addActionButton();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasAppeared = false
        performingSegue = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let v = self
        let config = TelenorConnectConfig(clientId: "telenordigital-connectexample-ios",
                                          redirectUrl: "telenordigital-connectexample-ios://oauth2callback",
                                          useStaging: true,
                                          scopes: ["profile", "openid", "email"],
                                          accountId: "telenor-connect-ios-hello-world",
                                          claims: nil,
                                          optionalParams: nil,
                                          isPublicClient: true,
                                          viewControllerContext: v,
                                          idProvider: IdProvider.telenorId);
        oauth2Module = AccountManager.getAccountBy(config: config) ?? AccountManager.addAccountWith(config: config, moduleClass: TelenorConnectOAuth2Module.self)
        // Note: The method will be called after (Safari) WebView completes logging in the user
        if oauth2Module!.oauth2Session.refreshToken != nil && !performingSegue {
            performingSegue = true
            self.performSegue(withIdentifier: "signedIn", sender: nil)
        }
        
        hasAppeared = true
    }

    @IBAction func signInPressed(_ sender: AnyObject) {
        guard let oauth2Module = self.oauth2Module else {
            return
        }
        
        if oauth2Module.oauth2Session.accessToken != nil {
            self.performSegue(withIdentifier: "signedIn", sender: nil)
            print("Access token is not nil");
            return
        }
        
        oauth2Module.requestAccess {(accessToken: AnyObject?, error: NSError?) -> Void in
            guard let accessToken = accessToken else {
                print("errorhere=\(String(describing: error))")
                return
            }
            
            
            print("accessToken=\(accessToken)")
            if self.hasAppeared && !self.performingSegue {
                self.performingSegue = true
                self.performSegue(withIdentifier: "signedIn", sender: nil)
            }
        }
    }
    
    private func addActionButton() {
        let textView = AboutTextLink(frame: CGRect(x: 50, y: 300, width: 200, height: 100), idProvider: IdProvider.telenorId, idLocale: IdLocale.danish)
        textView.frame.size.width = 200
        textView.backgroundColor = UIColor.red
        textView.sizeToFit()
        view.addSubview(textView)
    }
    
    func showPopup(_ sender: Any) {
        let modalView = AboutModalOverlay(frame: self.view.bounds)
        let titleFont = UIFont(name: "Telenor-Bold", size: 24)
        let subtitleFont = UIFont(name: "Telenor", size: 17)
        let descriptionFont = UIFont(name: "Telenor-Light", size: 17)
                
        print("Tokens suka")
        print(oauth2Module!.oauth2Session.accessToken);
        print(oauth2Module!.oauth2Session.refreshToken);
        print(oauth2Module!.oauth2Session.idToken);

        view.addSubview(modalView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signedIn") {
            let signedInController = segue.destination as! SignedInViewController
            signedInController.oauth2Module = oauth2Module
        }
    }
}
