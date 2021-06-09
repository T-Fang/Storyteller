//
//  Shot.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Shot {
    private static let thumbnailQueue = DispatchQueue(label: "ThumbnailQueue", qos: .background)
    var layers: [Layer] = [Layer]()
    var backgroundColor: Color
    let canvasSize: CGSize

    var thumbnail: Thumbnail
    let id: UUID
    private var persistenceManager: ShotPersistenceManager?
    private var observers = [ShotObserver]()

    var persisted: PersistedShot {
        PersistedShot(self)
    }

    func observedBy(_ observer: ShotObserver) {
        observers.append(observer)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    init(canvasSize: CGSize,
         backgroundColor: Color,
         layers: [Layer] = [],
         thumbnail: Thumbnail = Thumbnail(),
         id: UUID = UUID()) {
        self.canvasSize = canvasSize
        self.backgroundColor = backgroundColor
        self.layers = layers
        self.thumbnail = thumbnail
        self.id = id
    }

    func setPersistenceManager(to persistenceManager: ShotPersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    private func saveShot() {
        self.persistenceManager?.saveShot(self.persisted)
        notifyObservers()
    }

    private func saveLayer(_ layer: Layer) {
        self.persistenceManager?.saveLayer(layer.persisted)
        saveShot()
    }

    func generateThumbnails() {
        let defaultThumbnail = layers.reduce(
            UIImage.solidImage(ofColor: backgroundColor.uiColor,
                               ofSize: canvasSize), {
                                $0.mergeWith($1.defaultThumbnail)
                               })
        let redOnionSkin = layers
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), {
                                        $0.mergeWith($1.redOnionSkin) })
        let greenOnionSkin = layers
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), {
                                        $0.mergeWith($1.greenOnionSkin) })
        thumbnail = Thumbnail(defaultThumbnail: defaultThumbnail,
                              redOnionSkin: redOnionSkin, greenOnionSkin: greenOnionSkin)
    }

    func duplicate() -> Shot {
        Shot(canvasSize: canvasSize,
             backgroundColor: backgroundColor,
             layers: layers.map({ $0.duplicate() }),
             thumbnail: thumbnail)
    }

    func setBackgroundColor(color: Color) {
        self.backgroundColor = color
    }

    // MARK: - Layer Related Methods
    func addLayer(_ layer: Layer, at index: Int? = nil) {
        if let persistenceManager = persistenceManager {
            layer.setPersistenceManager(to: persistenceManager
                                                .getLayerPersistenceManager(for: layer.persisted))
        }
        layers.insert(layer, at: index ?? layers.endIndex)
        saveLayer(layer)
    }

    func duplicateLayers(at indices: [Int]) {
        indices
            .reversed()
            .forEach({ duplicateLayer(at: $0) })
    }

    func duplicateLayer(at index: Int) {
        let duplicatedLayer = layers[index].duplicate()
        addLayer(duplicatedLayer, at: index + 1)
    }

    func removeLayers(at indices: [Int]) {
        indices.reversed().forEach({ removeLayer(at: $0) })
    }

    @discardableResult
    func removeLayer(at index: Int) -> Layer {
        let removedLayer = layers.remove(at: index)
        self.persistenceManager?.deleteLayer(removedLayer.persisted)
        self.saveShot()
        return removedLayer
    }

    func moveLayer(from oldIndex: Int, to newIndex: Int) {
        addLayer(removeLayer(at: oldIndex), at: newIndex)
    }

    func updateLayer(_ layer: Layer, with newLayer: Layer) {
        if let index = self.layers.firstIndex(where: { $0 === layer }) {
            removeLayer(at: index)
            addLayer(newLayer, at: index)
        }
    }

    func groupLayers(at indices: [Int]) {
        guard let lastIndex = indices.last else {
            return
        }
        let newIndex = lastIndex - (indices.count - 1)

        let children = indices.map({ layers[$0].component })
        let component = CompositeComponent(children: children)
        let groupedLayer = Layer(component: component, canvasSize: canvasSize, name: Constants.defaultGroupedLayerName)
        removeLayers(at: indices)
        addLayer(groupedLayer, at: newIndex)
    }

    func ungroupLayer(at index: Int) {
        let layerToBeUngrouped = removeLayer(at: index)
        layerToBeUngrouped.ungroup().reversed().forEach({ addLayer($0, at: index) })
    }

    var onGoingThumbnailTask: (shot: Shot, workItem: DispatchWorkItem)?
}

// MARK: - Thumbnailable
extension Shot: Thumbnailable {

    func generateThumbnailAndSave() {
        self.saveShot()
        let workItem = DispatchWorkItem {
            self.generateThumbnails()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.saveShot()
                self.onGoingThumbnailTask = nil
            }
        }
        if let task = self.onGoingThumbnailTask, task.shot === self {
            task.workItem.cancel()
            self.onGoingThumbnailTask = (self, workItem)
        }
        Shot.thumbnailQueue.async(execute: workItem)
    }
}
