//
//  CompleteCollectionViewCell.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/01/16.
//

import UIKit
import SnapKit

class CompleteCollectionViewCell: UICollectionViewCell {
    var completeCount:Int = 0 // 완료한 챌린지 수
    var surveyInfo: Array<Array<String>> = [] // 완료한 챌린지의 survey기록
    
    struct commonTitle {
        var title: String

        lazy var label: UILabel = {
            let label = UILabel()
            label.attributedText = NSMutableAttributedString().regularBold(string: title, fontSize: 17)
            return label
        }()
    }
    
    // item이 5개인 collectionView 생성
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        
        // Title
        var infoTitle = commonTitle(title: "완료한 챌린지")
        // collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(CompleteCollectionViewSubCell.self, forCellWithReuseIdentifier: "completeSubCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // autoLayout
        self.addSubview(infoTitle.label)
        infoTitle.label.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(30)
        }
        
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.trailing.leading.bottom.equalToSuperview()
        }
        
        // 네트워크 - cell개수 불러오기
        for i in 1...5 {
            ExerciseCommon.shared.fetchCompleteSurveyInfo(index: i) { survey, count in
                self.completeCount += count
                self.surveyInfo += survey
                print("countInfo", count)
                collectionView.reloadData()
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompleteCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.completeCount + 1 // 2+1 = 3개
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "completeSubCell", for: indexPath) as! CompleteCollectionViewSubCell
        // self.completeCount에 값이 들어오는 순간 보다 indexPath.row호출 시점이 더 빠르므로...
        // defaultView를 깔아두고, 그 위에다가 infoView 얹는 식으로 진행
        if indexPath.row < self.completeCount { // 0,1
            let cellInfo = self.surveyInfo[indexPath.row]
            cell.setupSubviews(goal: cellInfo[0], date: cellInfo[1], rate: "40% 달성") // TO DO: 달성률 수정
            return cell
//        } else {
//            cell.setupDefaultView()
//        }
        }
        
        return cell
    }
    // cell 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
    }
}
