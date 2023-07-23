//
//  CommonUI.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/28.
//

import UIKit

/// 설문조사 common Button
class SurveyButton: UIButton {
    
    var buttonTitle: String = ""
    var config = UIButton.Configuration.filled()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = 7
        self.configuration = config
        
    }
    
    convenience init (buttonTitle: String) {
        self.init()
        self.buttonTitle = buttonTitle
        config.contentInsets = NSDirectionalEdgeInsets.init(top: 10, leading: 10, bottom: 10, trailing: 10)
        config.baseBackgroundColor = .lightGray
        config.title = self.buttonTitle
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            config.background.backgroundColor = isSelected ? .mainColor : .lightGray
            self.configuration = config
        }
    }
}

class mainTitle: UILabel {
    var title: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        numberOfLines = 0
        lineBreakMode = .byWordWrapping // 화면 사이즈에 따라 자동으로 줄바꿈 해줌 (텍스트 짤림현상 해결)
    }
    convenience init (title: String) {
        self.init()
        self.title = title
        attributedText = NSMutableAttributedString().bold(string: self.title, fontSize: 17)
        self.adjustsFontForContentSizeCategory = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class subTitle: UILabel {
    var title: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        numberOfLines = 2
    }
    convenience init (title: String) {
        self.init()
        self.title = title
        attributedText = NSMutableAttributedString().regular(string: title, fontSize: 15)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// +, - 버튼
class upDownButton: UIButton {
    var buttonTitle: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        layer.cornerRadius = 7
        backgroundColor = .cellColor
        setTitleColor(UIColor.mainColor, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    }
    convenience init (buttonTitle: String) {
        self.init()
        self.buttonTitle = buttonTitle
        setTitle(self.buttonTitle, for: .normal)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//--------------------------------------------------------------------------------------------//

/// 상하좌우 여백이 있는 textField
class TextFieldWithPadding: UITextField, UITextFieldDelegate {
    var textPadding = UIEdgeInsets(
        top: 15,
        left: 0,
        bottom: 15,
        right: 20
    )
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

class commonLabel: UILabel {
    var title: String = ""
    var content: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
    }
    
    convenience init (title: String, content: String) {
        self.init()
        self.title = title
        self.content = content
        
        self.attributedText = NSMutableAttributedString().regular(string: "\(title)   |   ", fontSize: 17)
            .regularBold(string: content, fontSize: 17)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PaddingLabel: UILabel {
    var topInset = 5.0
    var bottomInset = 5.0
    var leftInset = 13.0
    var rightInset = 13.0
    
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet { preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)}
    }
}

public func getTabBarHeight() -> Int {
    var tabBarHeight = 0
    // window는 OS 13.0 이상에서만 작동. 이외의 경우 그냥 50으로 고정시킴
    guard let window = UIApplication.shared.keyWindow else { return 50 }
    if window.safeAreaInsets.bottom > 0 { // 버튼 없는 기종 (아이폰X 이후)
        tabBarHeight = 85 // 탭바 높이 83
    } else { // 하단 버튼 있는 기종 (아이폰X 이전)
        tabBarHeight = 51 // 탭바 높이 49
    }
    
    return tabBarHeight
}
