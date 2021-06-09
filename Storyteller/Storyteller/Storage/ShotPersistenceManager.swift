//
//  LayerPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class ShotPersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init(at url: URL) {
        self.manager = PersistenceManager(at: url)
    }

    func saveLayer(_ layer: PersistedLayer) {
        guard let data = manager.encodeToJSON(layer) else {
            return
        }
        let fileName = layer.id.uuidString
        manager.saveData(data, toFile: fileName)
    }

    func saveShot(_ shot: PersistedShot) {
        guard let data = manager.encodeToJSON(shot) else {
            return
        }
        manager.saveData(data, toFile: "Shot Metadata")
    }

    func deleteLayer(_ layer: PersistedLayer) {
        let fileName = layer.id.uuidString
        manager.deleteFile(fileName)
    }

    func loadPersistedLayer(id: UUID) -> PersistedLayer? {
        let fileName = id.uuidString
        guard let data = manager.loadData(fileName) else {
            return nil
        }
        return manager.decodeFromJSON(data, as: PersistedLayer.self)
    }

    func loadPersistedLayers() -> [PersistedLayer] {
        let data = manager.getAllJsonUrls().compactMap {
            manager.loadData($0.deletingPathExtension().lastPathComponent.description)
        }
        return data.compactMap {
            manager.decodeFromJSON($0, as: PersistedLayer.self)
        }
    }

    func getLayerPersistenceManager(for persistedLayer: PersistedLayer) -> LayerPersistenceManager {
        LayerPersistenceManager(at: url)
    }
}
