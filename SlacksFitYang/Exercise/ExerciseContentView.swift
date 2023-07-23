//
//  ExerciseContentView.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/19.
//

// 재사용 할 기본 뷰 (exercise detail content)
import UIKit
import SnapKit
import AVKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Photos
import YoutubePlayer_in_WKWebView

class ExerciseContentView: UIViewController {
    var index: Int! // detailVC에서 넘어올때 index
    var selectedDate: Int = 0
    var maxSetCount: String = ""
    var setCounting: Int = 0 // setRecordCollection 클릭 시 저장
    var startTime: Float = 0
    var endTime: Int = 100000
    var recordBtnEnabled = true
    
    // 운동 기록 send
    var weightRecord: Int = 0 {
        didSet {
            weightLbl.text = "\(weightRecord)kg"
        }
    }
    var countRecord: Int = 0 {
        didSet {
            countLbl.text = "\(countRecord)ea"
        }
    }
    
    var exerciseType: String? // 운동 유형 (세트 기록 여부)
    var exerciseVideoView = WKYTPlayerView()
    
    lazy var exerciseTitle: UILabel = {
       let title = UILabel()
       title.textAlignment = .center
        title.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
       return title
    }()
    
    lazy var segmentBar: UIView = {
       let view = UIView()
        view.backgroundColor = .grayColor
        return view
    }()
    
