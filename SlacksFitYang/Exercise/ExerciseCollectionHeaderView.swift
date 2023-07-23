//
//  ExerciseCollectionHeaderView.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/05.
//

import UIKit
import SnapKit

final class ExerciseCollectionHeaderView: UICollectionReusableView {
    var userNickName: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dumbelImgView: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "dumbbell_5.png"))
        imgView.frame.size.width = 78
        imgView.frame.size.height = 55
        
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 2
        rotation.duration = 2 // 1바퀴 도는데 걸리는 시간
        rotation.isCumulative = true
        rotation.repeatCount = 2 // 몇번 반복 할것인가

        imgView.layer.add(rotation, forKey: "rotationAnimation") // 원하는 뷰에 애니메이션 삽입
        
        return imgView
    }()
    
    private lazy var titleLbl: UILabel = {
        let titleLabel = UILabel()
         titleLabel.numberOfLines = 2

        // 사용자 이름 가져오기
        FirebaseLoginInfo.shared.getUserNickname { nickname in
            self.userNickName = nickname
            // UI Update
            titleLabel.attributedText = NSMutableAttributedString()
                .bold(string: self.userNickName)
                .regular(string: " 님의 \n 오늘 챌린지는 ", fontSize: 14)
                .bold(string: "7가지 ")
                .regular(string: "입니다.", fontSize: 14)
        }
        
        //print("함수: 클로저로 받은 인자값 활용") -> 여기 먼저 실행 되고 위에 클로저가 실행됨. 따라서 클로저 내에서 ui업데이트 해야함
    
        return titleLabel
    }()
    
    func setupViews() {
        [dumbelImgView, titleLbl].forEach{ addSubview($0) }
        
        dumbelImgView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(50)
        }
        titleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(dumbelImgView.snp.bottom).offset(10)
        }
    }
}


extension NSMutableAttributedString {
    
    /// mainColor, bold, fontSize:20
    func bold(string: String) -> NSMutableAttributedString {
        let font = UIFont.boldSystemFont(ofSize: 20)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.mainColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    func bold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.mainColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    /// mainColor, regular
    func mainRegular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.mainColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    /// grayColor, regular
    func regular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.grayColor]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    /// black, bold
    func regularBold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    /// white, bold
    func whiteBold(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
        self.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }
    
    /*
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }


    func blackHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func underlined(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font: normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
     */
}
