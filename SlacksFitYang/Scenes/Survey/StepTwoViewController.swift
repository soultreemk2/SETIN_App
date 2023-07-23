//
//  StepTwoViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepTwoViewController: UIViewController {
    var age: Int = 22
    var gender: Int = 0
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.text = "STEP 2/6"
        
        return stepLbl
    }()
    
    private lazy var mainTitle: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "회원님의 성별과 나이를 선택해주세요"
        
        return mainTitle
    }()
    
    private lazy var subTitle: UILabel = {
       let subTitle = UILabel()
        subTitle.numberOfLines = 2
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.textColor = .gray
        subTitle.text = "회원님 정보에 맞는 루틴을 제공해 드립니다."
        
        return subTitle
    }()
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var plusBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .yellow
        btn.setTitle("+", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var minusBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .blue
        btn.setTitle("-", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var ageLbl: UILabel = {
        let label = UILabel()
        label.text = "22세"
        return label
    }()
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var stackView1: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minusBtn, ageLbl, plusBtn])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()

    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    var choiceOneBtn = SurveyButton(buttonTitle: "남성입니다")
    var choiceTwoBtn = SurveyButton(buttonTitle: "여성입니다")

    private lazy var stackView2: UIStackView = {
        [choiceOneBtn,choiceTwoBtn].forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        let stackView = UIStackView(arrangedSubviews: [choiceOneBtn, choiceTwoBtn])
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
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    @objc func buttonTapped(_sender: UIButton) {

        if _sender == plusBtn { age += 1 } else if _sender == minusBtn { age -= 1}
        if _sender == nextBtn {
            // 데이터 저장
            let twoData = SurveyTwo(age: age, gender: gender)
            SurveyCommon.shared.SurveyTwoDataStore(data: twoData)
            self.navigationController?.pushViewController(StepThreeViewController(), animated: true)
        }
        
        ageLbl.text = "\(age)세"
        
        if _sender == choiceOneBtn {_sender.isSelected = true; choiceTwoBtn.isSelected = false; disableButton(); gender = 1 }
        if _sender == choiceTwoBtn { _sender.isSelected = true; choiceOneBtn.isSelected = false; disableButton(); gender = 0}
        
    }


        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLabel()
        setupWeightStackView()
        setupBtnStackView()
        setupNextBtn()
    }
}

private extension StepTwoViewController {
    func setupLabel() {
        [StepLabel, mainTitle, subTitle].forEach { view.addSubview($0) }

        StepLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(150)
            $0.leading.equalToSuperview().inset(50)
        }
        
        mainTitle.snp.makeConstraints {
            $0.top.equalTo(StepLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
        }
        
        subTitle.snp.makeConstraints {
            $0.top.equalTo(mainTitle.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(50)
        }
        
    }
    
    func setupWeightStackView() {
        view.addSubview(stackView1)
        // autolayout
        stackView1.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
//            $0.leading.equalToSuperview().inset(30)
//            $0.trailing.equalToSuperview().inset(30)
//            $0.top.equalToSuperview().inset(50)
        }
    }
    
    func setupBtnStackView() {
        view.addSubview(stackView2)
        stackView2.snp.makeConstraints {
            $0.top.equalTo(stackView1.snp.bottom).offset(50)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(70)
        }
    }
    
    func setupNextBtn() {
        nextBtn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(100)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
        }
    }
    
    private func disableButton () {
        if (choiceOneBtn.isSelected || choiceTwoBtn.isSelected) {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = .blue
        }
    }
}
