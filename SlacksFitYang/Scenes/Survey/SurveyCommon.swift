//
//  SurveyCommon.swift
//  SlacksFit
//
//  Created by YANG on 2022/11/28.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

class SurveyCommon {
    static let shared = SurveyCommon()
    
    let db = Firestore.firestore()
    let loginInfo = FirebaseLoginInfo.shared.getCurrentUserInfo()

    func SurveyOneDataStore(data: SurveyOne) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(from: data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func SurveyTwoDataStore(data: SurveyTwo) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(from: data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func SurveyThreeDataStore(data: SurveyThree) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(from: data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    
    func SurveyFourDataStore(data: SurveyFour) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(from: data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func SurveyDataStore(data: [String: Any]) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func ExerciseDataStore(data: [String: Any]) {
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                       .collection("survey").document("surveyDoc\(surveyVer)")
        do {
            try docRef.setData(data, merge: true)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
    }
    
    func fetchStartDate(completion: @escaping(String) -> Void) {
        // string을 가져옴
        let surveyVer = fetchRecentSurveyVer()+1
        let docRef = db.collection("users").document(loginInfo)
                        .collection("survey").document("surveyDoc\(surveyVer)")
        docRef.getDocument { document, error in
            if let error = error {
                print("error: ", error)
            } else if let document = document, document.exists {
                let data = document.data()
                let dateStr = data?["projStartDate"] as! String
                completion(dateStr)
            }
        }
    }
    // 진행한 설문조사 리스트 (프로젝트 수) > 내림차순 정렬 [4,3,2,1]
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
    
    // 가장 최근의 프로젝트(설문조사) 버전
    func fetchRecentSurveyVer() -> Int {
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
            if surveyNumArr.count == 0 { maxSurveyVer = 1 } else { maxSurveyVer = Int(surveyNumArr[0])! }
        }
        return maxSurveyVer
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


