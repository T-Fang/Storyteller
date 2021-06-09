//
//  CompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import PencilKit

struct CompositeComponent {
    var children: [LayerComponent]
}

extension CompositeComponent: LayerComponent {
    func transformed(using transform: CGAffineTransform) -> CompositeComponent {
        CompositeComponent(children: children.map({ $0.transformed(using: transform) }))
    }

    var canvasSize: CGSize {
        children.first?.canvasSize ?? .zero
    }

    var containsDrawing: Bool {
        children.contains(where: { $0.containsDrawing })
    }
    func setDrawing(to drawing: PKDrawing) -> CompositeComponent {
        var newNode = self
        guard let index = children.lastIndex(where: { $0.containsDrawing }) else {
            return self
        }
        newNode.children[index] = children[index].setDrawing(to: drawing)
        return newNode
    }

    func merge<Result, Merger>(merger: Merger) -> Result where
        Result == Merger.T, Merger: LayerMerger {
        let childrenResult = children.map({ $0.merge(merger: merger) })
        return merger.merge(results: childrenResult, composite: self)
    }
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
        try children.reduce(initialResult, nextPartialResult)
    }
}
