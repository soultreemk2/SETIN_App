//
//  EmailAddressViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/06.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class EmailAddressViewController: UIViewController {
    var isAutoLogin: Bool?
    let userInfo = FirebaseLoginInfo.shared
    
    // -------------------- 배경 라벨 ------------------------ //
    private lazy var mainLogo: UILabel = {
        let mainLogo = UILabel()
        mainLogo.textColor = UIColor.mainColor
        mainLogo.text = "SETIN"
        mainLogo.font = .systemFont(ofSize: 50, weight: .bold)
        return mainLogo
    }()
    
    private lazy var descriptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.mainColor
        label.text = "최초 1회 입력 후\n간편로그인을 통해 로그인 하실 수 있습니다."
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "dumbell_3.png"))
        imgView.frame.size.width = 330
        imgView.frame.size.height = 100
        
        return imgView
    }()
    
    // -------------------- 하나의 StackView ------------------------ //
    private lazy var emailField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder =
        NSMutableAttributedString().whiteBold(string: "이메일 주소를 입력해 주세요.", fontSize: 15)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.lightGray
        textField.keyboardType = .emailAddress
        textField.delegate = self
        return textField
    }()
    
    private lazy var pwdField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder =
        NSMutableAttributedString().whiteBold(string: "비밀번호를 입력해 주세요. (5자리 이상)", fontSize: 15)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.lightGray
        textField.delegate = self
        return textField
    }()
    
    private lazy var pwdField2: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder =
        NSMutableAttributedString().whiteBold(string: "비밀번호를 다시 입력해 주세요.", fontSize: 15)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.lightGray
        textField.delegate = self
        return textField
    }()
    
    private lazy var nickNameField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 10
        textField.attributedPlaceholder =
        NSMutableAttributedString().whiteBold(string: "사용하실 닉네임을 입력해주세요. (3자리 이상)", fontSize: 15)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = UIColor.lightGray
        textField.delegate = self
        return textField
    }()
    
    struct alertErrorMsg {
        let title, msg: String
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        init(title: String, msg: String) {
            self.title = title
            self.msg = msg
            actionSheet.title = self.title
            actionSheet.message = self.msg
//            actionSheet.preferredStyle = .alert

            let okAction = UIAlertAction(title: "확인", style: .cancel)
            actionSheet.addAction(okAction)
        }
    }
    
    private let loginBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 7
        btn.backgroundColor = UIColor.mainColor
        btn.setTitle("로그인하기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private let registerBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 7
        btn.backgroundColor = UIColor.mainColor
        btn.setTitle("등록하기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    // MARK: View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pwdField2.isHidden = true
        nickNameField.isHidden = true
        registerBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "이메일/비밀번호 입력하기"
        setupView()
        loginBtn.addTarget(self, action: #selector(loginBtnTapped), for: .touchUpInside)
        
    }
    
    // MARK: Registor,Login Button Action
    @objc func loginBtnTapped() {
        // Firebase 이메일, 비밀번호 인증
        let email = emailField.text ?? ""
        let password = pwdField.text ?? ""
        
        // 유효성 검사
        if isValid(email: email, pwd: password) {
            loginUser(withEmail: email, password: password)
        }
    }
    
    // 이메일,비번 유효성 검사
    private func isValid(email:String, pwd:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let emailValid = emailTest.evaluate(with: email) ? true : false
        let pwdValid = (pwd.count < 6) ? false : true
        
        if !emailValid {
            let alert = alertErrorMsg(title: "이메일 주소 확인", msg: "이메일 형식이 올바르지 않습니다.")
            self.present(alert.actionSheet, animated: true)
        } else if (emailValid && !pwdValid) {
            let alert = alertErrorMsg(title: "비밀번호 확인", msg: "비밀번호 길이가 너무 짧습니다.")
            self.present(alert.actionSheet, animated: true)
        } else if (emailValid && pwdValid){
            //
        }
        
        if (emailValid && pwdValid) { return true } else { return false }
    }
    
    private func loginUser(withEmail email:String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case AuthErrorCode.wrongPassword.rawValue:
                    let alert = alertErrorMsg(title: "비밀번호 확인", msg: "비밀번호가 일치하지 않습니다. 다시 입력해 주세요")
                    self.present(alert.actionSheet, animated: true)
                    break
                case 17010:
                    let alert = alertErrorMsg(title: "비밀번호 확인", msg:"5회 이상 틀림. 잠시 후 다시 시도하거나 비밀번호를 변경해주세요")
                    self.present(alert.actionSheet, animated: true)
                    break
                case 17011: // 사용자 등록 안된 경우 > 회원가입
                    self.createUserInfo()
                    break
                    
                default:
                    print("error:\(error.localizedDescription)")
                    break
                }
            }
            else { // 로그인 성공
                let loginInfo = Auth.auth().currentUser?.uid
                self.userInfo.emailLoginUserID = loginInfo
                self.userInfo.emailLoginUserEmail = email
                self.navigationController?.pushViewController(TabBarController(), animated: true)
                
            }
        }
    }
    
    // 신규 회원가입일 경우
    func createUserInfo() {
        self.loginBtn.isHidden = true; self.pwdField2.isHidden = false;
        self.nickNameField.isHidden = false; self.registerBtn.isHidden = false;
        self.registerBtn.addTarget(self, action: #selector(RegisterBtnTapped), for: .touchUpInside)
    }
    
    @objc func RegisterBtnTapped() {
        print("RegisterBtnTapped")
        let pwdValid = (pwdField.text == pwdField2.text)
        let nickValid = nickNameField.text!.count >= 3
        
        if !pwdValid {
            let alert = alertErrorMsg(title: "비밀번호 확인", msg: "비밀번호가 일치하지 않습니다")
            self.present(alert.actionSheet, animated: true)
        }
        
        if !nickValid {
            let alert = alertErrorMsg(title: "닉네임 확인", msg: "닉네임은 3자리 이상이어야 합니다.")
            self.present(alert.actionSheet, animated: true)
        }
        
        if (pwdValid && nickValid) {
            Auth.auth().createUser(withEmail: emailField.text!, password: pwdField.text!) { (authResult, error) in
                if error == nil {
                    self.userInfo.emailLoginUserID = authResult?.user.uid
                    self.userInfo.emailUserNickname = self.nickNameField.text!
                    self.userInfo.createUserInfo()
                    self.navigationController?.pushViewController(TabBarController(), animated: true)
                    
                    // 자동로그인 셋팅 되어있으면 UserDefault에도 저장
                    if self.isAutoLogin! {
                        UserDefaults.standard.set(true, forKey: "isAutoLogin") // 자동로그인 선택 여부
                        UserDefaults.standard.set(self.emailField.text!, forKey: "emailLoginEmail")
                        UserDefaults.standard.set(authResult?.user.uid, forKey: "emailLoginID")
                        UserDefaults.standard.set(self.nickNameField.text!, forKey: "emailLoginNickName")
                    }
                    
                }
            }
        }
    }
}

