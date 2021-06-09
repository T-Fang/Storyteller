//
//  PersistedLayer.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//

import UIKit

struct PersistedLayer: Codable {
    var storageComponent: PersistedLayerComponent
    var canvasSize: CGSize
    var name: String
    var isLocked: Bool
    var isVisible: Bool

    var thumbnail: Thumbnail
    let id: UUID

    init(_ layer: Layer) {
        self.storageComponent = PersistedLayerComponent(layer.component)
        self.canvasSize = layer.canvasSize
        self.name = layer.name
        self.isLocked = layer.isLocked
        self.isVisible = layer.isVisible
        self.thumbnail = layer.thumbnail
        self.id = layer.id
    }

}

extension PersistedLayer {
    var layer: Layer {
        Layer(component: storageComponent.component, canvasSize: canvasSize,
              name: name, isLocked: isLocked, isVisible: isVisible, thumbnail: thumbnail, id: id)
    }
}
