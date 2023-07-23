//
//  StepFiveViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepFiveViewController: UIViewController {
    var style: Int = 1
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.textColor = .black
        stepLbl.text = "STEP 5/6"
        
        return stepLbl
    }()
    
    let mainLabel = mainTitle(title: "회원님이 선호하는\n운동 방식을 선택해주세요.")
    let subLabel = subTitle(title: "적절한 방안을 제시해 드립니다.")
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    var choiceOneBtn = SurveyButton(buttonTitle: "매일 전신부위를 다양하게")
    var choiceTwoBtn = SurveyButton(buttonTitle: "하루마다 상체와 하체를 번갈아서")
    var choiceThreeBtn = SurveyButton(buttonTitle: "하루에 한 부위를 집중적으로")
    
    private lazy var buttonStack: UIStackView = {
        [choiceOneBtn, choiceTwoBtn, choiceThreeBtn].forEach {
            $0.addTarget(self, action: #selector(choiceBtnClicked), for: .touchUpInside)
        }

        let stackView = UIStackView(arrangedSubviews: [choiceOneBtn, choiceTwoBtn, choiceThreeBtn])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .gray
        btn.setTitle("다음", for: .normal)
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(nextBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    // MARK: button Action
    @objc func choiceBtnClicked(_sender: UIButton) {
        [choiceOneBtn, choiceTwoBtn, choiceThreeBtn].forEach {
            disableButton()
            if _sender == choiceOneBtn { _sender.isSelected = true; style = 1 } else { $0.isSelected = false}
            if _sender == choiceTwoBtn { _sender.isSelected = true; style = 2 } else { $0.isSelected = false}
            if _sender == choiceThreeBtn { _sender.isSelected = true; style = 3 } else { $0.isSelected = false}
        }
    }
    
    @objc func nextBtnClicked() {
        SurveyCommon.shared.SurveyDataStore(data: ["style": style])
        self.navigationController?.pushViewController(StepSixViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabel()
        setupButtonStack()
        setupNextBtn()
    }
    
}
private extension StepFiveViewController {
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
        if (choiceOneBtn.isSelected || choiceTwoBtn.isSelected || choiceThreeBtn.isSelected) {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = .mainColor
        }
    }
}
