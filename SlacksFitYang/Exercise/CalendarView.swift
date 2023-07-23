//
//  CalendarView.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/10.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class CalendarView: UIView {
    var projDateFinal: Date = Date()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self

        // custom Cell 등록
        calendarCollectionView.register(CalendarCollectionViewCell.self, forCellWithReuseIdentifier: "calendarCell")

        calendarCollectionView.showsHorizontalScrollIndicator = false
        
        return calendarCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell",
                                                              for: indexPath) as! CalendarCollectionViewCell
        let row = indexPath.row // 0~13까지 13번 호출됨
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        SurveyCommon.shared.fetchStartDate { dateStr in
            self.projDateFinal = formatter.date(from: dateStr) ?? Date()
            let projStartDate = Calendar.current.dateComponents([.year,.month,.day], from: self.projDateFinal)

            let startDate = Calendar(identifier: .gregorian).date(from: projStartDate)
            let projDate = Calendar.current.date(byAdding: .day, value: row, to: startDate!) // 시작일로부터 1일씩 더해감

            // UI Update
            calendarCell.setup(day:row+1, date: projDate!)

            if projDate! < Date() {
                calendarCell.setupColorBlue()
                collectionView.scrollToItem(at: IndexPath(row: row, section: 0), at: .centeredHorizontally, animated: true)
            } else {
                calendarCell.setupColorGray()
            }
            
            // projStartDate와 오늘날짜의 차이
            let offsetComp = Calendar.current.dateComponents([.day], from: self.projDateFinal, to: Date())
            if offsetComp.day! >= 13 { // 프로젝트가 끝나는 날 FinalView 객체 생성
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addFinalView"), object: nil)
            }

        }
        return calendarCell
    }
    
    
}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    // cell 크기 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: 70)
    }
    
    // cell 클릭 시 마다
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 일자 별(1~14일) 운동리스트 조회 > ExerciseCollectionViewCell에 뿌려줌
        // 몇번째 일자 클릭한건지 데이터 던지기
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        
        let row = indexPath.row

        SurveyCommon.shared.fetchStartDate { dateStr in
            self.projDateFinal = formatter.date(from: dateStr) ?? Date()
            let projStartDate = Calendar.current.dateComponents([.year,.month,.day], from: self.projDateFinal)

            let startDate = Calendar(identifier: .gregorian).date(from: projStartDate)
            let projDate = Calendar.current.date(byAdding: .day, value: row, to: startDate!)
            let projDateStr = formatter.string(from: projDate!)
            let todayStr = formatter.string(from: Date())
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CalendarSelect"), object: [row, projDateStr, todayStr] as [Any])
        }
      
        // 터치에 따라 스크롤 되도록 설정
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }
}

extension CalendarView {
    func setupView() {
        self.backgroundColor = .white
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview()
//            $0.bottom.equalToSuperview()
        }
    }
}
