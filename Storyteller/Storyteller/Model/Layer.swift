//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

struct Layer: Codable, Identifiable {
    var layerType: LayerType
    var drawing: PKDrawing
    let canvasSize: CGSize
    var label: LayerLabel
    var id: UUID

    mutating func setDrawing(to updatedDrawing: PKDrawing) {
        self.drawing = updatedDrawing
    }

    func duplicate(withId newId: UUID = UUID()) -> Self {
        let newLabel = self.label.withLayerId(newId)
        return Self(
            layerType: self.layerType,
            drawing: self.drawing,
            canvasSize: self.canvasSize,
            label: newLabel,
            id: newId
        )
    }
}
