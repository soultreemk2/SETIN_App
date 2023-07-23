//
//  StepFourViewController.swift
//  
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepFourViewController: UIViewController {
    var place: String = "gym"
    var level: Int = 1
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.text = "STEP 4/6"
        
        return stepLbl
    }()
    
    private lazy var mainTitle1: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "4-1 \n 회원님은 주로 어느 곳에서 운동할 계획이신가요?"
        
        return mainTitle
    }()
    
    private lazy var subTitle1: UILabel = {
       let subTitle = UILabel()
        subTitle.numberOfLines = 2
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.textColor = .gray
        subTitle.text = "운동 장소에 알맞는 프로그램을 제공합니다."
        
        return subTitle
    }()
    
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    var gymBtn = SurveyButton(buttonTitle: "헬스장")
    var homeBtn = SurveyButton(buttonTitle: "집")

    private lazy var buttonStack1: UIStackView = {
        [gymBtn, homeBtn].forEach {
            $0.addTarget(self, action: #selector(choice1BtnClicked), for: .touchUpInside)
        }

        let stackView = UIStackView(arrangedSubviews: [gymBtn, homeBtn])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    
    private lazy var mainTitle2: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "4-2 \n 회원님의 운동 수준을 선택해주세요."
        
        return mainTitle
    }()
    
    private lazy var choiceBtns: [UIButton] = {
        
        let btn1 = SurveyButton(buttonTitle: "헬스장에 이제 등록했어요ㅠㅠ")
        let btn2 = SurveyButton(buttonTitle: "헬스장을 다니긴 하는데 뭘 해야할지..")
        let btn3 = SurveyButton(buttonTitle: "1년 이상 다녔지만 운동 체계가 필요해요!")
        let btn4 = SurveyButton(buttonTitle: "2년 이상 체계적으로 해왔어요")
        let btn5 = SurveyButton(buttonTitle: "디클라인 운동을 할줄 아는 고인물이에요")
        
        return [btn1, btn2, btn3, btn4, btn5]
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
    @objc func choice1BtnClicked(_sender: UIButton) {
        if _sender == gymBtn { _sender.isSelected = true; place = "gym"; homeBtn.isSelected = false; disableButton()}
        if _sender == homeBtn { _sender.isSelected = true; place = "home"; gymBtn.isSelected = false; disableButton()}
    }
    
    @objc func choice2BtnClicked(_sender: UIButton) {
        choiceBtns.forEach {
            disableButton()
            if _sender == choiceBtns[0] { _sender.isSelected = true; level = 1 } else { $0.isSelected = false }
            if _sender == choiceBtns[1] { _sender.isSelected = true; level = 2 } else { $0.isSelected = false }
            if _sender == choiceBtns[2] { _sender.isSelected = true; level = 3 } else { $0.isSelected = false }
            if _sender == choiceBtns[3] { _sender.isSelected = true; level = 4 } else { $0.isSelected = false }
            if _sender == choiceBtns[4] { _sender.isSelected = true; level = 5 } else { $0.isSelected = false }
        }
    }
    
    @objc func nextBtnClicked() {
        let fourData = SurveyFour(place: place, level: level)
        SurveyCommon.shared.SurveyFourDataStore(data: fourData)
        self.navigationController?.pushViewController(StepFiveViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLabel1()
        setupLabel2()
        setupNextBtn()
    }

}

private extension StepFourViewController {

    func setupLabel1() {
        [StepLabel, mainTitle1, subTitle1].forEach { view.addSubview($0) }
        
        StepLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(150)
            $0.leading.equalToSuperview().inset(50)
        }
        
        mainTitle1.snp.makeConstraints {
            $0.top.equalTo(StepLabel.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
        }
        
        subTitle1.snp.makeConstraints {
            $0.top.equalTo(mainTitle1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(50)
        }
        
        view.addSubview(buttonStack1)
        buttonStack1.snp.makeConstraints {
            $0.top.equalTo(subTitle1.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
        }
    }
    
    func setupLabel2() {
        view.addSubview(mainTitle2)
        mainTitle2.snp.makeConstraints {
            $0.top.equalTo(buttonStack1.snp.bottom).offset(70)
            $0.trailing.equalToSuperview().inset(50)
            $0.leading.equalToSuperview().inset(50)
        }
        
        choiceBtns.forEach {
            view.addSubview($0)
            
            $0.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(50)
                $0.leading.equalToSuperview().inset(50)
            }
            
            $0.addTarget(self, action: #selector(choice2BtnClicked), for: .touchUpInside)
        }

        choiceBtns[0].snp.makeConstraints { $0.top.equalTo(mainTitle2.snp.bottom).offset(10) }
        choiceBtns[1].snp.makeConstraints { $0.top.equalTo(choiceBtns[0].snp.bottom).offset(10) }
        choiceBtns[2].snp.makeConstraints { $0.top.equalTo(choiceBtns[1].snp.bottom).offset(10) }
        choiceBtns[3].snp.makeConstraints { $0.top.equalTo(choiceBtns[2].snp.bottom).offset(10) }
        choiceBtns[4].snp.makeConstraints { $0.top.equalTo(choiceBtns[3].snp.bottom).offset(10) }
        
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
        if ( (gymBtn.isSelected || homeBtn.isSelected) &&
             (choiceBtns[0].isSelected || choiceBtns[1].isSelected || choiceBtns[2].isSelected || choiceBtns[3].isSelected || choiceBtns[4].isSelected)) {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = .blue
        }
    }
}
