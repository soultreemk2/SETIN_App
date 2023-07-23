//
//  EditDefaultInfoViewController.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/02/06.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAuth

class EditDefaultInfoViewController: UIViewController, UITextFieldDelegate {
    let exerciseInfo = ExerciseCommon.shared
    let loginInfo = FirebaseLoginInfo.shared
    let loginEmailAddress = FirebaseLoginInfo.shared.getCurrentUserEmail()
    
    var nNickname: String?
    var nHeight: String?
    var nWeight: String?
    
    // 1. 뒤로가기 버튼
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("< 기본 정보", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.titleLabel?.textColor = .black
        return button
    }()
    
    // 2. 상단 메인 타이틀
    let imageView = UIImageView(image: UIImage(named: "water_bottle.png"))
    lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "수정하실 정보를 \n클릭하고 내용을 입력해주세요."
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        return label
    }()
    
    struct commonTextField {
        var edited: Bool = true
        let title, placeholder: String
        let leftView =  UILabel(frame: CGRect(x: 10, y: 0, width: 30, height: 30))
        let textField = TextFieldWithPadding()
  
        init(title: String, placeholer: String, edited: Bool) {
            self.title = title
            self.placeholder = placeholer
            self.edited = edited
            
            leftView.attributedText = NSMutableAttributedString().regular(string: "   " + "\(self.title)   |   ", fontSize: 17)
            textField.leftView = leftView
            textField.leftViewMode = .always
            textField.isUserInteractionEnabled = self.edited
            textField.layer.cornerRadius = 7
            textField.layer.borderColor = UIColor.grayColor.cgColor
            textField.layer.borderWidth = 1
            
            if !self.edited {
                textField.backgroundColor = UIColor.disabledColor
                textField.attributedPlaceholder = NSMutableAttributedString()
                                                    .regular(string: "\(self.placeholder)", fontSize: 18)
            } else {
                textField.backgroundColor = .white
                textField.attributedPlaceholder = NSMutableAttributedString()
                                                  .regularBold(string: self.placeholder, fontSize: 18)
            }
        }
    }
    
    // 3.2 스택뷰 (4개의 textField)
    func getEditStackView(completion: @escaping(UIStackView)->()) {
        loginInfo.getUserNickname { nickname in
            SurveyCommon.shared.fetchPofileInfo2 { weight, height in
                let textField1 = commonTextField(title: "닉네임", placeholer: nickname, edited: true)
                let textField2 = commonTextField(title: "계정", placeholer: self.loginEmailAddress, edited: false)
                let textField3 = commonTextField(title: "신장", placeholer: "\(height)cm", edited: true)
                let textField4 = commonTextField(title: "체중", placeholer: "\(weight)kg", edited: true)
                
                let textFieldArr = [textField1.textField, textField2.textField, textField3.textField, textField4.textField]
                // delegate, tag 지정
                textFieldArr.forEach { $0.delegate = self }
                for i in 0...textFieldArr.count-1 {
                    textFieldArr[i].tag = i+1
                }
                
                let editStack = UIStackView(arrangedSubviews: textFieldArr)
                editStack.axis = .vertical
                editStack.spacing = 20
                editStack.distribution = .fillEqually
                completion(editStack)
            }
        }
    }
    
    lazy var saveButton: UIButton = {
       let button = UIButton()
        button.layer.cornerRadius = 7
        button.setTitle("수정내용 저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isEnabled = false
        button.backgroundColor = UIColor.lightGray

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        backButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(updateUserInfo), for: .touchUpInside)
        
        setupView()
    }
    
    @objc func dismissVC() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func updateUserInfo() {
        SurveyCommon.shared.updateProfileInfo(nickname: self.nNickname, height: self.nHeight, weight: self.nWeight)
        let alert = UIAlertController(title: nil, message: "저장되었습니다.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "닫기", style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: TextField Delegate
    
    // 저장버튼 활성화 여부 (값이 하나라도 있으면..)
    func textFieldDidChangeSelection(_ textField: UITextField) {
        var nicknameValid = false
        var heightValid = false
        var weightValid = false
        
        if (textField.tag == 1) {
            if textField.text! != "" { nicknameValid = true } else { nicknameValid = false }
        }
        if (textField.tag == 3) {
            if textField.text != "" { heightValid = true } else { heightValid = false }
        }
        if (textField.tag == 4) {
            if textField.text != "" { weightValid = true } else { weightValid = false }
        }
        if (nicknameValid || heightValid || weightValid) {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .mainColor
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor.lightGray
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 1:
            // 입력받는 길이 제한 (3~10글자)
            var newLength = 0
            if textField.text!.count < 3 {
                textField.layer.borderColor = UIColor.red.cgColor
            } else if (textField.text!.count >= 3 && textField.text!.count < 10) {
                textField.layer.borderColor = UIColor.grayColor.cgColor
            }
            newLength = textField.text!.count + string.count - range.length
            return !(newLength > 10)
            
        case 3,4:
            // 숫자만 입력
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
            
        default:
            break
        }
        return true
    }
    
    // return 키 클릭 시
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nicknameField = textField.superview?.viewWithTag(1) as? UITextField
        let heightField = textField.superview?.viewWithTag(3) as? UITextField
        let weightField = textField.superview?.viewWithTag(4) as? UITextField

        if textField == nicknameField {
            if (textField.text!.count >= 1 && textField.text!.count < 3) {
                return false
            } else {
                heightField?.becomeFirstResponder()
            }
            
        } else if textField == heightField {
            weightField?.becomeFirstResponder()
        } else if textField == weightField {
            weightField?.resignFirstResponder()
        }
        return true
    }
    
    // 입력 완료
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.text!.count > 0 { // 입력을 한 경우에만
            switch textField.tag {
            case 1:
                self.nNickname = textField.text
            case 3:
                self.nHeight = textField.text
            case 4:
                self.nWeight = textField.text
            default:
                break
            }
        }
    }
}


extension EditDefaultInfoViewController {
    func setupView() {
        getEditStackView { [self] editStack in
            [backButton, imageView, mainTitle, editStack, saveButton].forEach { view.addSubview($0) }
            backButton.snp.makeConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
                $0.leading.equalToSuperview().inset(10)
            }
            imageView.snp.makeConstraints {
                $0.top.equalTo(backButton.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(20)
            }
            mainTitle.snp.makeConstraints {
                $0.top.equalTo(imageView.snp.bottom).offset(10)
                $0.leading.equalToSuperview().inset(20)
            }
            editStack.snp.makeConstraints {
                $0.top.equalTo(mainTitle.snp.bottom).offset(40)
                $0.leading.trailing.equalToSuperview().inset(30)
            }
            saveButton.snp.makeConstraints {
                $0.top.equalTo(editStack.snp.bottom).offset(40)
                $0.leading.trailing.equalToSuperview().inset(50)
                $0.height.equalTo(50)
            }
        }

    }
}
