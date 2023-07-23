//
//  PictureCollectionViewCell.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/04/09.
//

import Foundation
//import UIKit
import PhotosUI

class PictureCollectionViewCell: UICollectionViewCell {
    // 한번만 생성됨..
    lazy var pictureImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .cellColor
        imgView.layer.cornerRadius = 7
        imgView.isUserInteractionEnabled = true
//        imgView.contentMode = .scaleAspectFit
        // aspectFit: 이미지가 이미지뷰 보다 작은 경우 - 비율에맞게 무조건 늘려버림.. (이미지가 클 경우에 사용)
        // center: 이미지가 이미지뷰 보다 작은 경우도 길이와 너비가 늘어나지 않고 원본 사이즈 유지
        return imgView
    }()
    
    var dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefault()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        pictureImgView.image = nil
    }
}


extension PictureCollectionViewCell {
    
    func setupDate(day: String, dayOfWeek: String) {
        if day.count == 0 { return }
        dateLabel.text = "\(day)일 \(dayOfWeek)요일"
        dateLabel.textAlignment = .center
    }
    
    
    func setupDefault() {
        [pictureImgView, dateLabel].forEach { self.addSubview($0) }
        pictureImgView.image = nil // ❗️❗️삽질 : nil할당하지 않으면 cellForItemAt에서 이미지가 2개씩 바뀜...
                                   // 3클릭하면 3이랑5이미지가 같이 바뀌는 식. 원인은 못찾음.. 왜그러는 걸까
        pictureImgView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(self.frame.size.height - 20)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(pictureImgView.snp.bottom).offset(3)
            $0.height.equalTo(15)
            $0.centerX.equalToSuperview()
        }
    }
}

struct imageInfo: Codable {
    let projNum: Int!
    var imgNum: Int!
    let imgData: Data!
}
