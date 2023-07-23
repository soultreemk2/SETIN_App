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
        stepLbl.textColor = .black
        stepLbl.text = "곧 프로젝트가 시작됩니다!"
        
        return stepLbl
    }()
    
    let mainLabel = mainTitle(title: "회원님의\n 운동 시작일을 선택해주세요!")
    let subLabel = subTitle(title: "회원님의 목표를 확실하게 코치하겠습니다💪🏻")
    
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
        btn.backgroundColor = .mainColor
        btn.setTitle("프로젝트 생성", for: .normal)
        btn.addTarget(self, action: #selector(nextBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    // MARK: button Action
    @objc func datePickerChanged() {
        recordStartDate()
    }
    
    @objc func nextBtnClicked() {
        // TO DO: 저장된 survey 데이터를 기반으로 등급/종류 판정 > 운동컬렉션에서 가져와서 14일차로 나누어서 > exerciseDoc 데이터 생성 (쿼리 조합)
        // json에서 랜덤추출 > ExerciseList에 setData
        ExerciseCommon.shared.makeExerciseListByDate()


        //self.navigationController?.popToRootViewController(animated: true)  // navigationController의 SurveyMainVC로 돌아감
        tabBarController?.navigationController?.pushViewController(TabBarController(), animated: true) // 최상위 VC에 TabBar 임베드
    }
    
    func recordStartDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendarDate = formatter.string(from: datePicker.date)
        SurveyCommon.shared.SurveyDataStore(data: ["projStartDate": calendarDate])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLabel()
        setupCalendar()
        setupNextBtn()
        recordStartDate()
    }
}

extension StepFinalViewController {
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
    
    func setupCalendar() {
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(70)
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
    
}
