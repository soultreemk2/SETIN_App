//
//  PaddingLabel.swift
//  SlacksFit
//
//  Created by YANG on 2022/10/19.
//

import UIKit

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
