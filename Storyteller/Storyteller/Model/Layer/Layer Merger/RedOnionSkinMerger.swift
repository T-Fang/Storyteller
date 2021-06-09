//
//  RedOnionSkinMerger.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//
import UIKit

class RedOnionSkinMerger: ImageMerger {

    override func mergeDrawing(component: DrawingComponent) -> UIImage {
        let drawing = component.drawing.redOnionSkin
        let canvasSize = component.canvasSize
        guard !(drawing.bounds.isEmpty || drawing.bounds.isInfinite) else {
            return UIImage.solidImage(ofColor: .clear, ofSize: canvasSize)
        }
        return drawing.image(from: canvasSize.rectAtOrigin, scale: 0.5)
    }
}
