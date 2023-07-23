//
//  SurveyCommon.swift
//  SlacksFit
//
//  Created by YANG on 2022/11/28.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class SurveyCommon {
    static let shared = SurveyCommon()
    
    let db = Firestore.firestore()
    let loginInfo = FirebaseLoginInfo.shared.getCurrentUserInfo()

    func SurveyOneDataStore(data: SurveyOne) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver+1)")
            do {
                try docRef.setData(from: data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
 
    }
    
    func SurveyTwoDataStore(data: SurveyTwo) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            do {
                try docRef.setData(from: data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
    }
    
    func SurveyThreeDataStore(data: SurveyThree) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            do {
                try docRef.setData(from: data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
    }
    
    
    func SurveyFourDataStore(data: SurveyFour) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            do {
                try docRef.setData(from: data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
    }
    
    func SurveyDataStore(data: [String: Any]) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            do {
                try docRef.setData(data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
    }
    
    func ExerciseDataStore(data: [String: Any]) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            do {
                try docRef.setData(data, merge: true)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
    }
    /// 프로젝트 시작 일자 (가장 최근 설문조사)
    func fetchStartDate(completion: @escaping(String) -> Void) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                            .collection("survey").document("surveyDoc\(ver)")
            docRef.getDocument { document, error in
                if let error = error {
                    print("error: ", error)
                } else if let document = document, document.exists {
                    let data = document.data()
                    let dateStr = data?["projStartDate"] as? String ?? ""
                    completion(dateStr)
                }
            }
        }
    }
    
    /// 프로젝트 시작 일자 (특정 프로젝트 지정)
    func fetchStartDate(ver:Int, completion: @escaping(String) -> Void) {
        let docRef = self.db.collection("users").document(self.loginInfo)
                        .collection("survey").document("surveyDoc\(ver)")
        docRef.getDocument { document, error in
            if let error = error {
                print("error: ", error)
            } else if let document = document, document.exists {
                let data = document.data()
                let dateStr = data?["projStartDate"] as? String ?? ""
                completion(dateStr)
            }
        }
    }
    
    /// 프로젝트 진행 일자 수 (시작일로부터 오늘이 몇일째 인지)
    func fetchProjIngDate(completion: @escaping(Int) -> Void) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                            .collection("survey").document("surveyDoc\(ver)")
            docRef.getDocument { document, error in
                if let error = error {
                    print("error: ", error)
                } else if let document = document, document.exists {
                    let data = document.data()
                    let dateStr = data?["projStartDate"] as? String ?? ""
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let startDateFmt = formatter.date(from: dateStr) ?? Date()
                    let offsetComp = Calendar.current.dateComponents([.day], from: startDateFmt, to: Date())
                    completion(offsetComp.day!)
                }
            }
        }
    }
    
    /// 진행한 설문조사 리스트 (프로젝트 수) > 내림차순 정렬 [4,3,2,1]
    func fetchSurveyDocList(completion: @escaping(Array<String>) -> ()) {
        var surveyNumArr:Array<String> = []
        let docRef = db.collection("users").document(loginInfo)
                        .collection("survey")
        docRef.getDocuments { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let surveyDoc = document.documentID
                    let surveyNum = surveyDoc[surveyDoc.index(before: surveyDoc.endIndex)]
                    surveyNumArr.append(String(surveyNum))
                    surveyNumArr = surveyNumArr.sorted(by: >)
                }
            }
            completion(surveyNumArr)
        }
    }
    
    /// 진행중인 운동기록 리스트 (운동기록  중인 프로젝트 수)
    func fetchRecordDocList(completion: @escaping(Int) -> ()) {
        fetchRecentSurveyVer { ver in // 가장 최근의 설문조사(ex.3)
            let docRef = self.db.collection("users").document(self.loginInfo)
                            .collection("recording\(ver)")
            
            docRef.getDocuments { document, err in
                if let document = document, !document.isEmpty {
                    completion(ver)
                } else if let document = document, document.isEmpty {
                    completion(0)
                }
            }
        }
    }
    
    /// 가장 최근의 프로젝트(설문조사) 버전
    func fetchRecentSurveyVer(completion: @escaping(Int) -> Void) {
        var surveyNumArr:Array<String> = []
        var maxSurveyVer = 0
        let docRef = db.collection("users").document(loginInfo)
                        .collection("survey")
        docRef.getDocuments { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let surveyDoc = document.documentID
                    let surveyNum = surveyDoc[surveyDoc.index(before: surveyDoc.endIndex)]
                    surveyNumArr.append(String(surveyNum))
                    surveyNumArr = surveyNumArr.sorted(by: >)
                }
            }
            if surveyNumArr.count == 0 { maxSurveyVer = 0 } else { maxSurveyVer = Int(surveyNumArr[0])! }
            completion(maxSurveyVer)
        }
    }
    
    /// 가장 최근의 프로젝트(설문조사) 버전
    func fetchRecentSurveyVerAsyn() async -> Int {
        var surveyNumArr:Array<String> = []
        var maxSurveyVer = 0
        let docRef = db.collection("users").document(loginInfo)
                        .collection("survey")
        docRef.getDocuments { snapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snapshot!.documents {
                    let surveyDoc = document.documentID
                    let surveyNum = surveyDoc[surveyDoc.index(before: surveyDoc.endIndex)]
                    surveyNumArr.append(String(surveyNum))
                    surveyNumArr = surveyNumArr.sorted(by: >)
                }
            }
            if surveyNumArr.count == 0 { maxSurveyVer = 0 } else { maxSurveyVer = Int(surveyNumArr[0])! }
        }
        return maxSurveyVer
    }
    
    /// 프로필 정보1: 완료한 프로젝트 수, 맨 처음 프로젝트 시작일
    func fetchProfileInfo1(index: Int, completion: @escaping(String) -> ()) {
        if index == 0 { // 완료한 챌린지 수
            var count = 0
            for i in 1...5 {
                let docRef1 = db.collection("users").document(loginInfo)
                                .collection("recording\(i)").document("day14")
                docRef1.getDocument { document, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if let document = document, document.exists {
                        count += 1
                    }
                    completion(String(count))
                }
            }
        } else { // 새틴 시작일
            let docRef2 = db.collection("users").document(loginInfo)
                        .collection("survey").document("surveyDoc1")
            docRef2.getDocument { document, error in
                if let error = error {
                    print("error: ", error)
                } else if let document = document, document.exists {
                    let data = document.data()
                    let startDateStr = data?["projStartDate"] as? String ?? ""
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let startDate = formatter.date(from: startDateStr) ?? Date()
                    let offsetComp = Calendar.current.dateComponents([.day], from: startDate, to: Date())
                    let offsetDay = String(offsetComp.day! + 1)
                    completion(offsetDay)
                }
            }
        }
    }
    
    /// 프로필 정보: 신장, 체중 (가장 최근 설문기반)
    func fetchPofileInfo2(completion: @escaping(Int, Int) -> ()) {
        fetchRecentSurveyVer { ver in
            let docRef = self.db.collection("users").document(self.loginInfo)
                           .collection("survey").document("surveyDoc\(ver)")
            docRef.addSnapshotListener { snapshot, err in
                if let document = snapshot {
                    let data = document.data()
                    let weight = data?["weight"] as? Int ?? 0
                    let height = data?["height"] as? Int ?? 0
                    completion(weight, height)
                }
            }
        }
    }
    
    /// 프로필 정보: 신장, 체중 (가장 최근 설문기반)
