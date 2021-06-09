//
//  LayerVisibilityButton.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit

class LayerVisibilityButton: UIButton {
    var isChosen = false {
        didSet {
            refreshView()
        }
    }
}

extension LayerVisibilityButton: SelectableView {
    func refreshView() {
        if isChosen {
            setImage(UIImage(systemName: "checkmark.square.fill"),
                     for: .normal)
        } else {
            setImage(UIImage(systemName: "checkmark.square"),
                     for: .normal)
        }
    }
}
