//
//  SurveyMainViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/27.
//

import UIKit
import SnapKit

class SurveyMainViewController: UIViewController {
    var currentPage:Int = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white

        collectionView.delegate = self
        collectionView.dataSource = self

        // custom Cell 등록
        collectionView.register(SurveyMainCollectionViewCell.self, forCellWithReuseIdentifier: "mainCell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .mainColor
        pageControl.isUserInteractionEnabled = false
        
        return pageControl
    }()
    
    
    private lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .mainColor
        btn.setAttributedTitle(NSMutableAttributedString().whiteBold(string: "지금 세틴 프로젝트를 시작해보세요 >", fontSize: 15), for: .normal)
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
        [collectionView,pageControl,startBtn].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.frame.size.height/2)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        startBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(100)
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.height.equalTo(50)
        }
        
        startTimer()
        
    }
    
    // 3초마다 실행되는 타이머
    func startTimer() {
        let _: Timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (Timer) in
            self.bannerMove()
        }
    }
    
    // 배너 움직이는 매서드
    func bannerMove() {
        // 현재페이지가 마지막 페이지일 경우
        if currentPage == 1 {
            // 맨 처음 페이지로 돌아감
            collectionView.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .right, animated: true)
            currentPage = 0
            pageControl.currentPage = currentPage
            return
        }
        // 다음 페이지로 전환
        currentPage += 1
        collectionView.scrollToItem(at: NSIndexPath(item: currentPage, section: 0) as IndexPath, at: .right, animated: true)
        pageControl.currentPage = currentPage
    }
}


extension SurveyMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    // cell크기를 지정해주지 않으면 cell Class에서 equalToSuperView호출 시 크기가 제대로 안잡힘...
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! SurveyMainCollectionViewCell
        
        mainCell.setup(index: indexPath.row)
        
        return mainCell
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let page = Int(targetContentOffset.pointee.x / self.view.frame.width)
//        self.pageControl.currentPage = page
//    }
}
