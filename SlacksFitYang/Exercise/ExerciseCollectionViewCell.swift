//
//  ExerciseCollectionViewCell.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/04.
//

import SnapKit
import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseFirestoreSwift

class ExerciseCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true // image의 크기가 imageView 크기보다 클 경우 짤림 방지
        imageView.layer.cornerRadius = 12.0
        imageView.backgroundColor = .white
        
        return imageView
    }()
    
    private lazy var exersizeLbl: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .medium)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var setRecordingLbl: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var hashTagLbl1: PaddingLabel = {
       let label = PaddingLabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .mainColor
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .white
        
        return label
    }()
    
    private lazy var hashTagLbl2: UILabel = {
       let label = PaddingLabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.backgroundColor = .mainColor
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .white

        return label
    }()
    
    private lazy var refreshBtn: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
//        button.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        return button
    }()

    func setUp(daySelect: Int, rowIndex: Int) {
        setupSubviews()
        
        self.backgroundColor = .cellColor
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 10
        layer.cornerRadius = 10

        // 폰트 설정
        var combination = NSMutableAttributedString()
        let font1 = UIFont.systemFont(ofSize: 17, weight: .bold)
        let attributes1: [NSAttributedString.Key: Any] = [.font: font1, .foregroundColor: UIColor.black]
        let font2 = UIFont.systemFont(ofSize: 15)
        let attributes2: [NSAttributedString.Key: Any] = [.font: font2, .foregroundColor: UIColor.grayColor]
        
        self.imageView.image = nil
        self.exersizeLbl.text = nil
        self.hashTagLbl1.text = nil
        self.hashTagLbl2.text = nil
        self.setRecordingLbl.attributedText = nil
        
        // 사용자가 기록한 세트 수(or 횟수) 가져오기
        ExerciseCommon.shared.fetchSetCountByExerc(day: daySelect, index: rowIndex, update: true) { Set_or_Count in
            let countString = NSMutableAttributedString(string: "\(Set_or_Count[1])", attributes: attributes1)
            combination.append(countString)
            
            // calenarView에서 선택한 일자에 대한 운동리스트 fetch
            ExerciseCommon.shared.fetchExerciseListByDate(day: daySelect) { exerciseDayTotal in
                let exerciseInfo = exerciseDayTotal["운동\(rowIndex+1)"] as? [String: String] // 운동1, 운동2, 운동3 ....
                guard let title = exerciseInfo?["name"] as? String else { return }
                guard let tag1 = exerciseInfo?["hashTag1"] as? String else { return }
                guard let tag2 = exerciseInfo?["hashTag2"] as? String else { return }
                guard let image = exerciseInfo?["image"] as? String else { return }
                let guide = exerciseInfo?["guide"] as? String ?? ""
                
                self.exersizeLbl.text = title
                self.hashTagLbl1.text = tag1
                self.hashTagLbl2.text = tag2
                self.imageView.image = UIImage(named: "\(image).png")
                
                if guide.count >= 1 {
                    let guideString = NSAttributedString(string: "/\(guide)회", attributes: attributes2)
                    combination.append(guideString)
                } else {
                    let guideString = NSAttributedString(string: "/10Set", attributes: attributes2)
                    combination.append(guideString)
                }
                
                self.setRecordingLbl.attributedText = combination
                combination = NSMutableAttributedString()
            }
        }
    }
}

private extension ExerciseCollectionViewCell {
    // MARK: UI
    func setupSubviews() {
        [imageView, exersizeLbl, setRecordingLbl, hashTagLbl1, hashTagLbl2, refreshBtn].forEach { addSubview($0) }
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.leading.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(10)
        }
        
        exersizeLbl.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(20)
            $0.top.equalToSuperview().inset(15)
            $0.height.equalTo(20)
        }
        
        setRecordingLbl.snp.makeConstraints {
            $0.leading.equalTo(exersizeLbl)
            $0.top.equalTo(exersizeLbl.snp.bottom).inset(10)
        }
        
        hashTagLbl1.snp.makeConstraints {
            $0.leading.equalTo(exersizeLbl)
            $0.top.equalTo(setRecordingLbl.snp.bottom)
            $0.bottom.equalToSuperview().inset(12.0)
        }
        
        hashTagLbl2.snp.makeConstraints {
            $0.leading.equalTo(hashTagLbl1.snp.trailing).offset(10)
            $0.top.equalTo(setRecordingLbl.snp.bottom)
            $0.bottom.equalToSuperview().inset(12.0)
        }
        
        refreshBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15.0)
            $0.top.equalToSuperview().inset(12.0)
        }
    }
}
