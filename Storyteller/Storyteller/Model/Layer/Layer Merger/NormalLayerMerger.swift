//
//  NormalLayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import PencilKit

class NormalLayerMerger: LayerMerger {
    func mergeDrawing(component: DrawingComponent) -> LayerView {
        DrawingLayerView(drawing: component.drawing, canvasSize: component.canvasSize)
    }
    func mergeImage(component: ImageComponent) -> LayerView {
        let imageLayerView = ImageLayerView(canvasSize: component.canvasSize,
                                            image: component.image)
        imageLayerView.transform = component.transform
        return imageLayerView
    }
    func merge(results: [LayerView], composite: CompositeComponent) -> LayerView {
        CompositeLayerView(canvasSize: composite.canvasSize, children: results)
    }

}
