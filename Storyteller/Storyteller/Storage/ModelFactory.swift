//
//  ModelFactory.swift
//  Storyteller
//
//  Created by mmarcus on 30/4/21.
//

import Foundation

class ModelFactory {
    private let rootPersistenceManager = MainPersistenceManager()
    typealias PersistedModelTree = [(PersistedProject,
                                    [(PersistedScene,
                                      [(PersistedShot,
                                        [PersistedLayer]
                                      )])])]

    private func generateProject(from persistedProject: PersistedProject, withScenes scenes: [Scene]) -> Project {
        let idToScene: [UUID: Scene] = Dictionary(scenes.map { ($0.id, $0) }) { $1 }
        let orderedScenes = persistedProject.scenes.compactMap({ idToScene[$0] })
        return Project(name: persistedProject.name,
                       canvasSize: persistedProject.canvasSize,
                       scenes: orderedScenes,
                       id: persistedProject.id,
                       dateAdded: persistedProject.dateAdded,
                       dateUpdated: persistedProject.dateUpdated
        )
    }

    private func generateScene(from persistedScene: PersistedScene, withShots shots: [Shot]) -> Scene {
        let idToShot: [UUID: Shot] = Dictionary(shots.map { ($0.id, $0) }) { $1 }
        return Scene(
            name: persistedScene.name,
            canvasSize: persistedScene.canvasSize,
            description: persistedScene.description,
            id: persistedScene.id,
            shots:  persistedScene.shots.compactMap({ idToShot[$0] }),
            dateAdded: persistedScene.dateAdded,
            dateUpdated: persistedScene.dateUpdated
        )
    }

    private func generateShot(from persistedShot: PersistedShot, withLayers layers: [Layer]) -> Shot {
        let idToLayer: [UUID: Layer] = Dictionary(layers.map { ($0.id, $0) }) { $1 }
        return Shot(canvasSize: persistedShot.canvasSize,
                    backgroundColor: persistedShot.backgroundColor,
                    layers: persistedShot.layers.compactMap({ idToLayer[$0] }),
                    thumbnail: persistedShot.thumbnail,
                    id: persistedShot.id
        )
    }

    private func generateLayers(from persistedLayers: [PersistedLayer]) -> [Layer] {
        persistedLayers.map({ $0.layer })
    }

    private func initializePersistenceManagers(for projects: [Project]) {
        projects.forEach {
            print("project forEach")
            let projectPersistenceManager = rootPersistenceManager
                .getProjectPersistenceManager(of: $0.persisted)
            $0.setPersistenceManager(to: projectPersistenceManager)
            $0.scenes.forEach {
                let scenePersistenceManager = projectPersistenceManager
                    .getScenePersistenceManager(of: $0.persisted)
                $0.setPersistenceManager(to: scenePersistenceManager)
                $0.shots.forEach {
                    let shotPersistenceManager = scenePersistenceManager
                        .getShotPersistenceManager(of: $0.persisted)
                    $0.setPersistenceManager(to: shotPersistenceManager)
                    $0.layers.forEach {
                        let layerPersistenceManager = shotPersistenceManager
                            .getLayerPersistenceManager(for: $0.persisted)
                        $0.setPersistenceManager(to: layerPersistenceManager)
                    }
                }
            }
        }
    }

    func loadProjectModel(from tree: PersistedModelTree) -> [Project] {
        let projects = tree.map {
            generateProject(from: $0, withScenes: $1.map {
                generateScene(from: $0, withShots: $1.map {
                    generateShot(from: $0, withLayers: generateLayers(from: $1))
                })
            })
        }
        initializePersistenceManagers(for: projects)
        return projects
    }

    func loadDirectoryModel(from directories: [PersistedDirectory],
                            withRootId rootId: UUID,
                            withProjects projects: [Project]) -> Directory {
        let idToProjects: [UUID: Project] = Dictionary(projects.map { ($0.id, $0) }) { $1 }
        let idToPersistedDirectory: [UUID: PersistedDirectory] = Dictionary(directories.map { ($0.id, $0) }) { $1 }
        guard let rootDirectory = idToPersistedDirectory[rootId],
              let dir = buildDirectory(withRoot: rootDirectory,
                                       withSubDirectories: idToPersistedDirectory,
                                       withProjects: idToProjects) else {
            return Folder(name: "Root", description: "This is the root folder")
        }
        return dir
    }

    private func buildDirectory(withRoot rootDirectory: PersistedDirectory,
                                withSubDirectories subDirectories: [UUID: PersistedDirectory],
                                withProjects projects: [UUID: Project],
                                withParent parent: Folder? = nil) -> Directory? {
        if let project = rootDirectory as? PersistedProject {
            return projects[project.id]
        } else if let folder = rootDirectory as? PersistedFolder {
            let subPersistedDirectories = folder.children.compactMap {
                subDirectories[$0]
            }
            let folder = Folder(name: folder.name,
                                description: folder.description,
                                id: folder.id,
                                dateAdded: folder.dateAdded,
                                dateUpdated: folder.dateUpdated,
                                parent: parent)
            let subDirectories = subPersistedDirectories.compactMap {
                buildDirectory(withRoot: $0,
                               withSubDirectories: subDirectories,
                               withProjects: projects,
                               withParent: folder)
            }
            folder.addDirectories(subDirectories)
            return folder
        }
        return nil
    }
}
