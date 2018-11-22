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
    @IBOutlet weak var signInButton: UIButton!
    
    var performingSegue = false
    var oauth2Module: OAuth2Module?
    let config = TelenorConnectConfig(clientId: "telenordigital-connectexample-ios",
        redirectUrl: "telenordigital-connectexample-ios://oauth2callback",
        useStaging: true,
        scopes: ["profile", "openid", "email"],
        accountId: "telenor-connect-ios-hello-world",
        webView: true,
        useBiometrics: true,
        optionalParams: ["ui_locales": "no"]
        )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.oauth2Module = AccountManager.getAccountBy(config: config) ?? AccountManager.addAccountWith(config: self.config, moduleClass: TelenorConnectOAuth2Module.self)
        print("oauth2Module!.oauth2Session.accessToken != nil=\(oauth2Module!.oauth2Session.accessToken != nil)")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard oauth2Module?.oauth2Session.accessToken == nil else {
            let supportedBiometrics = oauth2Module?.getAvailableBiometrics() ?? BiometricTypes.none
            var buttonText = "Sign in with "
            print("supported biometrics: " + supportedBiometrics.rawValue)
            switch supportedBiometrics{
            case BiometricTypes.face_id:
                buttonText += "face id"
            case BiometricTypes.touch_id:
                buttonText += "touch id"
            default:
                buttonText += "Telenor Connect"
            }
            self.signInButton.setTitle(buttonText, for: .normal)
            return
        }
        self.signInButton.setTitle("Sign in with Telenor Connect", for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        performingSegue = false
    }

    @IBAction func signInPressed(_ sender: AnyObject) {
        print("pressed")
        guard let oauth2Module = self.oauth2Module else {
            print("no oauth2 module")
            return
        }
        
        oauth2Module.authenticate(viewController: self, oauth2Module: oauth2Module) { (error:Error?) in
            if(error != nil){
                print("unable to login \(error)")
                return
            }
            self.performSegue(withIdentifier: "signedIn", sender: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signedIn") {
            let signedInController = segue.destination as! SignedInViewController
            signedInController.oauth2Module = oauth2Module
        }
    }
}
