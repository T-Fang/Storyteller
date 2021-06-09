//
//  LayerView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import PencilKit

protocol LayerView: UIView {
    var toolPicker: PKToolPicker? { get set }
    var isLocked: Bool { get set }
    var isVisible: Bool { get set }
    var topCanvasView: PKCanvasView? { get }
    func transform(using transform: CGAffineTransform)
    func duplicate() -> LayerView
}

extension LayerView {
    func setUpPK(toolPicker: PKToolPicker, PKDelegate: PKCanvasViewDelegate) {
        self.toolPicker = toolPicker
        guard let canvasView = topCanvasView else {
            return
        }
        canvasView.delegate = PKDelegate
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
    }
    func updateLockEffect() {
        guard let canvasView = topCanvasView else {
            return
        }
        if isLocked {
            toolPicker?.setVisible(false, forFirstResponder: canvasView)
        }
    }
}
