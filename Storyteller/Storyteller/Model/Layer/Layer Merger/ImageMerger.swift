//
//  ImageMerger.swift
//  Storyteller
//
//  Created by TFang on 3/4/21.
//

import UIKit

class ImageMerger: LayerMerger {

    func mergeDrawing(component: DrawingComponent) -> UIImage {
        let drawing = component.drawing
        let canvasSize = component.canvasSize
        guard !(drawing.bounds.isEmpty || drawing.bounds.isInfinite) else {
            return UIImage.solidImage(ofColor: .clear, ofSize: canvasSize)
        }
        return drawing.image(from: canvasSize.rectAtOrigin, scale: 0.5)
    }
    func mergeImage(component: ImageComponent) -> UIImage {
        let emptyBackground = UIView(frame: component.canvasSize.rectAtOrigin)
        emptyBackground.backgroundColor = .clear
        emptyBackground.addSubview(component.merge(merger: NormalLayerMerger()))
        return emptyBackground.asImage()
    }

    func merge(results: [UIImage], composite: CompositeComponent) -> UIImage {
        results.reduce(UIImage.solidImage(ofColor: .clear,
                                          ofSize: composite.canvasSize), { $0.mergeWith($1) })
    }
}