//    func fetchPofileInfo2Asyn() async -> Array<Int> {
//        var weight = 0
//        var height = 0
//        let recentVer = await fetchRecentSurveyVerAsyn()
//        let docRef = self.db.collection("users").document(self.loginInfo)
//                       .collection("survey").document("surveyDoc\(recentVer)")
//        do {
//            let snapshot = try await docRef.getDocument()
//            if let data = snapshot.data() {
//                weight = data["weight"] as! Int
//                height = data["height"] as! Int
//                return [weight,height]
//            }
//            
//        } catch {
//            print("Error getting documents: \(error)")
//            return []
//        }
////        return [weight, height]
//    }
    
    
    /// 닉네임,신장,체중 정보 업데이트
    func updateProfileInfo(nickname:String?, height:String?, weight:String?) {
        if let nickname = nickname {
            db.collection("users").document(loginInfo).setData(["nickname": nickname], merge: true)
        }
        
        if let height = height {
            let iHeight = Int(height)
            fetchRecentSurveyVer { ver in
                let docRef = self.db.collection("users").document(self.loginInfo)
                               .collection("survey").document("surveyDoc\(ver)")
                docRef.setData(["height": iHeight], merge: true)
            }
        }
        
        if let weight = weight {
            let iWeight = Int(weight)
            fetchRecentSurveyVer { ver in
                let docRef = self.db.collection("users").document(self.loginInfo)
                               .collection("survey").document("surveyDoc\(ver)")
                docRef.setData(["weight": iWeight], merge: true)
            }
        }
    }
    /// 프로필 이미지 저장
    func updateProfileImage(image: UIImage) {
        
    }

}


struct SurveyOne: Codable {
    var UpDown: String
    var UpDownWeight: Int
}

struct SurveyTwo: Codable {
    var age: Int
    var gender: Int
}

struct SurveyThree: Codable {
    var height: Int
    var weight: Int
}

struct SurveyFour: Codable {
    var place: String
    var level: Int
}


