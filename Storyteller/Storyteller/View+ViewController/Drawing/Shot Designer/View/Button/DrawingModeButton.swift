//
//  DrawingModeButton.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//
import UIKit

class DrawingModeButton: UIBarButtonItem {
    var isChosen = false {
        didSet {
            refreshView()
        }
    }
}

extension DrawingModeButton: ShotDesignerButton {
}
