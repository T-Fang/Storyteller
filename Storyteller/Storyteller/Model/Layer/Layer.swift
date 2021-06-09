//
//  Layer.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Layer {
    var component: LayerComponent
    var name: String
    var canvasSize: CGSize
    var isLocked = false
    var isVisible = true {
        didSet {
            generateThumbnail()
        }
    }
    private var observers = [LayerObserver]()
    let id: UUID

    var thumbnail: Thumbnail
    private var persistenceManager: LayerPersistenceManager?

    var persisted: PersistedLayer {
        PersistedLayer(self)
    }

    init(component: LayerComponent, canvasSize: CGSize, name: String,
         isLocked: Bool = false, isVisible: Bool = true, thumbnail: Thumbnail? = nil, id: UUID = UUID()) {
        self.component = component
        self.canvasSize = canvasSize
        self.name = name
        self.isLocked = isLocked
        self.isVisible = isVisible
        self.id = id
        guard let thumbnail = thumbnail else {
            self.thumbnail = Thumbnail()
            generateThumbnail()
            return
        }
        self.thumbnail = thumbnail
    }

    func observedBy(_ observer: LayerObserver) {
        observers.append(observer)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    func setPersistenceManager(to manager: LayerPersistenceManager) {
        self.persistenceManager = manager
    }

    private func saveLayer() {
        self.persistenceManager?.saveLayer(self.persisted)
    }

    init(withDrawing drawing: PKDrawing, canvasSize: CGSize,
         name: String = Constants.defaultDrawingLayerName, id: UUID = UUID()) {
        self.canvasSize = canvasSize
        self.component = DrawingComponent(canvasSize: canvasSize, drawing: drawing)
        self.name = name
        self.id = id
        self.thumbnail = component.merge(merger: ThumbnailMerger())
    }

    init(withImage image: UIImage, canvasSize: CGSize,
         name: String = Constants.defaultImageLayerName, id: UUID = UUID()) {
        self.canvasSize = canvasSize
        self.component = ImageComponent(
            canvasSize: canvasSize, imageData: image.pngData()!)
        self.name = name
        self.id = id
        self.thumbnail = component.merge(merger: ThumbnailMerger())
    }

    func setDrawing(to drawing: PKDrawing) {
        updateComponent(component.setDrawing(to: drawing))
        saveLayer()
    }

    func updateComponent(_ component: LayerComponent) {
        self.component = component
        generateThumbnail()
        saveLayer()
    }

    func generateThumbnail() {
        guard isVisible else {
            thumbnail = Thumbnail()
            return
        }
        thumbnail = component.merge(merger: ThumbnailMerger())
        saveLayer()
    }

    func ungroup() -> [Layer] {
        guard let children = (component as? CompositeComponent)?.children else {
            return [self]
        }
        return children.map({ Layer(component: $0, canvasSize: canvasSize,
                                    name: Constants.defaultUngroupedLayerName,
                                    isLocked: isLocked,
                                    isVisible: isVisible)})
    }
    func duplicate() -> Layer {
        Layer(component: component,
              canvasSize: canvasSize,
              name: name,
              isLocked: isLocked,
              isVisible: isVisible,
              thumbnail: thumbnail)
    }
}

// MARK: - Transformable
extension Layer {
    func transform(using transform: CGAffineTransform) {
        updateComponent(component.transformed(using: transform))
    }

    var canTransform: Bool {
        !isLocked && isVisible
    }
}

// MARK: - Thumbnailable
extension Layer: Thumbnailable {
}
