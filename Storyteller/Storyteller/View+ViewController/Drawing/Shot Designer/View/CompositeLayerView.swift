//
//  CompositeLayerView.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import PencilKit
class CompositeLayerView: UIView {
    private(set) var children: [LayerView]
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

    init(canvasSize: CGSize, children: [LayerView] = [],
         isLocked: Bool = false, isVisible: Bool = true) {
        let frame = canvasSize.rectAtOrigin
        self.children = children
        self.isLocked = isLocked
        self.isVisible = isVisible
        super.init(frame: frame)

        children.forEach({ addSubview($0) })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CompositeLayerView: LayerView {
    func transform(using transform: CGAffineTransform) {
        children.forEach({ $0.transform(using: transform) })
    }

    var topCanvasView: PKCanvasView? {
        children.compactMap({ $0.topCanvasView }).last
    }
    func duplicate() -> LayerView {
        CompositeLayerView(canvasSize: bounds.size,
                           children: children.map({ $0.duplicate() }),
                           isLocked: isLocked, isVisible: isVisible)
    }
}

extension CompositeLayerView {
    override var canBecomeFirstResponder: Bool {
        true
    }
}
