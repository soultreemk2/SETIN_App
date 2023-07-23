//
//  TabBarController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/04.
//

import UIKit
import FirebaseFirestore

class TabBarController: UITabBarController {
    let db = Firestore.firestore()
    let loginInfo = FirebaseLoginInfo.shared.getCurrentUserInfo()
    let attributes : [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        object_setClass(self.tabBar, CustomTabBar.self)
    }
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    // 4개의 tabBar 정의
    lazy var surveyViewController: UIViewController = {
        let navCont = UINavigationController(rootViewController:SurveyMainViewController())
        let img = UIImage(named: "fire_gray.png") // 30x30
        let tabBarItem = UITabBarItem(title: "설문조사", image: img, tag: 0)
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        navCont.tabBarItem = tabBarItem
        return navCont
    }()
    
    lazy var exerciseViewController: UIViewController = {
        let viewController = ExerciseViewController()
        let img = UIImage(named: "fire_gray.png") // 30x30
        let tabBarItem = UITabBarItem(title: "챌린지", image: img, tag: 0)
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        viewController.tabBarItem = tabBarItem
        
        return viewController
    }()
    
//    lazy var dietViewController: UIViewController = {
//        let viewController = UIViewController()
//        let tabBarItem = UITabBarItem(title: "식단", image: UIImage(systemName: "fork.knife.circle"), tag: 1)
//        viewController.tabBarItem = tabBarItem
//
//        return viewController
//    }()

    lazy var pictureRecordViewController: UIViewController = {
        let viewController = PictureRecordViewController()
        let img = UIImage(named: "dumbell_tabbar.png") // 22x22
        let tabBarItem = UITabBarItem(title: "운동 인증", image: img, tag: 2)
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        viewController.tabBarItem = tabBarItem
        
        return viewController
    }()

    lazy var profileViewController: UIViewController = {
        let viewController = ProfileViewController2()
        let img = UIImage(named: "profile.png") // 22x22
        let tabBarItem = UITabBarItem(title: "내 정보", image: img, tag: 3)
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
        viewController.tabBarItem = tabBarItem
        
        return viewController
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Navigation Bar 숨기기
        navigationController?.navigationBar.isHidden = true
        UITabBar.appearance().tintColor = UIColor.red
        
        // 1. 진행한 설문조사가 없는 경우(첫진입)
        SurveyCommon.shared.fetchSurveyDocList { surveyArr in
            if surveyArr.count == 0 {
                self.viewControllers = [self.surveyViewController, self.pictureRecordViewController, self.profileViewController]
            } else { // 설문조사를 한번이라도 진행한 경우
                // 2. 설문 도중 중단된 경우 (앱 종료 등..)
                SurveyCommon.shared.fetchRecentSurveyVer { ver in
                    let docRef = self.db.collection("users").document(self.loginInfo)
                                   .collection("survey").document("surveyDoc\(ver)")
                    
                    docRef.getDocument { doc, err in
                        if let doc = doc {
                            let data = doc.data()
                            let projStartDate = data?["projStartDate"] as? String ?? "nil"
                            
                            if projStartDate == "nil" {
                                // 진행중이던 survey는 지우기
                                docRef.delete()
                                self.viewControllers = [self.surveyViewController, self.pictureRecordViewController, self.profileViewController]
                            } else {
                                self.viewControllers = [self.exerciseViewController, self.pictureRecordViewController, self.profileViewController]
                            }
                        }
        
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation Pop gesture 막기
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(setupSurveyVC), name: NSNotification.Name(rawValue: "newSurvey"), object: nil)
    }
    
    @objc func setupSurveyVC() {
        print("FinalView에서 newProj 타고 넘어옴")
        self.viewControllers = [self.surveyViewController, self.pictureRecordViewController, self.profileViewController]
    }
}
// TabBar 높이 조절
class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
         sizeThatFits.height = window.safeAreaInsets.bottom + 50
         return sizeThatFits
    }
}

/*
extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 40
        return sizeThatFits
    }
}
*/
