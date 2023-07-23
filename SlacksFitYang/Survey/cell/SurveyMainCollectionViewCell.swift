//
//  SurveyMainCollectionViewCell.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/03/25.
//

import SnapKit
import UIKit

class SurveyMainCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefault()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SurveyMainCollectionViewCell {
    private func setupDefault() {
        [imageView, titleLabel].forEach { self.addSubview($0) }
        imageView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(200)
//            $0.width.equalTo(320)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
    }
    
    func setup(index:Int) {
        if index == 0 {
            imageView.image = UIImage(named: "dumbell_3.png")
            titleLabel.attributedText = NSMutableAttributedString().bold(string: "나에게 꼭 맞는 루틴과\n운동을 추천해요")
        } else {
            imageView.image = UIImage(named: "sneaker.png")
            titleLabel.attributedText = NSMutableAttributedString().bold(string: "인증 게시판과 달성 이벤트로 성취감을 높여요")
        }
    }
}
