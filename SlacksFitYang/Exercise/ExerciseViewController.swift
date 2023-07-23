//
//  ExerciseViewController.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/04.
//

import SnapKit
import UIKit
import FirebaseFirestore

class ExerciseViewController: UIViewController {
    var callCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TO DO: 아이패드mini에서 짤림..
        view.addSubview(CalendarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 150)))
        let height = self.view.bounds.size.height - CGFloat(150 + getTabBarHeight())
        view.addSubview(ExerciseView(frame: CGRect(x: 0, y: 150, width: self.view.frame.size.width, height: height)))
        // init 시점을 조절해주면 됨
        NotificationCenter.default.addObserver(self, selector: #selector(setupFinalView), name: NSNotification.Name(rawValue: "addFinalView"), object: nil)
    }
    
    @objc func setupFinalView() {
        // TO DO: 아이패드 대응 안됨.. 화면자체가 작아서 다 안들어옴. 리젝 당하면 스크롤뷰 만들어야 할듯
        let height = self.view.frame.size.height - CGFloat(150 + getTabBarHeight())
        callCount += 1
        if callCount == 1 { // view가 계속 붙는 현상 방지.. cellForItemAt 말고 다른곳에서 호출하면 되려나? 고민 필요
            view.addSubview(FinalView(frame: CGRect(x: 0, y: 150, width: self.view.frame.size.width, height: height)))
        }
    }
}




/*
 
 func fetchData() {
     // FireStore 에서 가져오기
     db.collection("day1").getDocuments { snapshot, error in
         guard let documents = snapshot?.documents else {
             print("Firestore Fetching Error \(String(describing: error))")
             return
         }
         
         self.exercisesTotal = documents.compactMap { doc -> Exercise? in
             do {
                 let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                 let jsonParsing = try JSONDecoder().decode(Exercise.self, from:jsonData)
                 //print("json파싱결과",jsonParsing.title)
                 return jsonParsing
                 
             } catch let error {
                 print("JSON Parsing Error \(error)")
                 return nil
             }
             
         }
         DispatchQueue.main.async {
             self.exerciseCollectionView.reloadData()
         }
         //print("테스트",self.exercisesTotal.count) // 정상
     }
 }
 //print("테스트2",self.exercisesTotal.count)
 
 
 */




/*
ref = Database.database().reference()

ref.observe(.value) { snapshot in
    guard let value = snapshot.value as? [String:[String:Any]] else { return }
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: value)
        let exerciseData = try JSONDecoder().decode( Exercise.self, from: jsonData)
        self.exercise_Total = [exerciseData]
        
        DispatchQueue.main.async {
            self.exerciseCollectionView.reloadData()
        }
        
    } catch let error {
        print("ERROR JSON Parsing \(error.localizedDescription)")
    }
    
}
exerciseCollectionView.reloadData()
 */




