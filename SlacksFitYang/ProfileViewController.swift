//
//  ProfileViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/06.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController {
    var loginInfo = FirebaseLoginInfo.shared
    // cell Identifier
    let TOP_TITLE_CELL = "TopTitleCell"
    let INFO_ING_CHALLENGE_CELL = "InfoIngCollectionViewCell"
    let COMPLETE_CHALLENGE_CELL = "CompleteCollectionViewCell"
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1.0
        let challengeCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-30), collectionViewLayout: layout) // tabBarItem 크기가 30이다
        
        challengeCollectionView.backgroundColor = .white
        challengeCollectionView.delegate = self
        challengeCollectionView.dataSource = self

        // 섹션1 > 최상단 타이틀, 섹션2 > 챌린지 정보 뷰 2개, 섹션3 > 완료한 챌린지(컬렉션뷰)
        challengeCollectionView.register(TopTitleCollectionViewCell.self, forCellWithReuseIdentifier: TOP_TITLE_CELL)
        challengeCollectionView.register(InfoIngCollectionViewCell.self, forCellWithReuseIdentifier: INFO_ING_CHALLENGE_CELL)
        challengeCollectionView.register(CompleteCollectionViewCell.self, forCellWithReuseIdentifier: COMPLETE_CHALLENGE_CELL)
        
        return challengeCollectionView
    }()
    
    override func viewDidLoad() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .white
        // collectionView
        view.addSubview(collectionView)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    // 섹션1 > 최상단 타이틀, 섹션2 > 챌린지 정보 뷰 2개, 섹션3 > 완료한 챌린지(컬렉션뷰)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    // 섹션 별 cell 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if indexPath.section == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: TOP_TITLE_CELL, for: indexPath) as! TopTitleCollectionViewCell
        } else if indexPath.section == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: INFO_ING_CHALLENGE_CELL, for: indexPath) as! InfoIngCollectionViewCell
            
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: COMPLETE_CHALLENGE_CELL, for: indexPath) as! CompleteCollectionViewCell
            
        }
        return cell
    }
    
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    // cell 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        if indexPath.section == 0 {
            size = CGSize(width: collectionView.frame.width, height: collectionView.bounds.height*0.2)
        } else if indexPath.section == 1 {
            size = CGSize(width: collectionView.frame.width, height: collectionView.bounds.height*0.6)
        } else {
            size = CGSize(width: collectionView.frame.width, height: collectionView.bounds.height*0.2)
        }
        return size
    }
}
