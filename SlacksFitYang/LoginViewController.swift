//
//  LoginViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/05.
//

import SnapKit
import UIKit
import GoogleSignIn
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    let userInfo = FirebaseLoginInfo.shared
    var isAutoLogin: Bool = false
    
    var loadingView: UIView = UIView()
    var loadedView: UIImageView?
    
    //--------------------- Login StackView ------------------------//
    lazy var emailPwdBtn: UIButton = {
       let btn = UIButton()
        btn.layer.cornerRadius = 3
        btn.backgroundColor = .white
        btn.setTitle("이메일/비밀번호로 계속하기", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return btn
    }()
    
    lazy var googleBtn: GIDSignInButton = {
        let btn = GIDSignInButton()
        btn.style = .wide
        return btn
    }()
    
    lazy var appleBtn: ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return btn
    }()
    
    lazy var autoLoginBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.rectangle.fill"), for: .selected)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 3
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.setTitle("자동로그인", for: .normal)
        btn.addTarget(self, action: #selector(BtnClicked), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var loginStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailPwdBtn, googleBtn, appleBtn])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()

    //--------------------- View: VER1 ------------------------//
    private lazy var mainLogo_1: UILabel = {
        let mainLogo = UILabel()
        mainLogo.textColor = UIColor.mainColor
        mainLogo.text = "SETIN"
        mainLogo.font = .systemFont(ofSize: 50, weight: .bold)
        return mainLogo
    }()
    
    private lazy var descriptLabel_1: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = UIColor.mainColor
        label.text = "벌크업부터 \n다이어트까지 \n확실한 헬스 코치"
        return label
    }()
    
    private lazy var imageView_1: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "dumbell_3.png"))
        imgView.frame.size.width = 330
        imgView.frame.size.height = 100
        
        return imgView
    }()
    
    //--------------------- View: VER2 ------------------------//
    private lazy var mainLogo_2: UILabel = {
        let mainLogo = UILabel()
        mainLogo.textColor = .white
        mainLogo.text = "SETIN"
        mainLogo.font = .systemFont(ofSize: 50, weight: .bold)
        return mainLogo
    }()
    
    private lazy var descriptLabel_2: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = .white
        label.text = "벌크업부터 \n다이어트까지 \n확실한 헬스 코치"
        return label
    }()
    
    private lazy var imageView_2: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "login_back.png"))
        imgView.frame.size.width = self.view.frame.size.width
        imgView.frame.size.height = self.view.frame.size.height
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    // MARK: View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Google SignIn을 위한 VC (웹뷰)
        GIDSignIn.sharedInstance().presentingViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 자동로그인 정보
        setupAutoLoginInfo()

        setupLoadingView() // 첫번째뷰는 add까지 완료
        loadedView = imageView_2 // 두번째 뷰는 객체만 만들어두고..
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 뷰 교체 애니메이션
        //self.fromView1ToView2()
        setupLoadedView() //
        UIView.transition(from: loadingView, // viewDidAppear 순간 첫번째 뷰 사라짐
                          to: loadedView!,   // 첫번째뷰 사라지고 두번째뷰가 완전 생성 및 addSubiew
                          duration: 3.0,     // 애니메이션 길이(전환되는 속도)
                          options: [.transitionCrossDissolve]) { _ in
//                        self.setupLoadingView()
        }
    }
    
    // MARK: Button Action
    @objc private func BtnClicked(_sender: UIButton) {
        switch _sender {
        case emailPwdBtn:
            let emailLoginVC = EmailAddressViewController()
            emailLoginVC.isAutoLogin = isAutoLogin
            navigationController?.pushViewController(emailLoginVC, animated: true)
            // back버튼 안보임
            
        case googleBtn:
            let signIn = GIDSignIn.sharedInstance()
            signIn?.delegate = self
            
        case appleBtn:
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        case autoLoginBtn:
            autoLoginBtn.isSelected.toggle()
            isAutoLogin = autoLoginBtn.isSelected
            
        default:
            return
        }
    }
}

