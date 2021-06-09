//
//  ShotDesignerButton.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//
import UIKit
protocol ShotDesignerButton: UIBarButtonItem, SelectableView {
}

extension ShotDesignerButton {
    func refreshView() {
        if isChosen {
            tintColor = .orange
        } else {
            tintColor = .systemBlue
        }
    }
}