    lazy var setRecordCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0 // cell 사이 간 간격 삭제
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // cell 등록
        collectionView.register(RecordingCollectionViewCell.self, forCellWithReuseIdentifier: "recordingCell")
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.cornerRadius = 10
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        
        return collectionView
    }()
    
    /* ----- 하나의 stackView ----- */
    struct minusBtn {
        lazy var button: UIButton = {
            let btn = UIButton()
            btn.layer.cornerRadius = 7
            btn.backgroundColor = .cellColor
            btn.setTitleColor(UIColor.grayColor, for: .normal)
            btn.setTitle("-", for: .normal)
            return btn
        }()
    }
    
    struct plusBtn {
        lazy var button: UIButton = {
            let btn = UIButton()
            btn.layer.cornerRadius = 7
            btn.backgroundColor = .cellColor
            btn.setTitleColor(UIColor.grayColor, for: .normal)
            btn.setTitle("+", for: .normal)
            return btn
        }()
    }
    
    private lazy var weightLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var weightTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.black
        label.text = "무게"
        label.textAlignment = .center
        return label
    }()

    private lazy var countLbl: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var countTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.black
        label.text = "횟수" // 마지막으로 기록한 상태 표시
        label.textAlignment = .center
        return label
    }()
    
    private lazy var guideView: UILabel = {
        var text = "가능한 많은 셋트를 반복하고, 기록하세요!"
        
       let label = UILabel()
        label.backgroundColor = .guideViewColor
        label.layer.cornerRadius = 6
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "fire")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: text))
        label.textAlignment = .center
        label.attributedText = attributedString
        label.sizeToFit()
        
        return label
    }()

    var minusBtn = minusBtn()
    var minusBtn2 = minusBtn()
    var plusBtn = plusBtn()
    var plusBtn2 = plusBtn()
    
    /* -------------------------- */
    
    private lazy var recordStackView: UIStackView = {
        // plus, minus 버튼은 재활용이 불가한가...? 왜 꼭 두개씩 만들어줘야 하는 이유가? 엄청 삽질했네..
        self.minusBtn.button.tag = 1
        self.plusBtn.button.tag = 2
        self.minusBtn2.button.tag = 3
        self.plusBtn2.button.tag = 4
        
        let hStack1 = UIStackView(arrangedSubviews: [self.minusBtn.button, weightLbl, self.plusBtn.button])
        hStack1.axis = .horizontal
        hStack1.distribution = .equalSpacing
        hStack1.spacing = 5
        
        let vStack1 = UIStackView(arrangedSubviews: [weightTitle, hStack1])
        vStack1.axis = .vertical
        
        let hStack2 = UIStackView(arrangedSubviews: [minusBtn2.button, countLbl, plusBtn2.button])
        hStack2.axis = .horizontal
        hStack2.distribution = .equalSpacing
        hStack2.spacing = 5
        
        let vStack2 = UIStackView(arrangedSubviews: [countTitle, hStack2])
        vStack2.axis = .vertical
        
        let stack = UIStackView(arrangedSubviews: [vStack1, vStack2])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 5
        stack.backgroundColor = .white
        
        return stack
    }()
    
    private lazy var completeStackView: UIStackView = {
        let imgView = UIImageView(image: UIImage(named: "dumbell_4.png"))
        imgView.contentMode = .scaleAspectFit
        let title = UILabel()
        title.text = "세트완료"
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title.textColor = UIColor.black
        title.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [imgView, title])
        stack.backgroundColor = .white
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()
    
    
    var RecordBtn: UIButton = {
        let btn = UIButton()
        var isFinal: Bool = false;
        btn.titleLabel?.font = .systemFont(ofSize: 13.0, weight:.bold)
//        btn.backgroundColor = .mainColor
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 7
        btn.setTitle("완료 후 클릭", for: .normal)
        btn.tag = 5
        return btn
    }()
    
    // MARK: View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        RecordBtn.isEnabled = recordBtnEnabled
        RecordBtn.backgroundColor = recordBtnEnabled ? .mainColor : .grayColor

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // 영상 재생
        exerciseVideoView.delegate = self
        // cell 첫 로딩 시, 사용자가 기록한 가장 큰 셋트 수에 대한 기록 로딩
        ExerciseCommon.shared.fetchSetCountByExerc(day: selectedDate, index: index, update: false) { SetOrCount in
            // 운동 횟수 가이드 가져오기
            ExerciseCommon.shared.fetchExerciseListByDate(day: self.selectedDate) { exerciseDayTotal in
                let exerciseInfo = exerciseDayTotal["운동\(self.index+1)"] as? [String: String]
                let guideCount = exerciseInfo?["guide"] as? String ?? ""
                
                if SetOrCount[0] == "setCount" { // 세트 기록이 존재할때만
                    let maxSetCountIdx = IndexPath(item: Int(SetOrCount[1])!-1, section: 0)
                    self.setRecordCollection.scrollToItem(at: maxSetCountIdx,
                                                          at: .centeredHorizontally, animated: false)
                    self.setRecordCollection.selectItem(at: maxSetCountIdx,
                                                        animated: false, scrollPosition: .init())
                }
                
                // 해당 셋트 기록 로딩
                if SetOrCount[0] == "onlyCount" { // 세트를 기록하지 않는 경우
                    ExerciseCommon.shared.fetchWeightCountBySet(day: self.selectedDate, index: self.index, setNum: 0) { setWeightCount in
                        
                        if setWeightCount == [0,0] { // 저장된 운동기록이 없는 경우
                            self.weightRecord = 0
                            self.countRecord = Int(guideCount) ?? 0
                        } else {
                            let weight = setWeightCount[0]
                            let count = setWeightCount[1]
                            self.weightRecord = weight
                            self.countRecord = count
                        }
                    }
                } else {
                    ExerciseCommon.shared.fetchWeightCountBySet(day: self.selectedDate, index: self.index, setNum: Int(SetOrCount[1])!) { setWeightCount in
                        let weight = setWeightCount[0]
                        let count = setWeightCount[1]
                        self.weightRecord = weight
                        self.countRecord = count
                    }
                }
            }
        }
    }

    // MARK: button
    @objc func buttonTapped(_ sender: UIButton ) {
        switch sender.tag {
        case 1:
            weightRecord -= 1
            (weightRecord <= 0) ? (sender.isEnabled = false) : (sender.isEnabled = true)
        case 2:
            weightRecord += 1
        case 3:
            countRecord -= 1
            (countRecord <= 0) ? (sender.isEnabled = false) : (sender.isEnabled = true)
        case 4:
            countRecord += 1
            
        case 5: // 세트완료 후 클릭
            if !recordBtnEnabled {
                let alert = UIAlertController(title: nil, message: "오늘 날짜만 기록 가능합니다!", preferredStyle: .alert)
                let cancleAction = UIAlertAction(title: "닫기", style: .cancel)
                alert.addAction(cancleAction)
                self.parentViewController?.present(alert, animated: true)
                return
            }
            
            let alert = UIAlertController(title: nil, message: "저장되었습니다.", preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: "닫기", style: .cancel)
            alert.addAction(cancleAction)
            self.parentViewController?.present(alert, animated: true)
            
            ExerciseCommon.shared.sendWeightCountBySet(day:selectedDate, index: index,
                                                       setNum: setCounting, weight: weightRecord,
                                                       counting: countRecord)
            if setCounting == 9 {
                RecordBtn.tag = 6
                RecordBtn.setTitle("완료된 셋트 리셋하기", for: .normal)
                self.view.bringSubviewToFront(self.completeStackView)
                
            } else {
                RecordBtn.tag = 5
            }
        break

        case 6: // 완료된 셋트 리셋
            ExerciseCommon.shared.deleteRecordingBySet(day: selectedDate, index: index, setNum: setCounting)
            self.view.sendSubviewToBack(self.completeStackView)
            
        default:
            break
        }
    }
}

// MARK: CollectionView Delegate
extension ExerciseContentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TO DO: 운동 종목에 따라..
//        var settingCnt = 0
//        if exerciseType != nil {
//            if exerciseType == "onlyCounting" {
//                settingCnt = 0
//            } else if exerciseType == "setCounting" {
//                settingCnt = 10
//            }
//        }
//        return settingCnt
        return 10
    }
    
    // cell 등록
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recordingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "recordingCell", for: indexPath) as! RecordingCollectionViewCell
        
        recordingCell.setup(count: indexPath.row)
       
        return recordingCell
    }
}

