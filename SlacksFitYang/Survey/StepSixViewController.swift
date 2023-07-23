//
//  StepSixViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/01.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepSixViewController: UIViewController {
    var activityLevel: Int = 1
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.textColor = .black
        stepLbl.text = "STEP 6/6"
        
        return stepLbl
    }()
    
    let mainLabel = mainTitle(title: "회원님의 평소 활동량을 선택해주세요.")
    let subLabel = subTitle(title: "마지막 질문입니다!")
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    var choiceOneBtn = SurveyButton(buttonTitle: "요즘은 운동을 아예 안해요..")
    var choiceTwoBtn = SurveyButton(buttonTitle: "일주일에 2-3회 정도 가끔 해요")
    var choiceThreeBtn = SurveyButton(buttonTitle: "일주일에 3-5회 정도 주기적으로 해요")
    var choiceFourBtn = SurveyButton(buttonTitle: "일주일 내내 안쉬고 꾸준히 해요")
    var choiceFiveBtn = SurveyButton(buttonTitle: "하루 2회 이상 전문가 수준입니다")
    
    private lazy var buttonStack: UIStackView = {
        let buttonArr = [choiceOneBtn, choiceTwoBtn, choiceThreeBtn, choiceFourBtn, choiceFiveBtn]
        
        buttonArr.forEach {
            $0.addTarget(self, action: #selector(choiceBtnClicked), for: .touchUpInside)
        }

        let stackView = UIStackView(arrangedSubviews: buttonArr)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.isEnabled = false
        btn.setTitle("다음", for: .normal)
        btn.addTarget(self, action: #selector(nextBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    // MARK: button Action
    @objc func choiceBtnClicked(_sender: UIButton) {
        [choiceOneBtn, choiceTwoBtn, choiceThreeBtn, choiceFourBtn, choiceFiveBtn].enumerated().forEach {
            disableButton()
            activityLevel = $0.0 // index
            if _sender == choiceOneBtn { _sender.isSelected = true } else { $0.1.isSelected = false}
            if _sender == choiceTwoBtn { _sender.isSelected = true } else { $0.1.isSelected = false}
            if _sender == choiceThreeBtn { _sender.isSelected = true } else { $0.1.isSelected = false}
            if _sender == choiceFourBtn { _sender.isSelected = true } else { $0.1.isSelected = false}
            if _sender == choiceFiveBtn { _sender.isSelected = true } else { $0.1.isSelected = false}
        }
    }
    
    @objc func nextBtnClicked() {
        SurveyCommon.shared.SurveyDataStore(data: ["activityLevel": activityLevel])
        self.navigationController?.pushViewController(StepFinalViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLabel()
        setupButtonStack()
        setupNextBtn()
    }
}

extension StepSixViewController {
    func setupLabel() {
        [StepLabel, mainLabel, subLabel].forEach { view.addSubview($0) }

        StepLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(150)
            $0.leading.equalToSuperview().inset(50)
        }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(StepLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
        }
        
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(50)
        }
    }
    
    func setupButtonStack() {
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
        }
    }
    
    func setupNextBtn() {
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(getTabBarHeight())
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
    }
    
    private func disableButton () {
        if (choiceOneBtn.isSelected || choiceTwoBtn.isSelected ||
            choiceThreeBtn.isSelected || choiceFourBtn.isSelected || choiceFiveBtn.isSelected) {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = .mainColor
        }
    }
}
