//
//  ExerciseView.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/10.
//

import UIKit
import SnapKit

class ExerciseView: UIView {
    var clickDateIndex = 0 // calenarView에서 클릭한 날짜
    var clickDateStr = ""
    var todayDateStr = ""
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let exerciseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        exerciseCollectionView.backgroundColor = .white

        exerciseCollectionView.delegate = self
        exerciseCollectionView.dataSource = self

        // custom Cell 등록
        exerciseCollectionView.register(ExerciseCollectionViewCell.self, forCellWithReuseIdentifier: "exerciseCell")
        // header 등록
        exerciseCollectionView.register(ExerciseCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ExerciseCollectionHeaderView")
        
        return exerciseCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExerciseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let exerciseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCell",
                                                              for: indexPath) as! ExerciseCollectionViewCell
        let row = indexPath.row
        
        // calendar에서 몇일을 클릭했는지 데이터 받기 (clickDate)
        NotificationCenter.default.addObserver(self, selector: #selector(clickDateFetch), name: NSNotification.Name(rawValue: "CalendarSelect"), object: nil)
        // 해당 일자에 대한 운동정보 셋팅
        exerciseCell.setUp(daySelect: self.clickDateIndex, rowIndex: row)

        return exerciseCell
    }
    
    // header View 등록
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExerciseCollectionHeaderView", for: indexPath)
            return view
        } else {
            return UICollectionReusableView()
        }
    }
    
    @objc func clickDateFetch(_ notification : NSNotification)
    {
        let fetchDate = notification.object as! Array<Any>
        
        self.clickDateIndex = fetchDate[0] as! Int
        self.clickDateStr = fetchDate[1] as! String
        self.todayDateStr = fetchDate[2] as! String
        
        collectionView.reloadData() // reload를 해주어야 cellforItemAt이 호출되지 않더라도 바로 데이터가 반영됨
    }
}

extension ExerciseView: UICollectionViewDelegateFlowLayout {
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // detailVC로 이동
        let detailVC = ExerciseDetailViewController()
        detailVC.currentIdx = indexPath.row
        detailVC.selectedDate = self.clickDateIndex
        
        if self.clickDateStr != self.todayDateStr { // 클릭한 날짜와 오늘 날짜가 불일치
            detailVC.recordBtnEnabled = false
        } else {
            detailVC.recordBtnEnabled = true
        }
        
        
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while((topVC!.presentedViewController) != nil) {
             topVC = topVC!.presentedViewController
        }
        topVC?.present(detailVC, animated: true)
    }
    
    // header View 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32.0, height: 200 )
    }
}

extension ExerciseView {
    func setupView() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview()
//            $0.height.equalToSuperview().inset(50)
        }
    }

}
