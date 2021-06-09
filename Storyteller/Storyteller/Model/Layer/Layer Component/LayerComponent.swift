//
//  LayerComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

protocol LayerComponent: Transformable {
    var canvasSize: CGSize { get }
    var containsDrawing: Bool { get }
    func setDrawing(to drawing: PKDrawing) -> Self

    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result
    func merge<Result, Merger>(merger: Merger) -> Result where Merger.T == Result, Merger: LayerMerger
}
