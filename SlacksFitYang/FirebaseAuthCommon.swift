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
import SwiftJWT
import Alamofire

class FirebaseLoginInfo {
    static let shared = FirebaseLoginInfo()
    
    let db = Firestore.firestore()
    
    var emailLoginUserID: String?
    var googleLoginUserID: String?
    var appleLoginUserID: String?
    var emailUserNickname: String?
    var googleUserNickname: String?
    var appleUserNickname: String?
    var emailLoginUserEmail: String?
    var googleLoginUserEmail: String?
    var appleLoginUserEmail: String?
    
    var docRef: DocumentReference!
    
    func getUserNickname(completion: @escaping(_ nickname: String) -> Void) { // 현재 로그인 한 사용자 이름
        if let emailLoginUserID = emailLoginUserID {
            docRef = db.collection("users").document(emailLoginUserID)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    let nickname = data?["nickname"] as! String
                    completion(nickname)
                } else {
                    completion("")
                }
            }
        }
        
        if googleLoginUserID != nil {
            docRef = db.collection("users").document(googleLoginUserID!)
            docRef.addSnapshotListener { snapshot, error in
                if let document = snapshot {
                    let data = document.data()
                    let nickname = data?["nickname"] as? String
                    completion(nickname ?? self.googleUserNickname!)
                }
            }
        }
        
        if appleLoginUserID != nil {
            docRef = db.collection("users").document(appleLoginUserID!)
            docRef.addSnapshotListener { snapshot, error in
                if let document = snapshot {
                    let data = document.data()
                    let nickname = data?["nickname"] as? String
                    completion(nickname ?? self.appleUserNickname!)
                }
            }
        }
    }
    
    func createUserInfo() {
        if let emailLoginUserID = emailLoginUserID {
            db.collection("users").document(emailLoginUserID).setData(["nickname": emailUserNickname!])
        }
        
        if let googleLoginUserID = googleLoginUserID {
            db.collection("users").document(googleLoginUserID).setData(["nickname": googleUserNickname!], merge: true)
        }
        
        if let appleLoginUserID = appleLoginUserID {
            db.collection("users").document(appleLoginUserID).setData(["nickname": appleUserNickname!])
        }
    }
    
    func getCurrentUserInfo() -> String { // 현재 로그인 한 사용자정보(ID)
        if let emailLoginUserID = emailLoginUserID {
            return emailLoginUserID
            
        } else if let googleLoginUserID = googleLoginUserID {
            return googleLoginUserID
            
        } else if let appleLoginUserID = appleLoginUserID {
            return appleLoginUserID
            
        } else { // 분기 탈일 없으나
            return "로그인 사용자 정보 없음"
        }
    }
    func getCurrentUserEmail() -> String { // 현재 로그인 한 사용자 이메일
        if let emailLoginUserEmail = emailLoginUserEmail {
            return emailLoginUserEmail
            
        } else if let googleLoginUserEmail = googleLoginUserEmail {
            return googleLoginUserEmail
            
        } else if let appleLoginUserEmail = appleLoginUserEmail {
            return appleLoginUserEmail
            
        } else { // 분기 탈일 없으나
            return "로그인 사용자 정보 없음"
        }
    }
    
    func getCurrentLoginMethod() -> String { // 현재 로그인 수단 (이메일,구글,애플)
        if let emailLoginUserID = emailLoginUserID {
            return "email"
        } else if let googleLoginUserID = googleLoginUserID {
            return "google"
        } else {
            return "apple"
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
        
        // TO DO: 애플 로그아웃 추가 > 기본으로 제공하는게 없는 듯 함...
    }
    
    func deleteAutoLoginInfo() {
        UserDefaults.standard.removeObject(forKey: "isAutoLogin")

        if googleLoginUserID != nil {
            UserDefaults.standard.removeObject(forKey: "googleLoginUserID")
            UserDefaults.standard.removeObject(forKey: "googleUserNickname")
            UserDefaults.standard.removeObject(forKey: "googleLoginUserEmail")
        }
        
        if appleLoginUserID != nil {
            UserDefaults.standard.removeObject(forKey: "appleLoginUserID")
            UserDefaults.standard.removeObject(forKey: "appleUserNickname")
            UserDefaults.standard.removeObject(forKey: "appleLoginUserEmail")
        }
    }
    
    func deleteUserInfo() {
        // DB 정보 삭제
        let documentIDRef = db.collection("users").document(getCurrentUserInfo())
        documentIDRef.delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        
        // 컬렉션 내 하위document는 수동삭제 해야함 (애플이 권장하지 않는다고 하나.. 서버단에서 삭제하라네?..)
        for i in 1...14 {
            documentIDRef.collection("survey").document("surveyDoc\(i)").delete()
            documentIDRef.collection("recording\(i)").document("day\(i)").delete()
            documentIDRef.collection("ExerciseList").document("day\(i)").delete()
                                                                                                
        }
        
        // TO DO: 애플로그인은 토큰도 삭제해주어야 함
        if appleLoginUserID != nil {
            let jwtString = makeJWT()
            UserDefaults.standard.set(jwtString, forKey: "AppleClientSecret")
            
            let taCode = UserDefaults.standard.object(forKey: "theAuthorizationCode") as? String ?? ""
            getAppleRefreshToken(code: taCode, completionHandler: { output in
                let clientSecret = jwtString
                if let refreshToken = output{
                    print("Client_Secret - \(clientSecret)")
                    print("refresh_token - \(refreshToken)")

                    // api 통신
                    self.revokeAppleToken(clientSecret: clientSecret, token: refreshToken) {
                        print("Apple revoke token Success")
                        // 애플 탈퇴 구현을 위해 저장해둔 UserDefault 삭제
                        UserDefaults.standard.removeObject(forKey: "AppleClientSecret")
                        UserDefaults.standard.removeObject(forKey: "theAuthorizationCode")
                    }
                }else{
                    print("회원탈퇴 실패")
                }
            })
        }
        
    }

    /// 애플로그인 탈퇴: client_secret(JWT) 생성하기
    //client_secret
    func makeJWT() -> String{
        let myHeader = Header(kid: "4T8D97LJ22") //sign in with
        struct MyClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }

        let nowDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = 6
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        let myClaims = MyClaims(iss: "7GU55NHY2N",
                                iat: iat,
                                exp: exp,
                                aud: "https://appleid.apple.com",
                                sub: "yang.SlacksFitYang")

        var myJWT = JWT(header: myHeader, claims: myClaims)

        //JWT 발급을 요청값의 암호화 과정에서 다운받아두었던 Key File이 필요하다.(.p8 파일)
        guard let url = Bundle.main.url(forResource: "AuthKey_4T8D97LJ22", withExtension: "p8") else{
            return ""
        }
        let privateKey: Data = try! Data(contentsOf: url, options: .alwaysMapped)

        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)

        print("🗝 singedJWT - \(signedJWT)")
        return signedJWT
    }
    
    /// 애플로그인 탈퇴: 토큰 생성하기
    //client_refreshToken
    func getAppleRefreshToken(code: String, completionHandler: @escaping (String?) -> Void) {
        
        guard let secret = UserDefaults.standard.string(forKey: "AppleClientSecret") else {return}
        
        let url = "https://appleid.apple.com/auth/token?client_id=yang.SlacksFitYang&client_secret=\(secret)&code=\(code)&grant_type=authorization_code"
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        
        print("🗝 clientSecret - \(UserDefaults.standard.string(forKey: "AppleClientSecret"))")
        print("🗝 authCode - \(code)")
        
        let a = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
            .validate(statusCode: 200..<500)
            .responseData { response in
                print("🗝 response - \(response.description)")
                
                switch response.result {
                case .success(let output):
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(AppleTokenResponse.self, from: output){
                        if decodedData.refresh_token == nil{
                            print("토큰 생성 실패")
                        } else{
                            completionHandler(decodedData.refresh_token)
                        }
                    }
                    
                case .failure(_):
                    //로그아웃 후 재로그인하여
                    print("애플 토큰 발급 실패 - \(response.error.debugDescription)")
                }
            }
    }
    
    /// 애플로그인 탈퇴: 토큰 revoke
    func revokeAppleToken(clientSecret: String, token: String, completionHandler: @escaping () -> Void) {
           let url = "https://appleid.apple.com/auth/revoke?client_id=yang.SlacksFitYang&client_secret=\(clientSecret)&token=\(token)&token_type_hint=refresh_token"
           let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

           AF.request(url,
                      method: .post,
                      headers: header)
           .validate(statusCode: 200..<600)
           .responseData { response in
               guard let statusCode = response.response?.statusCode else { return }
               if statusCode == 200 {
                   print("애플 토큰 삭제 성공!")
                   completionHandler()
               }
           }
       }
    
    
    private init() {
        
    }
}

// MARK: - 애플 엑세스 토큰 발급 응답 모델
struct AppleTokenResponse: Codable {
    var access_token: String?
    var token_type: String?
    var expires_in: Int?
    var refresh_token: String?
    var id_token: String?

    enum CodingKeys: String, CodingKey {
        case refresh_token = "refresh_token"
    }
}
