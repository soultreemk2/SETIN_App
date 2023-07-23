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
            heightLbl.text = "\(height)cm"
        }
    }
    
    var weight: Int = 58 {
        didSet {
            weightLbl.text = "\(weight)kg"
        }
    }
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.text = "STEP 3/6"
        
        return stepLbl
    }()
    
    private lazy var mainTitle: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "회원님의 신장과 체중을 선택해주세요"
        
        return mainTitle
    }()
    
    private lazy var subTitle: UILabel = {
       let subTitle = UILabel()
        subTitle.numberOfLines = 2
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.textColor = .gray
        subTitle.text = "맞춤형 프로그램을 위해 신체 정보가 필요합니다."
        
        return subTitle
    }()
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var plusBtn1: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .yellow
        btn.setTitle("+", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var minusBtn1: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .blue
        btn.setTitle("-", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var heightLbl: UILabel = {
        let label = UILabel()
        label.text = "168cm"
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
    
    // 하나의 stackView
    //---------------------------------------------------------------------------------------------------------------//
    private lazy var plusBtn2: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .yellow
        btn.setTitle("+", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var minusBtn2: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .blue
        btn.setTitle("-", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var weightLbl: UILabel = {
        let label = UILabel()
        label.text = "68kg"
        return label
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
        btn.backgroundColor = .blue
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
        view.backgroundColor = .systemBackground
        
        setupLabel()
        setupStackView()
        setupNextBtn()
    }
}

private extension StepThreeViewController {
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
    
    func setupStackView() {
        view.addSubview(stackView1)
        // autolayout
        stackView1.snp.makeConstraints {
            //$0.centerX.centerX.equalToSuperview()
            $0.leading.equalToSuperview().inset(70)
            $0.trailing.equalToSuperview().inset(70)
            $0.top.equalTo(subTitle.snp.bottom).offset(100)
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
            $0.bottom.equalToSuperview().inset(100)
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
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
