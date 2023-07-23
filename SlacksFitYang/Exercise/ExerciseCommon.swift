//
//  ExerciseCommon.swift
//  SlacksFit
//
//  Created by YANG on 2022/12/13.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class ExerciseCommon {
    static let shared = ExerciseCommon()
    
    let db = Firestore.firestore()
    let loginInfo = FirebaseLoginInfo.shared.getCurrentUserInfo()

    /// 일자 별 운동 종목 셋팅
    func makeExerciseListByDate() {
        // json불러오기
        guard
            let jsonData = loadJSON()
        else { return }
        
        let exerciseList = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        let infoList = exerciseList["exerciseList"] as! [[String: String]]
        var infos: [String: String]

        // 14*7 = 98개를 난수로 생성, 38개 중에서 중복추출
        for day in 1...14 {
            // 50개 종목에서 7개씩 랜덤으로 추출
            var indexes:[Int] = []
            while indexes.count < 7 {
                let index = Int.random(in: 1...38)
                if !indexes.contains(index){
                    indexes.append(index)
                }
           }
            
            // 데이터 저장
            let docRef = self.db.collection("users").document(loginInfo)
                           .collection("ExerciseList").document("day\(day)")
            
            for (index, randInt) in indexes.enumerated() {
                infos = infoList[randInt-1]
                
                do {
                    try docRef.setData(from: ["운동\(index+1)":infos], merge: true)
                    indexes.removeAll()
                } catch let error {
                    print("Error writing to Firestore: \(error)")
                }
            }
        }
    }
    
    private func loadJSON() -> Data? {
        guard let fileLocation = Bundle.main.url(forResource: "ExerciseList", withExtension: "json") else { return nil }
        
        do {
            // 4. 해당 위치의 파일을 Data로 초기화하기
            let data = try Data(contentsOf: fileLocation)
            return data
        } catch {
            // 5. 잘못된 위치나 불가능한 파일 처리 (오늘은 따로 안하기)
            return nil
        }
    }
    
    /// 일자 별 운동 리스트 받아오기
    func fetchExerciseListByDate(day: Int, completion: @escaping([String:Any])->()){
        let docRef = db.collection("users").document(loginInfo)
                       .collection("ExerciseList").document("day\(day+1)")
       
        docRef.getDocument { (snapshot, error) in
           if let document = snapshot {
               guard let exerciseDayTotal = document.data() else { return }
               //let exerciseArr = data?["운동\(day+1)"] as? Array ?? []
               completion(exerciseDayTotal)
           }
       }
   }
    /// (일자별&셋트별) 운동 무게, 횟수 저장
    func sendWeightCountBySet(day: Int, index: Int, setNum:Int, weight: Int, counting: Int) {
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("recording\(ver)").document("day\(day+1)")
            
            do {
                try docRef.setData(from: ["운동\(index)": ["Set\(setNum)":[weight, counting]]], merge: true)
            } catch let error {
                print("Error writing to Firestore: \(error)")
            }
        }
    }
    
    /// (일자별&운동별) 사용자가 기록한 세트 수 가져오기
    // 저장된 셋트/횟수 기록들 중에서 가장 큰 기록을 리턴
    func fetchSetCountByExerc(day: Int, index: Int, update:Bool, completion: @escaping(Array<String>)->()){
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("recording\(ver)").document("day\(day+1)")
           
            if (update) {
                docRef.addSnapshotListener { (snapshot, error) in // addsnapshot
                   if let document = snapshot {
                       let data = document.data()
                       let setAll = data?["운동\(index)"] as? [String:Any]
                       let maxSetCount = setAll?.keys.sorted(by: >)[0] as? String ?? "0"
                       let maxSetCount_str = maxSetCount[maxSetCount.index(maxSetCount.endIndex, offsetBy: -1)]
                       
                       var SetOrCount = ""
                       if maxSetCount_str == "0" { // 세트 기록이 없는 경우 (onlyCounting)
                           let set_0 = setAll?["Set0"] as? [Any]
                           let onlyCounting_Count = set_0?[1] as? NSNumber // 삽질 오지게함.. optional값을 형식에 맞게 벗기는거 왤케 까다로움..
                           SetOrCount = onlyCounting_Count?.stringValue ?? "0"
                           completion(["onlyCount", SetOrCount])
                       } else {
                           SetOrCount = String(maxSetCount_str)
                           completion(["setCount", SetOrCount])
                       }
                       
                   }
               }
            } else {
                docRef.getDocument { (snapshot, error) in // addsnapshot
                   if let document = snapshot {
                       let data = document.data()
                       let setAll = data?["운동\(index)"] as? [String:Any]
                       let maxSetCount = setAll?.keys.sorted(by: >)[0] as? String ?? "0"
                       let maxSetCount_str = maxSetCount[maxSetCount.index(maxSetCount.endIndex, offsetBy: -1)]

                       var SetOrCount = ""
                       if maxSetCount_str == "0" { // 세트 기록이 없는 경우 (onlyCounting)
                           let set_0 = setAll?["Set0"] as? [Any]
                           let onlyCounting_Count = set_0?[1] as? NSNumber // 삽질 오지게함.. optional값을 형식에 맞게 벗기는거 왤케 까다로움..
                           SetOrCount = onlyCounting_Count?.stringValue ?? "0"
                           completion(["onlyCount", SetOrCount])
                       } else {
                           SetOrCount = String(maxSetCount_str)
                           completion(["setCount", SetOrCount])
                       }
                   }
               }
            }

        }
   }
    /// (일자별&운동별&셋트별) 사용자가 저장한 운동 기록 로딩
    func fetchWeightCountBySet(day: Int, index: Int, setNum: Int, completion: @escaping(Array<Int>)->()) {
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("recording\(ver)").document("day\(day+1)")
           
            docRef.getDocument { (snapshot, error) in
               if let document = snapshot {
                   let data = document.data()
                   let setAll = data?["운동\(index)"] as? [String:Any]
                   // 세트 기록이 없는 경우 0으로 전달
                   let setWeightCount = setAll?["Set\(setNum)"] as? Array<Int> ?? [0, 0]
                   completion(setWeightCount)
               }
           }
        }
    }
    /// (일자별&운동별&셋트별) 운동 기록 삭제
    func deleteRecordingBySet(day: Int, index: Int, setNum: Int) {
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("recording\(ver)").document("day\(day+1)")
            docRef.getDocument { (snapshot, error) in
               if let document = snapshot {
                   let data = document.data()
                   let setAll = data?["운동\(index)"] as? [String:Any]
                   let setWeightCount = setAll?["Set\(setNum)"] as? Array<Int> ?? [0,0]
                   docRef.updateData(["운동\(index)": FieldValue.arrayRemove(setWeightCount)]) { err in
                       if let err = err {
                           print("Error removing document: \(err)")
                       } else {
                           print("Document successfully removed!")
                       }
                   }
               }
           }
        }
    }
    /// 완료한 프로젝트의 survey 정보
    func fetchCompleteSurveyInfo(index: Int, completion: @escaping(Array<[String]>, Int)->()) {
        // 해당 프로젝트의 survey기록, 달성률
        var surveyInfo: Array<[String]> = []
        var countInfo: Array<Int> = []
        var progressRate: Int = 0

        // survey기록 로딩
        let surveyRef = self.db.collection("users").document(self.loginInfo).collection("survey")
            .document("surveyDoc\(index)")
        surveyRef.getDocument { doc, err in
            if let doc = doc {
                let data = doc.data()
                let weight = data?["UpDownWeight"] as? Int ?? 0
                let updown = data?["UpDown"] as? String ?? "nil"
                let UpDownWeight = "\(weight)" + "kg " + updown + " 챌린지" // 1kg 감량
                let startDate = data?["projStartDate"] as? String ?? "nil"
                let tmpDate = self.dateStringToDate(dateStr: startDate) // Date형식으로 변환
                let tmpDate2 = Calendar.current.date(byAdding: .day, value: 14, to: tmpDate) // 14일 더하고
                let endDate = self.dateToString(date: tmpDate2!) // 다시 문자열로 반환
                let finalDate = startDate.suffix(8) + "~" + endDate
                
                if tmpDate2! <= Date() { // 프로젝트 종료일 < 오늘날짜
                    surveyInfo.append(contentsOf: [[UpDownWeight, finalDate]])
                    countInfo.append(1)
                }
            }
            completion(surveyInfo, countInfo.count)
        }

    }
    func dateStringToDate(dateStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let convertDate = formatter.date(from: dateStr) else { return Date() } // Date 타입으로 변환
        return convertDate
    }
    
    func dateToString(date: Date) -> String {
        let dateForm = DateFormatter()
        dateForm.dateFormat = "yy-MM-dd"
        let dateStr = dateForm.string(from: date)
        return dateStr
    }
    

    
    /* Survey */
    /// 설문조사 기록 로딩 (FinalView)
    func fetchSurveyStyle(completion: @escaping(String)->()) {
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            
            docRef.getDocument { (snapshot, error) in
               if let document = snapshot {
                   let data = document.data()
                   let style = data?["style"] as? Int
                   var style_str = ""
                   
                   switch style {
                   case 1:
                       style_str = "매일 전신부위를 다양하게"
                   case 2:
                       style_str = "하루마다 상체와 하체를 번갈아서"
                   case 3:
                       style_str = "하루에 한 부위만 집중적으로"
                   default:
                       return
                   }
                   completion(style_str)
               }
           }
        }

    }
    /// 설문조사 기록 로딩 (목표)
    func fetchSurveyGoal(completion: @escaping(String)->()) {
        SurveyCommon.shared.fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            
            docRef.getDocument { (snapshot, error) in
               if let document = snapshot {
                   let data = document.data()
                   let weight = data?["UpDownWeight"] as? Int ?? 0
                   let updown = data?["UpDown"] as? String ?? "nil"
                   let UpDownWeight = "\(weight)" + "kg " + updown

                   completion(UpDownWeight)
               }
           }
        }

    }
    
    /// 달성도 측정 (일자별)
    func fetchProgressRate(ver: Int, day: Int, completion: @escaping(Float)->()) {
        let docRef = db.collection("users").document(loginInfo)
                       .collection("recording\(ver)").document("day\(day)")
        docRef.addSnapshotListener { (snapshot, error) in
           var sumMaxSetCount:Float = 0.0
           if let document = snapshot {
               let data = document.data()
               for i in 1...7 { // 운동7가지
                   let setAll = data?["운동\(i)"] as? [String:Any]
                   let maxSetCount = setAll?.keys.sorted(by: >)[0] as? String ?? "0"
                   let maxSetCount_str = maxSetCount[maxSetCount.index(maxSetCount.endIndex, offsetBy: -1)]
                   let maxSetCount_Int = Float(String(maxSetCount_str)) ?? 0.0
                   sumMaxSetCount += maxSetCount_Int
               }
           }
           completion((sumMaxSetCount/7*4)*100) // 운동7가지x4세트씩
       }
    }
    /// 달성도 측정 (최종: 일자별합산/14일)
    func fetchProgressRateFinal(ver: Int,completion: @escaping(Float)->()) {
        var sumRate:Float = 0.0
        for i in 1...14 {
            fetchProgressRate(ver:ver, day: i) { rate in
                sumRate += rate
            }
        }
        completion(sumRate/14)
    }
}
