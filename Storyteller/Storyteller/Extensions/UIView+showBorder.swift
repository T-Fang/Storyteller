//
//  UIView+showBorder.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit

extension UIView {
    func showBorder() {
        layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        layer.borderWidth = Constants.layerBorderWidth
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
//        layer.shadowOffset = .zero
//        layer.shadowRadius = 10
    }
    func hideBorder() {
//        layer.shadowOpacity = 0
        layer.borderWidth = 0
    }
}
