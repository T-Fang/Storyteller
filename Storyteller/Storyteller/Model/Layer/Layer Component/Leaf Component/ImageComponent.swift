//
//  ImageComponent.swift
//  Storyteller
//
//  Created by TFang on 16/4/21.
//
import PencilKit

struct ImageComponent {
    let canvasSize: CGSize
    private(set) var imageData: Data
    var transform = CGAffineTransform.identity

    var image: UIImage {
        UIImage(data: imageData)!
    }
}

extension ImageComponent: LayerComponent {
    func transformed(using transform: CGAffineTransform) -> ImageComponent {
        ImageComponent(canvasSize: canvasSize, imageData: imageData,
                       transform: self.transform.concatenating(transform))
    }

    var containsDrawing: Bool {
        false
    }

    func setDrawing(to drawing: PKDrawing) -> ImageComponent {
        self
    }

    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, LayerComponent) throws -> Result) rethrows -> Result {
        try nextPartialResult(initialResult, self)
    }

    func merge<Result, Merger>(merger: Merger) -> Result where
        Result == Merger.T, Merger: LayerMerger {
        merger.mergeImage(component: self)
    }

}
extension ImageComponent: Codable {
}
