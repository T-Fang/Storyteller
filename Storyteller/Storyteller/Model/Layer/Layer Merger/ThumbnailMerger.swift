//
//  ThumbnailMerger.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import UIKit

class ThumbnailMerger: LayerMerger {

    func mergeDrawing(component: DrawingComponent) -> Thumbnail {
        let canvasSize = component.canvasSize
        let drawing = component.drawing
        guard !(drawing.bounds.isEmpty || drawing.bounds.isInfinite) else {
            return Thumbnail()
        }

        let thumbnail = drawing.image(from: canvasSize.rectAtOrigin, scale: 0.5)
        let redOnionSkin = drawing.redOnionSkin
            .image(from: canvasSize.rectAtOrigin, scale: 0.5)
        let greenOnionSkin = drawing.greenOnionSkin
            .image(from: canvasSize.rectAtOrigin, scale: 0.5)
        return Thumbnail(defaultThumbnail: thumbnail, redOnionSkin: redOnionSkin,
                         greenOnionSkin: greenOnionSkin)
    }
    func mergeImage(component: ImageComponent) -> Thumbnail {
        let emptyBackground = UIView(frame: component.canvasSize.rectAtOrigin)
        emptyBackground.backgroundColor = .clear
        emptyBackground.addSubview(component.merge(merger: NormalLayerMerger()))
        let image = emptyBackground.asImage()
        return Thumbnail(defaultThumbnail: image, redOnionSkin: image,
                         greenOnionSkin: image)
    }

    func merge(results: [Thumbnail], composite: CompositeComponent) -> Thumbnail {
        let clearImage = UIImage.solidImage(ofColor: .clear,
                                            ofSize: composite.canvasSize)
        let defaultThumbnail = results.map({ $0.defaultThumbnail })
            .reduce(clearImage, { $0.mergeWith($1) })
        let redOnionSkin = results.map({ $0.redOnionSkin })
            .reduce(clearImage, { $0.mergeWith($1) })
        let greenOnionSkin = results.map({ $0.redOnionSkin })
            .reduce(clearImage, { $0.mergeWith($1) })
        return Thumbnail(defaultThumbnail: defaultThumbnail, redOnionSkin: redOnionSkin,
                         greenOnionSkin: greenOnionSkin)
    }
}
