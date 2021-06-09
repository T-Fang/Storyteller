//
//  TransformLayerButton.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

class TransformLayerButton: UIBarButtonItem {
    var isChosen = false {
        didSet {
            refreshView()
        }
    }
}

extension TransformLayerButton: ShotDesignerButton {
}
