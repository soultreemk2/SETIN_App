//
//  PictureRecordViewController.swift
//  SlacksFitYang
//
//  Created by YANG on 2023/04/06.
//

import Foundation
import UIKit
import PhotosUI

class PictureRecordViewController: UIViewController,
                                   UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var challengeCnt = 0
    var indexCnt = 0
    var dateArr: Array<String> = [] // 시작일자, 끝일자
    var selectImgIndex = 0
    
    var mainLabel = UILabel()
    var subLabel = UILabel()
    
    // 버튼 클릭 시 1) 타이틀 변경 2) 컬렉션뷰 셀 업데이트
    lazy var beforeBtn: UIButton = {
        // 챌린지가 한개면 비활성화 & 회색버튼
        let button = UIButton()
        button.setImage(UIImage(named: "before.png"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var afterBtn: UIButton = {
        // 챌린지가 한개면 비활성화 & 회색버튼
        let button = UIButton()
        button.setImage(UIImage(named: "after.png"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // collectionView
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PictureCollectionViewCell.self, forCellWithReuseIdentifier: "pictureCell")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 카메라 접근 사용 권한 요청
        checkCameraPermission() // TO DO: 최종 배포 시 주석 해제
        
        // UI
        setupLabel()
        setupCollectionView()
    
        SurveyCommon.shared.fetchStartDate { dateStr in
            DispatchQueue.main.async {
                self.dateArr = self.calculateDate(startDate: dateStr)
                self.subLabel.attributedText = NSMutableAttributedString().regular(string: "\(self.dateArr[0]) ~ \(self.dateArr[1])", fontSize: 18)
                self.collectionView.reloadData()
            }
        }
        
    }
    // 설문조사 갔다가, 돌아온 경우 다시 fetch를 해와야 하므로 viewWillAper
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        SurveyCommon.shared.fetchRecordDocList { count in
            if (count == 0) { // 운동 기록이 없거나(설문O 기록X), 설문조사 부터 안된 경우
                let alerMsg = "설문조사를 먼저 완료하세요!\n\n설문조사를 완료한 경우라면, 운동 기록을 시작하세요"
                let actionSheet = UIAlertController(title: nil, message: alerMsg, preferredStyle: .alert)
                let moveAction = UIAlertAction(title: "확인", style: .default) { (_) in
                    self.navigationController?.pushViewController(TabBarController(), animated: true)
                }
                actionSheet.addAction(moveAction)
                self.parentViewController?.present(actionSheet, animated: true)
            }

            DispatchQueue.main.async {
                self.challengeCnt = count
                self.indexCnt = count
                self.mainLabel.attributedText = NSMutableAttributedString().regularBold(string: "\(count)번째 챌린지", fontSize: 20)
                self.beforeBtn.isEnabled = (self.indexCnt > 1)
            }
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if sender == beforeBtn { // 이전 버튼
            afterBtn.isEnabled = true
            self.indexCnt -= 1
        } else { // 다음 버튼
            self.indexCnt += 1
        }
        beforeBtn.isEnabled = (self.indexCnt > 1)
        afterBtn.isEnabled = !(self.indexCnt >= self.challengeCnt)
        // data update
        mainLabel.attributedText = NSMutableAttributedString().regularBold(string: "\(self.indexCnt)번째 챌린지", fontSize: 20)
        SurveyCommon.shared.fetchStartDate(ver: self.indexCnt) { dateStr in
            self.dateArr = self.calculateDate(startDate: dateStr)
            self.subLabel.attributedText = NSMutableAttributedString().regular(string: "\(self.dateArr[0]) ~ \(self.dateArr[1])", fontSize: 18)
            self.collectionView.reloadData()
        }
    }
}
    
extension PictureRecordViewController {
    // MARK: CollectionView Delegate, DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as! PictureCollectionViewCell
        
        let data = UserDefaults.standard.object(forKey: "exerciseRecordImage") as? Data
        
        if data == nil { // 저장한 사진이 없을 때 (첫 로딩 혹은 앱삭제 후 재설치)
            
            if self.dateArr.count > 0 { // 비동기로 값이 들어온 후에 실행되게끔 방어코드
                let dateAndComp = calculateEndDate(from: self.dateArr[0], day: indexPath.row)
                cell.setupDate(day: dateAndComp[0], dayOfWeek: dateAndComp[2])
                cell.pictureImgView.contentMode = .center
                if dateAndComp[1] == "T" {
                    cell.pictureImgView.image = UIImage(named: "plus_gray.png")
                    cell.pictureImgView.backgroundColor = .mainColor
                } else if dateAndComp[1] == "P" {
                    cell.pictureImgView.image = UIImage(named: "plus_gray.png")
                    cell.pictureImgView.backgroundColor = .cellColor
                } else {
                    cell.pictureImgView.image = UIImage(named: "fire_gray.png")
                    cell.pictureImgView.backgroundColor = .cellColor
                }
            }
        } else {  // 저장한 사진이 있을 때
            if let decodeData = try? JSONDecoder().decode([imageInfo].self, from: data!) {
                for items in decodeData {
                    // 저장된 이미지 중에 해당 cell 일자의 이미지가 존재하는 경우
                    if (items.projNum == self.indexCnt) && (items.imgNum == indexPath.row) {
                        cell.pictureImgView.contentMode = .scaleAspectFit
                        cell.pictureImgView.image = UIImage(data: items.imgData) ?? UIImage()
                    }
                }
                
                if self.dateArr.count > 0 { // 비동기로 값이 들어온 후에 실행되게끔 방어코드
                    let dateAndComp = calculateEndDate(from: self.dateArr[0], day: indexPath.row)
                    cell.setupDate(day: dateAndComp[0], dayOfWeek: dateAndComp[2])
                    // 사진 배정이 안된 경우 (해당 일자에 사진이 없을 때 - 기본 이미지)
                    if (cell.pictureImgView.image == nil) {
                        cell.pictureImgView.contentMode = .center
                        if dateAndComp[1] == "T" {
                            cell.pictureImgView.image = UIImage(named: "plus_gray.png")
                            cell.pictureImgView.backgroundColor = .mainColor
                        } else if dateAndComp[1] == "P" {
                            cell.pictureImgView.image = UIImage(named: "plus_gray.png")
                            cell.pictureImgView.backgroundColor = .cellColor
                        } else {
                            cell.pictureImgView.image = UIImage(named: "fire_gray.png")
                            cell.pictureImgView.backgroundColor = .cellColor
                        }
                    }
                }
            }
        }
        
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectImgIndex = indexPath.row
        let dateAndComp = calculateEndDate(from: self.dateArr[0], day: indexPath.row)
        if dateAndComp[1] != "F" {
            setupPictureSelectView()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        let numberOfCells:CGFloat = 3 // 한 줄에 보여주고 싶은 셀 개수
        let width = collectionView.frame.size.width - (flowLayout.minimumInteritemSpacing * (numberOfCells-1))
        return CGSize(width: width/numberOfCells, height: width/numberOfCells)
    }
    
    
    // MARK: Custom Method
    
    func setupLabel() {
        [mainLabel, subLabel, beforeBtn, afterBtn].forEach { view.addSubview($0) }
        mainLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
            
        }
        subLabel.snp.makeConstraints {
            $0.top.equalTo(mainLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        beforeBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(20)
        }
        afterBtn.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(20)
        }
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(getTabBarHeight())
        }
    }
    
    func setupPictureSelectView() {
        var conf = PHPickerConfiguration()
        conf.selectionLimit = 1
        conf.filter = .any(of: [.images])

        let picker = PHPickerViewController(configuration: conf)
        picker.delegate = self
        self.parentViewController?.present(picker, animated: true)
    }
    
    // 프로젝트 시작일로부터 끝나는 일자,요일 구하기 + 시작일 포맷 변경
    func calculateDate(startDate: String) -> Array<String> {
        let fmt = DateFormatter()
        let fmt2 = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt2.dateFormat = "yy.MM.dd"
        
        let strToDate = fmt.date(from: startDate) ?? Date()
        let dateComp = Calendar.current.dateComponents([.year,.month,.day], from: strToDate)
        let compToDate = Calendar(identifier: .gregorian).date(from: dateComp)
        let finalDate = Calendar.current.date(byAdding: .day, value: 13, to: compToDate!) // 시작일로부터 14일 더하기
        
        let startDateStr = fmt2.string(from: strToDate)
        let endDateStr = fmt2.string(from: finalDate!)
        
        return [startDateStr, endDateStr]
    }
    
    // 프로젝트 시작일로부터 n일 이후 일자 (1~13일), 요일
    func calculateEndDate(from: String, day: Int) -> Array<String> {
        let fmt = DateFormatter()
        let fmt2 = DateFormatter()
        fmt.dateFormat = "yy.MM.dd"
        fmt2.dateFormat = "EEEEEE" // 요일
        fmt2.locale = Locale(identifier:"ko_KR")
        
        let todayDate = fmt.date(from: fmt.string(from: Date()))
        let fromDate = fmt.date(from: from) ?? Date()
        let dateComp = Calendar.current.dateComponents([.year,.month,.day], from: fromDate)
        let compToDate = Calendar(identifier: .gregorian).date(from: dateComp)
        let endDate = Calendar.current.date(byAdding: .day, value: day, to: compToDate!) // 시작일로부터 14일 더하기
        let endDateStr = fmt.string(from: endDate!)
        
        // 오늘(T), 지난날(P), 미래(F)
        var compResult = ""
        switch endDate?.compare(todayDate!) {
        case .orderedSame:
            compResult = "T"
        case .orderedAscending:
            compResult = "P"
        case .orderedDescending:
            compResult = "F"
        default:
            break
        }
        
        let dayOfWeek = fmt2.string(from: endDate!)
        
        return [String(endDateStr.suffix(2)), compResult, dayOfWeek]
    }
    
    func checkCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
           if granted {
               print("Camera: 권한 허용")
           } else {
               DispatchQueue.main.async {
                   let actionSheet = UIAlertController(title: "", message: "앨범 접근 권한을 거부하여 사진 기록이 불가합니다.", preferredStyle: .alert)
                   let cancleAction = UIAlertAction(title: "닫기", style: .cancel) { (_) in
                       self.navigationController?.pushViewController(TabBarController(), animated: true)
                   }
                   let moveAction = UIAlertAction(title: "권한 설정하기", style:.default) { (_) in
                       guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

                       if UIApplication.shared.canOpenURL(url) {
                           UIApplication.shared.open(url)
                       }
                   }
                   
                   actionSheet.addAction(cancleAction)
                   actionSheet.addAction(moveAction)
                   self.parentViewController?.present(actionSheet, animated: true)
               }
           }
       })
    }
}

