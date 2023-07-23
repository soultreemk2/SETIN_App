//
//  StepOneViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/20.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepOneViewController: UIViewController {
    let surveyCommon = SurveyCommon.shared
    
    var UpDown: String = "감량"
    var UpDownWeight: Int = 1
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.text = "STEP 1/6"
        
        return stepLbl
    }()
    
    private lazy var mainTitle: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "2주 후, 회원님께서 원하는 변화는 무엇인가요?"
        
        return mainTitle
    }()
    
    private lazy var subTitle: UILabel = {
       let subTitle = UILabel()
        subTitle.numberOfLines = 2
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.textColor = .gray
        subTitle.text = "SETIN은 2주 동안 원하는 몸매를 만들어 드립니다."
        
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
    
    private lazy var weightLbl: UILabel = {
        let label = UILabel()
        label.text = "1.0kg 감량"
        return label
    }()
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var stackView1: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minusBtn, weightLbl, plusBtn])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()

    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    let choiceOneBtn = SurveyButton(buttonTitle: "체중과 체지방량을 감소하고 싶어요")
    let choiceTwoBtn = SurveyButton(buttonTitle: "체중과 근력을 증가하고 싶어요")
    
    private lazy var stackView2: UIStackView = {
        [choiceOneBtn, choiceTwoBtn].forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        let stackView = UIStackView(arrangedSubviews: [choiceOneBtn, choiceTwoBtn])
        stackView.axis = .vertical
        stackView.spacing = 10
        
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
    
    // MARK: Button Action
    @objc func buttonTapped(_sender: UIButton) {
        if _sender == plusBtn { UpDownWeight += 1} else if _sender == minusBtn { UpDownWeight -= 1}
        if _sender == choiceOneBtn { _sender.isSelected = true; choiceTwoBtn.isSelected = false; disableButton(); UpDown = "감량"}
        if _sender == choiceTwoBtn { _sender.isSelected = true; choiceOneBtn.isSelected = false; disableButton(); UpDown = "증량"}
        
        if _sender == nextBtn {
            // 데이터 저장
            let oneData = SurveyOne(UpDown: UpDown, UpDownWeight: UpDownWeight)
            surveyCommon.SurveyOneDataStore(data: oneData)
            
            self.navigationController?.pushViewController(StepTwoViewController(), animated: true)
        }
 
        weightLbl.text = "\(UpDownWeight).0kg \(UpDown)"
    
        // 버튼 비활성화
        if (UpDownWeight <= 1) {
            minusBtn.isEnabled = false
            plusBtn.isEnabled = true
        } else if (UpDownWeight >= 5) {
            plusBtn.isEnabled = false
            minusBtn.isEnabled = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //self.hidesBottomBarWhenPushed = true
        
        setupLabel()
        setupWeightStackView()
        setupBtnStackView()
        setupNextBtn()
    }
}

private extension StepOneViewController {
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
        }
    }
    
    func setupNextBtn() {
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
