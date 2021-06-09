//
//  StorageCompositeComponent.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//
struct PersistedLayerComponent: Codable {
    enum StorageNodeType {
        case drawing(DrawingComponent)
        case image(ImageComponent)
        case composite([PersistedLayerComponent])
    }

    var type: StorageNodeType

    init(_ node: LayerComponent) {
        self = PersistedLayerComponent.generateStorageComponent(node)
    }

    init(type: StorageNodeType) {
        self.type = type
    }

    static func generateStorageComponent(_ layerComponent: LayerComponent) -> PersistedLayerComponent {
        if let drawingComponent = layerComponent as? DrawingComponent {
            return PersistedLayerComponent(type: .drawing(drawingComponent))
        }
        if let imageComponent = layerComponent as? ImageComponent {
            return PersistedLayerComponent(type: .image(imageComponent))
        }
        if let composite = layerComponent as? CompositeComponent {
            let storageChildren = composite.children.map({ generateStorageComponent($0) })
            return PersistedLayerComponent(type: .composite(storageChildren))
        }

        fatalError("Failed to generate storage layer component")
    }

    enum CodingKeys: String, CodingKey {
        case children
        case drawing
        case image
    }

    enum CodableError: Error {
        case decoding(String)
        case encoding(String)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch type {
        case .drawing(let drawingComponent):
            try container.encode(drawingComponent, forKey: .drawing)
        case .image(let imageComponent):
            try container.encode(imageComponent, forKey: .image)
        case .composite(let children):
            var childrenContainer = container.nestedUnkeyedContainer(forKey: .children)
            try childrenContainer.encode(contentsOf: children)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let drawingComponent = try? container.decode(DrawingComponent.self, forKey: .drawing) {
            self.type = .drawing(drawingComponent)
            return
        }
        if let imageComponent = try? container.decode(ImageComponent.self, forKey: .image) {
            self.type = .image(imageComponent)
            return
        }
        if let children = try? container.decode([PersistedLayerComponent].self, forKey: .children) {
            self.type = .composite(children)
            return
        }

        throw CodableError.decoding("Error while decoding PersistedLayerComponent")
    }
}

extension PersistedLayerComponent {
    static func generateLayerComponent(_ storageComponent: PersistedLayerComponent) -> LayerComponent {
        switch storageComponent.type {
        case .drawing(let drawingComponent):
            return drawingComponent
        case .image(let imageComponent):
            return imageComponent
        case .composite(let storageChildren):
            let children = storageChildren.map({ generateLayerComponent($0) })
            return CompositeComponent(children: children)
        }
    }

    var component: LayerComponent {
        PersistedLayerComponent.generateLayerComponent(self)
    }
}
