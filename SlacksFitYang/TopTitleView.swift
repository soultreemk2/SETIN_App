//
//  TopTitleView.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/07/07.
//

import Foundation
import UIKit
import SnapKit
import PhotosUI
import FirebaseAuth
import GoogleSignIn

class TopTitleView: UIView {
    var loginInfo = FirebaseLoginInfo.shared

    lazy var logoutBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout.png"), for: .normal)
        button.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
        return button
    }()
    //--------------------- Title -----------------------//
    lazy var profileImg: UIImageView = {
        var image = UIImage()
        let imageData = UserDefaults.standard.data(forKey: "profileImage")
        if let imageData = imageData {
            image = UIImage(data: imageData) ?? UIImage()
        } else { // 기본이미지
            image = UIImage(systemName: "person") ?? UIImage()
        }
        
        let imgView = UIImageView(image: image)
        imgView.backgroundColor = .gray
        return imgView
    }()
    
    lazy var mainDescriptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()
    
    lazy var segmentBar: UIView = {
       let view = UIView()
        view.backgroundColor = .grayColor
        return view
    }()
    
    
    override func updateConstraints() {
        setupConstraints()
        super.updateConstraints()
    }

    override func layoutSubviews() {
        profileImg.clipsToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTabGesture()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func logoutBtnTapped(_sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        /* 로그아웃 기능 중단
         1) 애플 로그아웃 공식적으로 제공안함 (임의로 로그아웃 하고 재로그인 하면 appleIDCredential이 invalid 뜸.
         2) 이미지 들도 삭제해야 하는데, UserDefault에 저장되어 있어 난감..
         */
        let logoutAction = UIAlertAction(title: "로그아웃", style: .default) { _ in
            self.loginInfo.logOutUserInfo()
            // 자동로그인 UserDefault 삭제
            self.loginInfo.deleteAutoLoginInfo()
            
            // getting access to the window object from SceneDelegate
            let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
            sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }
        
        let changePwdAction = UIAlertAction(title: "비밀번호 변경", style: .default) { _ in
            let email = self.loginInfo.getCurrentUserEmail()
            Auth.auth().sendPasswordReset(withEmail: email)
            let actionSheet = UIAlertController(title: "비밀번호 변경", message: "비밀번호 재설정 메일이 전송되었습니다.\n이메일에서 확인하세요.", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "닫기", style: .cancel)
            actionSheet.addAction(cancleAction)
            self.parentViewController?.present(actionSheet, animated: true)
        }
        
        let withdrawAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
            // 경고 팝업 창
            let actionSheet = UIAlertController(title: "탈퇴 유의사항", message: "탈퇴 시 모든 신체정보/프로젝트 데이터/운동 인증사진이 삭제되며 복구 및 취소는 불가합니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                // 삭제처리
                Auth.auth().currentUser?.delete()
                // db 삭제
                self.loginInfo.deleteUserInfo()
                // 자동로그인 UserDefault 삭제
                self.loginInfo.deleteAutoLoginInfo()
                // 운동기록 userDefault 삭제
                UserDefaults.standard.removeObject(forKey: "exerciseRecordImage")
                UserDefaults.standard.removeObject(forKey: "profileImage")
                self.parentViewController?.navigationController?.pushViewController(LoginViewController(), animated: true)
            }
            
            let cancleAction = UIAlertAction(title: "취소", style: .cancel)
            actionSheet.addAction(cancleAction)
            actionSheet.addAction(okAction)
            self.parentViewController?.present(actionSheet, animated: true)

        }
        
        let cancleAction = UIAlertAction(title: "닫기", style: .cancel)
        
        // changePwdAction 노출 여부 결정
        if loginInfo.getCurrentLoginMethod() == "email" {
//            [logoutAction, changePwdAction, withdrawAction, cancleAction].forEach { actionSheet.addAction($0) }
            [changePwdAction, withdrawAction, cancleAction].forEach { actionSheet.addAction($0) }
            
        } else {
//            [logoutAction, withdrawAction, cancleAction].forEach { actionSheet.addAction($0) }
            [withdrawAction, cancleAction].forEach { actionSheet.addAction($0) }
        }
        
        self.parentViewController?.present(actionSheet, animated: true)
    }
}

extension TopTitleView {
    func setupConstraints() {
        self.addSubview(profileImg)
        profileImg.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(10)
            $0.width.height.equalTo(100)
        }
    }
    
    func setupImagePicker() {
        // 기본설정
        var conf = PHPickerConfiguration()
        conf.selectionLimit = 1
        conf.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: conf)
        picker.delegate = self
        self.parentViewController?.present(picker, animated: true)
    }
    
    func setupTabGesture() {
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpImgView))
        profileImg.addGestureRecognizer(tabGesture)
        profileImg.isUserInteractionEnabled = true
    }
    
    func setupView() {
        // 로그아웃 버튼
        self.addSubview(logoutBtn)
        logoutBtn.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.width.equalTo(30)
            $0.height.equalTo(25)
            $0.trailing.equalToSuperview().inset(30)
        }
        
        loginInfo.getUserNickname { nickname in
            SurveyCommon.shared.fetchProfileInfo1(index: 0) { count in
                SurveyCommon.shared.fetchProfileInfo1(index: 1) { day in
                    self.mainDescriptLabel.attributedText =
                    NSMutableAttributedString().regularBold(string: nickname, fontSize: 20)
                        .regular(string: "  님\n", fontSize: 17)
                        .regular(string: "완료한 챌린지는 ", fontSize: 17)
                        .regularBold(string: "\(count)개 \n", fontSize: 17)
                        .regular(string: "세틴을 시작한지 ", fontSize: 17)

                        .regularBold(string: "\(day)일 ", fontSize: 17)
                        .regular(string: "째입니다", fontSize: 17)
                }
            }
        }
        [profileImg, mainDescriptLabel, segmentBar].forEach { self.addSubview($0)}
    
        mainDescriptLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(40)
        }
        segmentBar.snp.makeConstraints {
            $0.top.equalTo(mainDescriptLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(2)
        }
    }
    
    @objc func touchUpImgView() {
        // 카메라 접근 권한
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
           if granted {
               DispatchQueue.main.async {
                   self.setupImagePicker()
               }
           } else {
               DispatchQueue.main.async{
                   let actionSheet = UIAlertController(title: "", message: "프로필 사진 선택을 위해 카메라 접근 권한을 허용해 주세요.", preferredStyle: .alert)
                   let moveAction = UIAlertAction(title: "권한 설정하기", style:.default) { (_) in
                       guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

                       if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url)
                       }
                   }
                   actionSheet.addAction(moveAction)
                   self.parentViewController?.present(actionSheet, animated: true)
               }
           }
       })
    }
}

extension TopTitleView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { img, error in
                DispatchQueue.main.async {
                    self.profileImg.image = img as? UIImage
                }
                // 이미지 userDefault 저장
                let image = img as! UIImage
                let imageData = image.jpegData(compressionQuality: 1.0)
                UserDefaults.standard.set(imageData, forKey: "profileImage")
            }
        } else {
            print("이미지 못불러옴")
        }
    }
}
