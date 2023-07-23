//
//  InfoIngView.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/01/24.
//

import Foundation
import UIKit

class InfoIngView: UIView {
    var loginInfo = FirebaseLoginInfo.shared
    var arrangedSubviews:Array<UIView> = [] // stackView에 들어갈 subview 4개
    var count = 0
    var challengeStackView: UIStackView?
    
    // 공통 UIComponent
    struct commonTitle {
        var title: String

        lazy var label: UILabel = {
            let label = UILabel()
            label.attributedText = NSMutableAttributedString().regularBold(string: title, fontSize: 17)
            return label
        }()
    }
    struct editButton {
        lazy var button: UIButton = {
            let btn = UIButton()
            btn.setAttributedTitle(NSMutableAttributedString().regular(string: "수정 >", fontSize: 17), for: .normal)
            return btn
        }()
    }
    
    //--------------------- DefaultInfo -----------------------//
    var infoTitle = commonTitle(title: "기본 정보")
    var editInfoBtn = editButton()
    
    //--------------------- ChallengeInfo1 -----------------------//
    var challengeTitle1 = commonTitle(title: "진행중인 챌린지")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        editInfoBtn.button.addTarget(self, action: #selector(defaultInfoEdit), for: .touchUpInside)
        
        fetchInfoStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func defaultInfoEdit() {
        let editVC = EditDefaultInfoViewController()
        editVC.modalPresentationStyle = .overFullScreen;
        self.parentViewController?.present(editVC, animated: true)
        
    }
}

extension InfoIngView {
    
    func fetchInfoStackView() {
        loginInfo.getUserNickname { nickname in
            SurveyCommon.shared.fetchPofileInfo2 { weight, height in
                self.count += 1
                let nicknameLbl = commonLabel(title: "닉네임", content: nickname)
                let emailLbl = commonLabel(title: "계정", content: self.loginInfo.getCurrentUserEmail())
                let heightLbl = commonLabel(title: "신장", content: "\(height)cm")
                let weightLbl = commonLabel(title: "체중", content: "\(weight)kg")
                let arrangedSubviews = [nicknameLbl, emailLbl, heightLbl, weightLbl]
                
                DispatchQueue.main.async {
                    self.arrangedSubviews = arrangedSubviews
                }
            }
        }
        
        ExerciseCommon.shared.fetchSurveyGoal { goal in
            SurveyCommon.shared.fetchRecentSurveyVer { ver in
                ExerciseCommon.shared.fetchProgressRateFinal(ver:ver) { rate in
                    SurveyCommon.shared.fetchProjIngDate { day in
                        let dayLbl = commonLabel(title: "진행일", content: "\(day+1)일차")
                        let goalLbl = commonLabel(title: "목표", content: goal)
                        let rateLbl = commonLabel(title: "달성도", content: "\(rate)%")
                        
                        let stack = UIStackView(arrangedSubviews: [dayLbl, goalLbl, rateLbl])
                        stack.axis = .vertical
                        stack.distribution = .fill
                        stack.spacing = 10
                        stack.layer.cornerRadius = 15
                        stack.layer.borderWidth = 1.5
                        stack.layer.borderColor = UIColor.grayColor.cgColor
                        //  여백
                        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
                        stack.isLayoutMarginsRelativeArrangement = true
//                        completion(stack)
                        DispatchQueue.main.async {
                            self.challengeStackView = stack
                            
                            self.setupInfoView()
                        }
                    }
                }
            }
        }
        
    }
 
    func setupInfoView() {
        if (self.count > 1) {
            let stackView = self.viewWithTag(100)
            stackView?.removeFromSuperview()
        }
        
        if (self.arrangedSubviews.count > 0) || (self.challengeStackView != nil) {
            let infoStack = UIStackView(arrangedSubviews: self.arrangedSubviews)
            infoStack.tag = 100
            infoStack.axis = .vertical
            infoStack.distribution = .fill
            infoStack.spacing = 10
            infoStack.layer.cornerRadius = 15
            infoStack.layer.borderWidth = 1.5
            infoStack.layer.borderColor = UIColor.grayColor.cgColor
            //  여백
            infoStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
            infoStack.isLayoutMarginsRelativeArrangement = true
            
            [self.infoTitle.label, self.editInfoBtn.button, infoStack,
             self.challengeTitle1.label, self.challengeStackView!].forEach { self.addSubview($0) }

            self.infoTitle.label.snp.makeConstraints {
                $0.top.equalToSuperview().inset(30)
                $0.leading.equalToSuperview().inset(30)
            }
            self.editInfoBtn.button.snp.makeConstraints {
                $0.top.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
            infoStack.snp.makeConstraints {
                $0.top.equalTo(self.infoTitle.label.snp.bottom).offset(5)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
                
            // 진행중인 챌린지
            self.challengeTitle1.label.snp.makeConstraints {
                $0.top.equalTo(infoStack.snp.bottom).offset(40)
                $0.leading.equalToSuperview().inset(30)
            }

            self.challengeStackView!.snp.makeConstraints {
                $0.top.equalTo(self.challengeTitle1.label.snp.bottom).offset(5)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
        }
    }
}
