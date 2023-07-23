//
//  SurveyButton.swift
//  SlacksFit
//
//  Created by YANG on 2022/09/28.
//

import UIKit

class SurveyButton: UIButton {
    
    var buttonTitle: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        backgroundColor = .gray
        layer.cornerRadius = 15
//        setImage(UIImage(named: "grey_button"), for: .normal)
//        setImage(UIImage(named: "blue_button"), for: .highlighted)
    }
    
    convenience init (buttonTitle: String) {
        self.init()
        self.buttonTitle = buttonTitle
        setTitle(self.buttonTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .blue : .gray
        }
    }
}