extension ExerciseContentView: UICollectionViewDelegateFlowLayout {
    // cell 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 61, height: 35)
    }

    // cell 클릭 시
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setCounting = indexPath.row + 1 // 현재 기록할 셋트 수
        // 해당 셋트에 대한 운동기록 로딩
        ExerciseCommon.shared.fetchWeightCountBySet(day: selectedDate, index: index, setNum: setCounting) { (setWeightCount) in
            let weight = setWeightCount[0]
            let counting = setWeightCount[1]
            self.weightRecord = weight
            self.countRecord = counting
        }
        
        // 스크롤 중앙에 오도록
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if !(setCounting == 9) {
            RecordBtn.setTitle("셋트 완료 후 클릭", for: .normal)
            RecordBtn.tag = 5
            self.view.sendSubviewToBack(self.completeStackView)
        }
    }
}

// MARK: YouTube Player Delegate
extension ExerciseContentView: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        exerciseVideoView.playVideo()
        exerciseVideoView.seek(toSeconds: startTime, allowSeekAhead: true)
    }
    
    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        if (Int(playTime) >= endTime) {
            exerciseVideoView.stopVideo()
            exerciseVideoView.seek(toSeconds: startTime, allowSeekAhead: true)
        }
    }
}

// MARK: Private Extension
extension ExerciseContentView {
    func setupDefaultView() {
        [self.minusBtn.button, self.plusBtn.button, minusBtn2.button, plusBtn2.button, RecordBtn].forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        // Default
        [exerciseVideoView, exerciseTitle, segmentBar].forEach { view.addSubview($0) }
        
        exerciseVideoView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        exerciseTitle.snp.makeConstraints {
            $0.top.equalTo(exerciseVideoView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(30)
            $0.height.equalTo(30)
        }
        
        segmentBar.snp.makeConstraints {
            $0.top.equalTo(exerciseTitle.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(3)
        }
        
        // 운동 유형에 따라 뷰 달라짐
        if exerciseType == "setCounting" {
            [setRecordCollection].forEach { view.addSubview($0)}
            
            setRecordCollection.snp.makeConstraints {
                $0.top.equalTo(segmentBar.snp.bottom).offset(40)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.height.equalTo(35)
            }
        }
    }
    
    func setupRecordStack() {
        [completeStackView, recordStackView, RecordBtn].forEach { view.addSubview($0) }
        
        // 운동 유형에 따라 레이아웃이 달라짐
        if exerciseType == "setCounting" {
            view.addSubview(guideView)
            completeStackView.snp.makeConstraints {
                $0.top.equalTo(setRecordCollection.snp.bottom).offset(30)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
            recordStackView.snp.makeConstraints {
                $0.top.equalTo(setRecordCollection.snp.bottom).offset(30)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
            guideView.snp.makeConstraints {
                $0.top.equalTo(recordStackView.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.height.equalTo(40)
            }
            RecordBtn.snp.makeConstraints {
                $0.top.equalTo(guideView.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.bottom.equalToSuperview().inset(15)
                $0.height.equalTo(50)
            }
            
        } else {
            completeStackView.snp.makeConstraints {
                $0.top.equalTo(segmentBar.snp.bottom).offset(30)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
            }
            recordStackView.snp.makeConstraints {
                $0.top.equalTo(segmentBar.snp.bottom).offset(30)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.height.equalTo(70)
            }
            RecordBtn.snp.makeConstraints {
                $0.top.equalTo(recordStackView.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(30)
                $0.trailing.equalToSuperview().inset(30)
                $0.bottom.equalToSuperview().inset(15)
                $0.height.equalTo(50)
            }
        }
    }

}

/*
final class videoControlView: UIView {
    var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "play.png"), for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .yellow
        self.addSubview(playBtn)
        playBtn.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(100)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 */


//    override func viewDidLayoutSubviews() {
//        // cell 첫 로딩 시, 사용자가 기록한 가장 큰 셋트 수에 대한 기록 로딩
//        // 버그... 값 바꾼 후에 셋트완료 버튼 클릭하면 왜 얘가 호출이 되는건지.. --> addSnapshot이라 그랬음...
//        ExerciseCommon.shared.fetchSetCountByExerc(day: selectedDate, index: index) { maxSetCount_str in
//            let maxSetCountIdx = IndexPath(item: Int(maxSetCount_str)!, section: 0)
//            self.setRecordCollection.scrollToItem(at: maxSetCountIdx,
//                                                  at: .centeredHorizontally, animated: false)
//            self.setRecordCollection.selectItem(at: maxSetCountIdx,
//                                                animated: false, scrollPosition: .init())
//            // 해당 셋트 기록 로딩
//            ExerciseCommon.shared.fetchWeightCountBySet(day: self.selectedDate, index: self.index, setNum: Int(maxSetCount_str)!) { setWeightCount in
//                let weight = setWeightCount[0]
//                let count = setWeightCount[1]
//                self.weightRecord = weight
//                self.countRecord = count
//            }
//        }
//    }
