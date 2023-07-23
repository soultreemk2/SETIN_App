//
//  StepThreeViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class StepThreeViewController: UIViewController {
    var height: Int = 168 {
        didSet {
            heightLbl.attributedText = NSMutableAttributedString().bold(string: "\(height)")
                                    .regular(string: "cm", fontSize: 15)
        }
    }
    
    var weight: Int = 58 {
        didSet {
            weightLbl.attributedText = NSMutableAttributedString().bold(string: "\(weight)")
                                    .regular(string: "kg", fontSize: 15)
        }
    }
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.textColor = UIColor.black
        stepLbl.text = "STEP 3/6"
        
        return stepLbl
    }()
    
    let mainLabel = mainTitle(title: "회원님의 신장과 체중을 선택해주세요")
    let subLabel = subTitle(title: "맞춤형 프로그램을 위해 신체 정보가 필요합니다." )
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    let plusBtn = upDownButton(buttonTitle: "+")
    let minusBtn = upDownButton(buttonTitle: "-")
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    let plusBtn1 = upDownButton(buttonTitle: "+")
    let plusBtn2 = upDownButton(buttonTitle: "+")
    let minusBtn1 = upDownButton(buttonTitle: "-")
    let minusBtn2 = upDownButton(buttonTitle: "-")

    private lazy var heightLbl: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().bold(string: "168")
                                .regular(string: "cm", fontSize: 15)
        return label
    }()
    
    private lazy var weightLbl: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().bold(string: "68")
                                .regular(string: "kg", fontSize: 15)
        return label
    }()
    
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var stackView1: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minusBtn1, heightLbl, plusBtn1])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        return stackView
    }()

    private lazy var stackView2: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minusBtn2, weightLbl, plusBtn2])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        return stackView
    }()
    
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .mainColor
        btn.setTitle("다음", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: Button Action
    @objc func buttonTapped(_sender: UIButton) {
        switch _sender {
        case plusBtn1:
            height += 1

        case minusBtn1:
            height -= 1

        case plusBtn2:
            weight += 1

        case minusBtn2:
            weight -= 1
            
        case nextBtn:
            let threeData = SurveyThree(height: height, weight: weight)
            SurveyCommon.shared.SurveyThreeDataStore(data: threeData)
            self.navigationController?.pushViewController(StepFourViewController(), animated: true)
            
        default:
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        [plusBtn1, minusBtn1, plusBtn2, minusBtn2].forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        setupLabel()
        setupStackView()
        setupNextBtn()
    }
}

private extension StepThreeViewController {
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
    
    func setupStackView() {
        view.addSubview(stackView1)
        // autolayout
        stackView1.snp.makeConstraints {
            //$0.centerX.centerX.equalToSuperview()
            $0.leading.equalToSuperview().inset(70)
            $0.trailing.equalToSuperview().inset(70)
            $0.top.equalTo(subLabel.snp.bottom).offset(100)
        }
        
        view.addSubview(stackView2)
        // autolayout
        stackView2.snp.makeConstraints {
            $0.top.equalTo(stackView1.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(70)
            $0.trailing.equalToSuperview().inset(70)
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
    
    func SurveyThreeDataStore() {
        let db = Firestore.firestore()
        let document = db.collection("survey").document("survey")
        let data = SurveyThree(height: height, weight: weight)
        
        do {
            try document.setData(from: data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
}