// MARK: Login Delegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil { // login 성공
            if isAutoLogin {
                UserDefaults.standard.set(true, forKey: "isAutoLogin") // 자동로그인 선택 여부
                UserDefaults.standard.set(user.userID, forKey: "googleLoginUserID")
                UserDefaults.standard.set(user.profile.name, forKey: "googleUserNickname")
                UserDefaults.standard.set(user.profile.email, forKey: "googleLoginUserEmail")
            }
            
            // 사용자 정보 저장
            userInfo.googleLoginUserID = user.userID
            userInfo.googleUserNickname = user.profile.name
            userInfo.googleLoginUserEmail = user.profile.email
            userInfo.createUserInfo()
            self.navigationController?.pushViewController(TabBarController(), animated: true)
            
        } else {
            print("login error:\(error.localizedDescription)")
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if isAutoLogin {
                UserDefaults.standard.set(true, forKey: "isAutoLogin") // 자동로그인 선택 여부
            }
            
            let fullName = appleIDCredential.fullName
            let name = (fullName?.familyName ?? "이름") + (fullName?.givenName ?? "비공개")

            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleLoginUserID")
            UserDefaults.standard.set(name, forKey: "appleUserNickname")
            UserDefaults.standard.set(appleIDCredential.email, forKey: "appleLoginUserEmail")
            
            userInfo.appleLoginUserID = appleIDCredential.user
            userInfo.appleUserNickname = name
            userInfo.appleLoginUserEmail = appleIDCredential.email //email
            userInfo.createUserInfo()
            
            if  let authorizationCode = appleIDCredential.authorizationCode,
                let identityToken = appleIDCredential.identityToken,
                let authCodeString = String(data: authorizationCode, encoding: .utf8),
                let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                print("authorizationCode: \(authorizationCode)")
                print("identityToken: \(identityToken)")
                print("authCodeString: \(authCodeString)")
                print("identifyTokenString: \(identifyTokenString)")
                
                UserDefaults.standard.set(authCodeString, forKey: "theAuthorizationCode")
            }
            
            // 로그인 완료 후 화면 이동
            self.navigationController?.pushViewController(TabBarController(), animated: true)
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error in Apple login: ",error.localizedDescription )
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: Custom Method
private extension LoginViewController {
    func setupAutoLoginInfo() {
        // 자동로그인 설정 되어있으면 1)UserDefualt에 저장된 값으로 firebase저장 2) TabBar로 이동
        let autoLoginYN = UserDefaults.standard.object(forKey: "isAutoLogin") as? Bool ?? nil
        if autoLoginYN == true {
            let emailLoginID = UserDefaults.standard.object(forKey: "emailLoginID") as? String ?? nil
            let emailLoginEmail = UserDefaults.standard.object(forKey: "emailLoginEmail") as? String ?? nil
            let emailLoginNickName = UserDefaults.standard.object(forKey: "emailLoginNickName") as? String ?? nil
            
            let googleID = UserDefaults.standard.object(forKey: "googleLoginUserID") as? String ?? nil
            let googleNickName = UserDefaults.standard.object(forKey: "googleUserNickname") as? String ?? nil
            let googleEmail = UserDefaults.standard.object(forKey: "googleLoginUserEmail") as? String ?? nil
            
            let appleID = UserDefaults.standard.object(forKey: "appleLoginUserID") as? String ?? nil
            let appleNickName = UserDefaults.standard.object(forKey: "appleUserNickname") as? String ?? nil
            let appleEmail = UserDefaults.standard.object(forKey: "appleLoginUserEmail") as? String ?? nil
            
            if emailLoginID != nil {
                userInfo.emailLoginUserID = emailLoginID
                userInfo.emailLoginUserEmail = emailLoginEmail
                userInfo.emailUserNickname = emailLoginNickName
            }
            
            if googleID != nil {
                userInfo.googleLoginUserID = googleID
                userInfo.googleUserNickname = googleNickName
                userInfo.googleLoginUserEmail = googleEmail
            }
            
            if appleID != nil {
                userInfo.appleLoginUserID = appleID
                userInfo.appleUserNickname = appleNickName
                userInfo.appleLoginUserEmail = appleEmail
            }
            // 바로 TabBar로 이동
            self.navigationController?.pushViewController(TabBarController(), animated: true)
        }
    }
    
    func setupLoadingView() {
        print("setupLoadingView")
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        loadingView.backgroundColor = .white
        view.addSubview(loadingView)
        
        [mainLogo_1, descriptLabel_1, imageView_1].forEach {
            loadingView.addSubview($0)
        }
        
        mainLogo_1.snp.makeConstraints {
            $0.top.equalToSuperview().inset(130)
            $0.leading.equalToSuperview().inset(50)
            $0.width.equalTo(180)
            $0.height.equalTo(60)
        }
        
        descriptLabel_1.snp.makeConstraints {
            $0.top.equalTo(mainLogo_1.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(50)
        }
        
        imageView_1.snp.makeConstraints {
            $0.top.equalTo(descriptLabel_1.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(90)
        }
    }
    
    func setupLoadedView() {
        print("setupLoadedView")
        view.addSubview(imageView_2)
        [mainLogo_2, descriptLabel_2, loginStackView, autoLoginBtn].forEach {
            imageView_2.addSubview($0)
        }
        
        mainLogo_2.snp.makeConstraints {
            $0.top.equalToSuperview().inset(130)
            $0.leading.equalToSuperview().inset(50)
            $0.width.equalTo(180)
            $0.height.equalTo(60)
        }
        descriptLabel_2.snp.makeConstraints {
            $0.top.equalTo(mainLogo_2.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(50)
        }
        
        loginStackView.snp.makeConstraints {
            $0.top.equalTo(descriptLabel_2.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(60)
        }
        
        autoLoginBtn.snp.makeConstraints {
            $0.top.equalTo(loginStackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(80)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }
        
        // 로그인 버튼 액션
        [emailPwdBtn, googleBtn, appleBtn].forEach {
            $0.addTarget(self, action: #selector(BtnClicked), for: .touchUpInside)
        }
    }
    
    
    func fromView1ToView2() {
        UIView.transition(from: loadingView, // view에서 사라짐
                          to: imageView_2, // view.addSubview(loadedView)
                          duration: 3.0,
                          options: [.transitionCrossDissolve]) { _ in
                                    self.fromView2ToView1()
        }
    }
    
    func fromView2ToView1() {
        UIView.transition(from: imageView_2, // view에서 사라짐
                          to: loadingView, // view.addSubview(loadedView)
                          duration: 3.0,
                          options: [.transitionCrossDissolve]) { _ in
                                    self.fromView1ToView2()
        }
    }
}


