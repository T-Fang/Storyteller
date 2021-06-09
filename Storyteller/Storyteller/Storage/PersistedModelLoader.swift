//
//  PersistedModelLoader.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class PersistedModelLoader {
    typealias PersistedModelTree = [(PersistedProject,
                                    [(PersistedScene,
                                      [(PersistedShot,
                                        [PersistedLayer]
                                      )])])]

    let rootManager = MainPersistenceManager()

    // [PersistedProject: [PersistedScene: [PersistedShot: [PersistedLayer]]

    func loadPersistedModels() -> PersistedModelTree {
        let projects = rootManager.loadPersistedProjects()
        return projects.map {
            let projectManager = rootManager.getProjectPersistenceManager(of: $0)
            let scenes = projectManager.loadPersistedScenes()
            return ($0,
             scenes.map {
                let sceneManager = projectManager.getScenePersistenceManager(of: $0)
                let shots = sceneManager.loadPersistedShots()
                return ($0,
                    shots.map {
                        let shotManager = sceneManager.getShotPersistenceManager(of: $0)
                        let layers = shotManager.loadPersistedLayers()
                        return ($0, layers)
                    }
                )
             })
        }
    }

    func getRootId() -> UUID? {
        rootManager.loadRootId()
    }

    func loadPersistedFolders() -> [PersistedFolder] {
        rootManager.loadPersistedFolders()
    }

    func loadPersistedDirectories() -> [PersistedDirectory] {
        rootManager.loadPersistedDirectories()
    }
}
