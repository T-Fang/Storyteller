//
//  DrawingComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct DrawingComponent {
    let canvasSize: CGSize
    private(set) var drawing: PKDrawing
}

extension DrawingComponent: LayerComponent {

    // MARK: - Transformable
    var anchor: CGPoint {
        CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
    }
    func transformed(using transform: CGAffineTransform) -> DrawingComponent {
        DrawingComponent(canvasSize: canvasSize,
                         drawing: drawing.transformed(using: transform.transformedAround(anchor)))
    }

    // MARK: - LayerComponent
    var containsDrawing: Bool {
        true
    }
    func setDrawing(to drawing: PKDrawing) -> DrawingComponent {
        var newComponent = self
        newComponent.drawing = drawing
        return newComponent
    }

    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
        try nextPartialResult(initialResult, self)
    }
    func merge<Result, Merger>(merger: Merger) -> Result where
        Result == Merger.T, Merger: LayerMerger {
        merger.mergeDrawing(component: self)
    }
}

extension DrawingComponent: Codable {
}
