//
//  AppDelegate.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/01/08.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import AuthenticationServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance()?.clientID = "34704401787-vd5mbuj532vh7uq2pjg986g1khoh4ifa.apps.googleusercontent.com"
        
        // apple ID 인증상태 조회
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let appleUserIdentifier = UserDefaults.standard.object(forKey: "appleLoginUserID") as? String ?? "" // apple login을 한번이라도 성공했으면 userDefault에 저장됨
        
        appleIDProvider.getCredentialState(forUserID: appleUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                //인증성공 상태
                print("apple login authorized")
            case .revoked:
                //인증만료 상태
                print("apple login revoked")
            default:
                //.notFound 등 이외 상태
                print("apple login error:", error?.localizedDescription)
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle( url )
    }

}

