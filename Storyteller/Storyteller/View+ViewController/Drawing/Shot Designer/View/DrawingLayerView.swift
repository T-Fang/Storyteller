//
//  DrawingLayerView.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import PencilKit

class DrawingLayerView: UIView {
    var toolPicker: PKToolPicker?

    var isLocked: Bool {
        didSet {
            updateLockEffect()
        }
    }

    var isVisible: Bool {
        didSet {
            isHidden = !isVisible
        }
    }
    private(set) var canvasView: PKCanvasView

    init(drawing: PKDrawing, canvasSize: CGSize,
         isLocked: Bool = false, isVisible: Bool = true) {
        let frame = canvasSize.rectAtOrigin
        canvasView = PKCanvasView(frame: frame)
        canvasView.drawing = drawing
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false

        self.isLocked = isLocked
        self.isVisible = isVisible
        super.init(frame: frame)

        addSubview(canvasView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawingLayerView: LayerView {
    func transform(using transform: CGAffineTransform) {
        canvasView.drawing.transform(using: transform)
    }
    var topCanvasView: PKCanvasView? {
        canvasView
    }
    func duplicate() -> LayerView {
        let copy = DrawingLayerView(drawing: canvasView.drawing, canvasSize: bounds.size,
                                    isLocked: isLocked, isVisible: isVisible)
        guard let toolPicker = toolPicker, let delegate = canvasView.delegate else {
            return copy
        }
        copy.setUpPK(toolPicker: toolPicker, PKDelegate: delegate)
        return copy
    }
}
extension DrawingLayerView {
    override var canBecomeFirstResponder: Bool {
        true
    }
}
