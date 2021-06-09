//
//  ProjectPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class ProjectPersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init(at url: URL) {
        self.manager = PersistenceManager(at: url)
    }

    func saveProject(_ project: PersistedProject) {
        guard let data = manager.encodeToJSON(project) else {
            return
        }
        manager.saveData(data, toFile: "Project Metadata")
    }

    func saveScene(_ scene: PersistedScene) {
        guard let data = manager.encodeToJSON(scene) else {
            return
        }
        let folderName = scene.id.uuidString
        manager.createFolder(named: folderName)
        manager.saveData(data, toFile: "Scene Metadata", atFolder: folderName)
    }

    func deleteScene(_ scene: PersistedScene) {
        let folderName = scene.id.uuidString
        manager.deleteFolder(named: folderName)
    }

    func loadPersistedScene(id: UUID) -> PersistedScene? {
        let folderName = id.uuidString
        guard let data = manager.loadData("Scene Metadata", atFolder: folderName) else {
            return nil
        }
        return manager.decodeFromJSON(data, as: PersistedScene.self)
    }

    func getScenePersistenceManager(of scene: PersistedScene) -> ScenePersistenceManager {
        let folderName = scene.id.uuidString
        return ScenePersistenceManager(at: url.appendingPathComponent(folderName))
    }

    func getScenePersistenceManagers() -> [ScenePersistenceManager] {
        manager.getAllDirectoryUrls().compactMap {
            ScenePersistenceManager(at: $0)
        }
    }

    func loadPersistedScenes() -> [PersistedScene] {
        let data = manager.getAllDirectoryUrls().compactMap {
            manager.loadData("Scene Metadata", atFolder: $0.lastPathComponent.description)
        }
        return data.compactMap {
            manager.decodeFromJSON($0, as: PersistedScene.self)
        }
    }
}
