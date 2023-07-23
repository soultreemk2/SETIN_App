//
//  RecordingCollectionViewCell.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/23.
//

import UIKit
import SnapKit

class RecordingCollectionViewCell: UICollectionViewCell {
    private lazy var setLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.clipsToBounds = true
        label.layer.cornerRadius = 7
        label.font = UIFont.systemFont(ofSize: 11)
        label.backgroundColor = .cellColor
        label.textColor = .grayColor
        
        return label
    }()
    
    func setup(count:Int) {
        addSubview(setLabel)
        setLabel.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(35)
        }
        
        setLabel.text = "\(count+1)set"
    }
    
    override var isSelected: Bool {
        didSet {
            setLabel.backgroundColor = isSelected ? .mainColor: .cellColor
            setLabel.textColor = isSelected ? .white: .grayColor
        }
    }
}
