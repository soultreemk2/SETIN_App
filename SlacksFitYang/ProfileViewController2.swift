//
//  ProfileViewController2.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/07/04.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FirebaseFirestoreSwift

/*
 기본 바탕: ScrollView
 contentView 위에다가
  > TopTitle (UIView)
  > InfoCollection (UIView)
  > collectionView
 */

class ProfileViewController2: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        setupScrollView()
        setupContentView()
        
        // ⭐️⭐️⭐️ 스크롤 영역을 넓히고 싶을때!!!
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        scrollView.contentInset = insets
    }
}

private extension ProfileViewController2 {
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.frame.size.height - CGFloat(getTabBarHeight()))
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(scrollView.snp.height)  // ⭐️⭐️⭐️ height를 지정하지 않으면 contentView가 안붙음
            $0.edges.equalToSuperview()
        }
    }
    
    func setupContentView() {
        let width = self.view.frame.size.width
        let topTitleView = TopTitleView(frame: CGRect(x: 0, y: 0, width: width, height: 150))
        
        let infoIngView = InfoIngView(frame: CGRect(x: 0, y: 150, width: width, height: 400))
        
        let completeView = CompleteCollectionView(frame: CGRect(x: 0, y: 570, width: width, height: 200))
        
        contentView.addSubview(topTitleView)
        contentView.addSubview(infoIngView)
        contentView.addSubview(completeView)
    }
}
