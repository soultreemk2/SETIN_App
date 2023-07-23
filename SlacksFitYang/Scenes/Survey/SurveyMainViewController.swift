//
//  SurveyMainViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit

class SurveyMainViewController: UIViewController {
    
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 15
        btn.backgroundColor = .gray
        btn.setTitle("지금 시작하기", for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return btn
    }()
    
    @objc func buttonTapped(_sender: UIButton) {
        // 첫번째 tab의 surveyViewController에 push
        self.navigationController?.pushViewController(StepOneViewController(), animated: true)
        
        // 이거는 메인 window의 최상위계층 navigationController에 push
        //tabBarController?.navigationController?.pushViewController(StepOneViewController(), animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        view.addSubview(startBtn)
        
        startBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(300)
        }
        
    }
}
