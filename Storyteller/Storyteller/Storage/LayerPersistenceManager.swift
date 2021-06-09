//
//  LayerPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 1/5/21.
//

import Foundation

class LayerPersistenceManager {
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
}
