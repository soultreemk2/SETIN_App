//
//  CalendarCollectionViewCell.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/08.
//

import UIKit
import SnapKit

final class CalendarCollectionViewCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "fire_gray.png"))
        
        imgView.frame = CGRect(x: (self.frame.size.width-15)/2, y: 5, width: 15, height: 15)
        return imgView
    }()
    
    private lazy var dayLbl: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15.0, weight:.bold)
        label.textColor = .gray
        label.textAlignment = .center

        return label
    }()
    
    private lazy var dateLbl: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 15.0, weight:.bold)
        label.textColor = .gray
        label.textAlignment = .center

        return label
    }()
    
    private lazy var divideLine: UIView = {
       let lineView = UIView()
        lineView.backgroundColor = .gray

        return lineView
    }()
    
    // collectionView의 cellForItemAt에서 cell 등록 후 호출
    func setup(day:Int, date:Date) {
        // text셋팅
        dayLbl.text = "Day-\(day)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let current_date_string = formatter.string(from: date)
        dateLbl.text = current_date_string
        
        // 레이아웃
        setupViews()
    }
    
    func setupColorBlue() {
        dayLbl.textColor = .mainColor
        dateLbl.textColor = .mainColor
        imageView.image = UIImage(named: "fire.png")
        divideLine.backgroundColor = .mainColor
    }
    
    func setupColorGray() {
        dayLbl.textColor = .gray
        dateLbl.textColor = .gray
        imageView.image = UIImage(named: "fire_gray.png")
        divideLine.backgroundColor = .gray
    }
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? .skyBlueColor : .white
        }
    }
}

private extension CalendarCollectionViewCell {
    func setupViews() {
        [imageView, dayLbl, dateLbl, divideLine].forEach {
            addSubview($0)
        }

        dayLbl.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        dateLbl.snp.makeConstraints {
            $0.top.equalTo(dayLbl.snp.bottom).offset(6)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        divideLine.snp.makeConstraints {
            $0.top.equalTo(dateLbl.snp.bottom).offset(10)
            $0.width.equalToSuperview()
            $0.height.equalTo(7)
        }
        
    }
}
