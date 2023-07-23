//
//  CompleteCollectionViewSubCell.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/01/23.
//

import Foundation
import UIKit

class CompleteCollectionViewSubCell: UICollectionViewCell {
    
    let image = UIImageView(image: UIImage(named: "fire.png"))
    let image_gray = UIImageView(image: UIImage(named: "fire_gray.png"))
    let goalLabel = UILabel()
    let defaultLabel = UILabel()
    let dateLabel = UILabel()
    let progressLabel = UILabel()
    let baseView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaultView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompleteCollectionViewSubCell {
    
    func setupSubviews(goal:String, date:String, rate:String) {
        self.layer.cornerRadius = 20
        goalLabel.attributedText = NSMutableAttributedString().bold(string: goal)
        dateLabel.attributedText = NSMutableAttributedString().regular(string: date, fontSize: 14)
        progressLabel.attributedText = NSMutableAttributedString().regularBold(string: rate, fontSize: 18)
        
        baseView.backgroundColor = .cellColor
        baseView.layer.cornerRadius = 20
        self.addSubview(baseView)
        baseView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [image, goalLabel, dateLabel, progressLabel].forEach { baseView.addSubview($0) }
        
        image.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        goalLabel.snp.makeConstraints {
            $0.top.equalTo(image.snp.bottom).offset(7)
            //$0.centerX.equalToSuperview()
            //$0.height.equalTo(50)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(goalLabel.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
        }
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setupDefaultView() {
        self.backgroundColor = .cellColor
        self.layer.cornerRadius = 20
        [image_gray, defaultLabel].forEach { addSubview($0) }
        let txt = "새로운 챌린지\n완료 시\n추가됩니다"
        defaultLabel.attributedText = NSMutableAttributedString().regular(string: txt, fontSize: 14)
        defaultLabel.numberOfLines = 3
        
        image_gray.snp.makeConstraints {
            $0.top.equalToSuperview().inset(15)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        defaultLabel.snp.makeConstraints {
            $0.top.equalTo(image_gray.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
    }
}