// MARK: TextField Delegate
extension EmailAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField: pwdField.becomeFirstResponder()
        case pwdField: pwdField.resignFirstResponder()
        case pwdField2: nickNameField.becomeFirstResponder()
        case nickNameField: nickNameField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
}



private extension EmailAddressViewController {
    func setupView() {
        view.backgroundColor = .white
        
        [mainLogo, descriptLabel, imageView,
         emailField, pwdField, pwdField2, nickNameField, loginBtn, registerBtn].forEach {
            view.addSubview($0)
        }
        
        mainLogo.snp.makeConstraints {
            $0.top.equalToSuperview().inset(130)
            $0.leading.equalToSuperview().inset(50)
            $0.width.equalTo(180)
            $0.height.equalTo(60)
        }
        
        descriptLabel.snp.makeConstraints {
            $0.top.equalTo(mainLogo.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(50)
        }
        
        imageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(30)
            $0.leading.equalToSuperview().inset(90)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(descriptLabel.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        pwdField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        pwdField2.snp.makeConstraints {
            $0.top.equalTo(pwdField.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        nickNameField.snp.makeConstraints {
            $0.top.equalTo(pwdField2.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(40)
        }
        
        loginBtn.snp.makeConstraints {
            $0.top.equalTo(nickNameField.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(80)
            $0.trailing.equalToSuperview().inset(80)
            $0.height.equalTo(50)
        }
        
        registerBtn.snp.makeConstraints {
            $0.top.equalTo(nickNameField.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(80)
            $0.trailing.equalToSuperview().inset(80)
            $0.height.equalTo(50)
        }
    }
}
