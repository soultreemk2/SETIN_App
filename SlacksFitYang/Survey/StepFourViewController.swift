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
        stepLbl.textColor = .black
        stepLbl.text = "STEP 4/6"
        
        return stepLbl
    }()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let mainLabel = mainTitle(title: "4-1\n회원님은 주로 어느 곳에서 운동할 계획이신가요?")
    let subLabel1 = subTitle(title: "운동 장소에 알맞는 프로그램을 제공합니다.")
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
    
    let mainLabel2 = mainTitle(title: "4-2 \n 회원님의 운동 수준을 선택해주세요.")
    
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
        view.backgroundColor = .white
        setupScrollView()
        setupLabel1()
        setupLabel2()
        setupNextBtn()
    }

}

private extension StepFourViewController {
    func setupScrollView() {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        scrollView.contentInset = insets
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(scrollView.snp.height)  // ⭐️⭐️⭐️ height를 지정하지 않으면 contentView가 안붙음.....
//            $0.edges.equalTo(scrollView.snp.edges)
            $0.edges.equalToSuperview()
        }
    }

    func setupLabel1() {
        [StepLabel, mainLabel, subLabel1].forEach { scrollView.addSubview($0) }
        
        StepLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(60)
            $0.leading.equalToSuperview().inset(50)
        }
        
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(StepLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
        subLabel1.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
        scrollView.addSubview(buttonStack1)
        buttonStack1.snp.makeConstraints {
            $0.top.equalTo(subLabel1.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
        }
    }
    
    func setupLabel2() {
        scrollView.addSubview(mainLabel2)
        mainLabel2.snp.makeConstraints {
            $0.top.equalTo(buttonStack1.snp.bottom).offset(70)
            $0.trailing.equalToSuperview().inset(50)
            $0.leading.equalToSuperview().inset(50)
        }
        
        choiceBtns.forEach {
            scrollView.addSubview($0)
            
            $0.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(50)
                $0.leading.equalToSuperview().inset(50)
            }
            
            $0.addTarget(self, action: #selector(choice2BtnClicked), for: .touchUpInside)
        }

        choiceBtns[0].snp.makeConstraints { $0.top.equalTo(mainLabel2.snp.bottom).offset(10) }
        choiceBtns[1].snp.makeConstraints { $0.top.equalTo(choiceBtns[0].snp.bottom).offset(10) }
        choiceBtns[2].snp.makeConstraints { $0.top.equalTo(choiceBtns[1].snp.bottom).offset(10) }
        choiceBtns[3].snp.makeConstraints { $0.top.equalTo(choiceBtns[2].snp.bottom).offset(10) }
        choiceBtns[4].snp.makeConstraints { $0.top.equalTo(choiceBtns[3].snp.bottom).offset(10) }
        
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
        if ( (gymBtn.isSelected || homeBtn.isSelected) &&
             (choiceBtns[0].isSelected || choiceBtns[1].isSelected || choiceBtns[2].isSelected || choiceBtns[3].isSelected || choiceBtns[4].isSelected)) {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = .mainColor
        }
    }
}
