//
//  GreenOnionSkinMerger.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import UIKit

class GreenOnionSkinMerger: ImageMerger {

    override func mergeDrawing(component: DrawingComponent) -> UIImage {
        let drawing = component.drawing.greenOnionSkin
        let canvasSize = component.canvasSize
        guard !(drawing.bounds.isEmpty || drawing.bounds.isInfinite) else {
            return UIImage.solidImage(ofColor: .clear, ofSize: canvasSize)
        }
        return drawing.image(from: canvasSize.rectAtOrigin, scale: 0.5)
    }
}
