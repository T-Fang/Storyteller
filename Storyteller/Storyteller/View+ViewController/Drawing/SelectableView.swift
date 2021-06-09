//
//  SelectableView.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

protocol SelectableView {
    var isChosen: Bool { get set }

    func refreshView()
}

extension SelectableView {
    mutating func select() {
        isChosen = true
        refreshView()
    }

    mutating func deselect() {
        isChosen = false
        refreshView()
    }
}
