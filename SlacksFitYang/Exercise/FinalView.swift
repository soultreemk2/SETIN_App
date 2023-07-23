//
//  FinalView.swift
//  SlacksFit
//
//  Created by YANG on 2022/12/29.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FinalView: UIView {
    let db = Firestore.firestore()
    let loginInfo = FirebaseLoginInfo.shared.getCurrentUserInfo()
    
    private lazy var dumbelImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "dumbbell_5.png"))
        imgView.frame.size.width = 78
        imgView.frame.size.height = 55
        
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 2 // 1바퀴 도는데 걸리는 시간
        rotation.isCumulative = true
        rotation.repeatCount = 2 // 몇번 반복 할것인가

        imgView.layer.add(rotation, forKey: "rotationAnimation") // 원하는 뷰에 애니메이션 삽입
        return imgView
    }()
    
    private lazy var titleLbl: UILabel = {
        let titleLabel = UILabel()
         titleLabel.numberOfLines = 2

        // 사용자 이름 가져오기
        FirebaseLoginInfo.shared.getUserNickname { nickname in
            titleLabel.attributedText = NSMutableAttributedString()
                .bold(string: nickname)
                .regularBold(string: " 님의 \n챌린지가 종료되었습니다", fontSize: 16)
        }
        return titleLabel
    }()
    
    private lazy var RecordStackView: UIStackView = {
        let degreeTitle = UILabel()
        degreeTitle.text = "챌린지 달성도"
        let progressView = UIProgressView()
        progressView.progressViewStyle = .default
        progressView.progressTintColor = .mainColor
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 0.7)
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 13
        //progressView.progress = 0.8
        
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            ExerciseCommon.shared.fetchProgressRateFinal(ver:ver) { rate in
                progressView.progress = rate
            }
        }
        
        let goalTitle = UILabel()
        goalTitle.text = "챌린지 목표"
        let goalLbl = UILabel()
        ExerciseCommon.shared.fetchSurveyGoal { goal in
            goalLbl.attributedText = NSMutableAttributedString().mainRegular(string: goal, fontSize: 16)
        }

        goalLbl.textAlignment = .center
    
        let methodTitle = UILabel()
        methodTitle.text = "챌린지 방식"
        let methodLbl = UILabel()
        ExerciseCommon.shared.fetchSurveyStyle { style in
            let surveyStyle = style
            methodLbl.attributedText = NSMutableAttributedString().mainRegular(string: surveyStyle, fontSize: 16)
        }
        methodLbl.textAlignment = .center
        
        [goalLbl, methodLbl].forEach {
            $0.layer.cornerRadius = 5
            $0.layer.borderColor = UIColor.mainColor.cgColor
            $0.layer.borderWidth = 1
        }
        
        let stack = UIStackView(arrangedSubviews: [degreeTitle, progressView, goalTitle, goalLbl, methodTitle, methodLbl])
        stack.axis = .vertical
        stack.spacing = 3
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var newProjBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 13.0, weight:.bold)
        btn.backgroundColor = .mainColor
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 7
        btn.setTitle("새로운 프로젝트를 시작해보세요  >", for: .normal)
        btn.addTarget(self, action: #selector(newProjStart), for: .touchUpInside)
        return btn
    }()
    
    lazy var surveyViewController: UIViewController = {
        let navCont = UINavigationController(rootViewController:SurveyMainViewController())
        navCont.navigationBar.topItem?.title = "프로젝트 시작하기"
//        let tabBarItem = UITabBarItem(title: "운동", image: UIImage(systemName: "figure.walk"), tag: 0)
//        navCont.tabBarItem = tabBarItem
        return navCont
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupView() {
        self.backgroundColor = .white
        [dumbelImgView, titleLbl, RecordStackView, newProjBtn].forEach { addSubview($0) }
        
        dumbelImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(20)
        }
        titleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(dumbelImgView.snp.bottom).offset(10)
        }
        RecordStackView.snp.makeConstraints {
            $0.top.equalTo(titleLbl.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }
        
        newProjBtn.snp.makeConstraints {
            $0.top.equalTo(RecordStackView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(50)
        }
    }
    
    @objc func newProjStart() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newSurvey"), object: nil)
        parentViewController?.navigationController?.pushViewController(TabBarController(), animated: true)
    }
}

extension UIResponder {
    var parentViewController: UIViewController? {
        return self.next as? UIViewController ?? next?.parentViewController
    }
}
