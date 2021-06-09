//
//  LayerLockButton.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit

class LayerLockButton: UIButton {
    var isChosen = false {
        didSet {
            refreshView()
        }
    }
}

extension LayerLockButton: SelectableView {
    func refreshView() {
        if isChosen {
            setImage(UIImage(systemName: "lock.square.fill"), for: .normal)
        } else {
            setImage(UIImage(systemName: "lock.square"), for: .normal)
        }
    }
}
