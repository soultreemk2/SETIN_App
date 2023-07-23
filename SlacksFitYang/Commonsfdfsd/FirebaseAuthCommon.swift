//
//  FirebaseAuthCommon.swift
//  SlacksFit
//
//  Created by YANG on 2022/11/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn

class FirebaseLoginInfo {
    static let shared = FirebaseLoginInfo()
    
    let db = Firestore.firestore()
    
    var emailLoginUserID: String?
    var googleLoginUserID: String?
    var appleLoginUserID: String?
    var emailUserNickname: String?
    var googleUserNickname: String?
    
    var docRef: DocumentReference!
    
    func getUserNickname(completion: @escaping(_ nickname: String) -> Void) { // 현재 로그인 한 사용자 이름
        if let emailLoginUserID = emailLoginUserID {
            docRef = db.collection("users").document(emailLoginUserID)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    let nick = data?["nickname"] as! String
                    completion(nick)
                } else {
                    completion("")
                }
            }
        }
        
        if googleLoginUserID != nil {
            completion(googleUserNickname!)
        }
    }
    
    func createUserInfo() {
        if let emailLoginUserID = emailLoginUserID {
            db.collection("users").document(emailLoginUserID).setData(["nickname": emailUserNickname!])
        }
        
        if let googleLoginUserID = googleLoginUserID {
            db.collection("users").document(googleLoginUserID).setData(["nickname": googleUserNickname!])
        }
    }
    
    func getCurrentUserInfo() -> String { // 현재 로그인 한 사용자정보
        if let emailLoginUserID = emailLoginUserID {
            return emailLoginUserID
            
        } else if let googleLoginUserID = googleLoginUserID {
            return googleLoginUserID
            
        } else { // 분기 탈일 없으나
            return "로그인 사용자 정보 없음"
        }
    }
    
    func logOutUserInfo() {
        if emailLoginUserID != nil {
            do {
                try Auth.auth().signOut()
                emailLoginUserID = nil
                emailUserNickname = nil
            } catch let signOutError as NSError {
                print("Error: signout \(signOutError.localizedDescription)")
            }
        }
        
        if googleLoginUserID != nil {
            GIDSignIn.sharedInstance()?.signOut()
            googleLoginUserID = nil
            googleUserNickname = nil
        }
        
        // TO DO: 애플 로그아웃 추가
    }
    
    private init() {
        
    }
}
