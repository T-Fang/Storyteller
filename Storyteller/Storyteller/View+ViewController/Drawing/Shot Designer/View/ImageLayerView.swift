//
//  ImageLayerView.swift
//  Storyteller
//
//  Created by TFang on 17/4/21.
//

import PencilKit

class ImageLayerView: UIImageView {
    var toolPicker: PKToolPicker?

    var isLocked: Bool
    var isVisible: Bool {
        didSet {
            isHidden = !isVisible
        }
    }

    init(canvasSize: CGSize, image: UIImage,
         isLocked: Bool = false, isVisible: Bool = true) {
        self.isLocked = isLocked
        self.isVisible = isVisible

        super.init(image: image)
        self.frame = canvasSize.rectAtOrigin
        contentMode = .scaleAspectFit
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageLayerView: LayerView {
    func transform(using transform: CGAffineTransform) {
        self.transform = self.transform.concatenating(transform)
    }
    var topCanvasView: PKCanvasView? {
        nil
    }
    func duplicate() -> LayerView {
        ImageLayerView(canvasSize: bounds.size, image: image ?? UIImage(),
                       isLocked: isLocked, isVisible: isVisible)
    }
}
extension ImageLayerView {
    override var canBecomeFirstResponder: Bool {
        true
    }
}