// MARK: PHPickerViewController Delegate
extension PictureRecordViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { img, error in
                // 이미지 userDefault 저장
                let image = img as! UIImage
                let imageData = image.jpegData(compressionQuality: 1.0)
                let selectedImg = imageInfo(projNum: self.indexCnt, imgNum: self.selectImgIndex, imgData: imageData)
                // 구조체에 저장
//                var imgArr: [imageInfo] = [] // 전역변수에 할당하고 self로 가져오면.. 앱 재실행시마다 전역변수 참조되어 빈 배열로 초기화됨..
                                               // 이렇게 해도 마찬가지임 (picking 끝날때마다 초기화됨)

                var newArray = [imageInfo]()
                //1.this is protected cannot update directly
                let imgDataArr = UserDefaults.standard.object(forKey: "exerciseRecordImage") as? Data ?? Data()
                
                if let decodedArr = try? JSONDecoder().decode([imageInfo].self, from: imgDataArr) {
                    newArray = decodedArr  // 2. just copying the value here
                }
                newArray.append(selectedImg) // 3. appending the new value
                
                if let encodedImgArr = try? JSONEncoder().encode(newArray) {
                    UserDefaults.standard.set(encodedImgArr, forKey: "exerciseRecordImage")
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        } else {
            print("이미지 못불러옴")
        }
        
    }
}
