//
//  StepFinalViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/01.
//

import UIKit
import SnapKit
import FirebaseFirestore

class StepFinalViewController: UIViewController {
    let db = Firestore.firestore()
    
    private lazy var StepLabel: UILabel = {
        let stepLbl = UILabel()
        stepLbl.font = .systemFont(ofSize: 20)
        stepLbl.text = "곧 프로젝트가 시작됩니다!"
        
        return stepLbl
    }()
    
    private lazy var mainTitle: UILabel = {
       let mainTitle = UILabel()
        mainTitle.numberOfLines = 2
        mainTitle.font = .systemFont(ofSize: 15, weight: .bold)
        mainTitle.textColor = .blue
        mainTitle.text = "회원님의 \n 운동 시작일을 선택해주세요!"
        
        return mainTitle
    }()
    
    private lazy var subTitle: UILabel = {
       let subTitle = UILabel()
        subTitle.numberOfLines = 2
        subTitle.font = .systemFont(ofSize: 12, weight: .medium)
        subTitle.textColor = .gray
        subTitle.text = "회원님의 목표 ___을 확실하게 코치하겠습니다 :)" // 뷰간 데이터 전달
        
        return subTitle
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        var components = DateComponents()
        components.day = 10
        let maxDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
        components.day = -10
        let minDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        
        datePicker.minuteInterval = 720
        return datePicker
    }()
    
    private lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .blue
        btn.setTitle("프로젝트 생성", for: .normal)
        btn.addTarget(self, action: #selector(nextBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    // MARK: button Action
    @objc func datePickerChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendarDate = formatter.string(from: datePicker.date)
        SurveyCommon.shared.SurveyDataStore(data: ["projStartDate": calendarDate])
    }
    
    @objc func nextBtnClicked() {
        // TO DO: 운동데이터를 등급/종류 별로 나누어서 하나의 컬렉션에 저장해 둠
        // TO DO: 저장된 survey 데이터를 기반으로 등급/종류 판정 > 운동컬렉션에서 가져와서 14일차로 나누어서 > exerciseDoc 데이터 생성 (쿼리 조합)
        SurveyCommon.shared.ExerciseDataStore(data: ["운동명":"벤치프레스"])
        //self.navigationController?.popToRootViewController(animated: true)  // navigationController의 SurveyMainVC로 돌아감
        tabBarController?.navigationController?.pushViewController(TabBarController(), animated: true) // 최상위 VC에 TabBar 임베드
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupLabel()
        setupCalendar()
        setupNextBtn()
    }
}

extension StepFinalViewController {
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
    
    func setupCalendar() {
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(70)
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
    
}
