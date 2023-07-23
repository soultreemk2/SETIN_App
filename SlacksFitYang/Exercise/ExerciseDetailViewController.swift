//
//  ExerciseDetailViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/04.
//

import SnapKit
import UIKit

class ExerciseDetailViewController: UIViewController {
    // 운동 기록 저장 -> ExerciseView에서 보여주기
    var currentIdx: Int = 0
    var selectedDate: Int = 0
    var recordBtnEnabled = true

    private lazy var exercisePageVC: UIPageViewController = {
        let pageViewControl = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewControl.delegate = self
        pageViewControl.dataSource = self
        return pageViewControl
    }()

    func viewControllerAtIndex(index: Int) -> ExerciseContentView {
        let vc = ExerciseContentView()
        vc.index = index 
        vc.selectedDate = selectedDate
        vc.recordBtnEnabled = recordBtnEnabled
        
        // 운동 타이틀, 비디오 url  -> 모델에서 가져오기
        ExerciseCommon.shared.fetchExerciseListByDate(day: selectedDate) { exerciseDayTotal in
            let exerciseInfo = exerciseDayTotal["운동\(index+1)"] as? [String: String]
            guard let title = exerciseInfo?["name"] as? String else { return }
            guard let url = exerciseInfo?["youTubeID"] as? String else { return }
            guard let type = exerciseInfo?["type"] as? String else { return }
            if ( (exerciseInfo?["startTime"] != nil) && (exerciseInfo?["endTime"] != nil) ) {
                let start = exerciseInfo?["startTime"]
                let end = exerciseInfo?["endTime"]
                vc.startTime = Float(start!)!
                vc.endTime = Int(end!)!
            }
            vc.exerciseType = type
            vc.exerciseTitle.text = title
            vc.exerciseVideoView.load(withVideoId: url, playerVars: ["playsinline": 1])
            
            vc.setupDefaultView()
            vc.setupRecordStack()
        }
    
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // pageController에 뷰컨 연결
        let startVC = self.viewControllerAtIndex(index: currentIdx) as ExerciseContentView
        let viewControllers = NSArray(object: startVC)
        
        exercisePageVC.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true)
        self.addChild(exercisePageVC)
        setupViews()

    }
}

extension ExerciseDetailViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    // 왼쪽에서 오른쪽으로 스와이프 하기 직전에 호출 > 직전에 다음 화면에 어떤 ViewController가 표출될지 결정
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ExerciseContentView
        var index = vc.index as Int
        
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }
    
    // 오른쪽에서 왼쪽으로 스와이프 하기 직전에 호출 > 직전에 다음 화면에 어떤 ViewController가 표출될지 결정
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ExerciseContentView
        var index = vc.index as Int
        
        if (index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if (index == 7) {
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    // 인디케이터 개수
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 7
    }

    // 인디케이터 초기 선택 값
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIdx
    }
}


// MARK: Private
private extension ExerciseDetailViewController {
    func setupViews() {
        view.addSubview(exercisePageVC.view)
        
        // UIPageControl 커스터마이즈
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .cellColor
        pageControl.currentPageIndicatorTintColor = .mainColor
        pageControl.backgroundColor = .detailViewColor

        UIPageControl().transform = CGAffineTransform(scaleX: 2, y: 2)
    }

}


