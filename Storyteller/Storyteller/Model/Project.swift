//
//  Project.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Project: Directory {
    var description: String
    var name: String
    let id: UUID
    let dateAdded: Date
    var dateUpdated: Date

    let canvasSize: CGSize

    private var persistenceManager: ProjectPersistenceManager?
    private var observers = [ProjectObserver]()

    func observedBy(_ observer: ProjectObserver) {
        observers.append(observer)
    }

    var persisted: PersistedProject {
        PersistedProject(self)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    var scenes: [Scene] = []

    func loadScene(at index: Int) -> Scene? {
        guard scenes.indices.contains(index) else {
            return nil
        }
        let scene = scenes[index]
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                            .getScenePersistenceManager(of: scene.persisted))
        }
        return scene
    }

    init(name: String,
         description: String = "",
         canvasSize: CGSize,
         scenes: [Scene] = [],
         id: UUID = UUID(),
         persistenceManager: ProjectPersistenceManager? = nil,
         dateAdded: Date = Date(),
         dateUpdated: Date = Date()) {
        self.name = name
        self.description = description
        self.canvasSize = canvasSize
        self.scenes = scenes
        self.id = id
        self.persistenceManager = persistenceManager
        self.dateUpdated = dateUpdated
        self.dateAdded = dateAdded
    }

    func setPersistenceManager(to persistenceManager: ProjectPersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    private func updateDate() {
        self.dateUpdated = Date()
    }

    // TODO: check if working properly
    private func saveScene(_ scene: Scene) {
        self.updateDate()
        self.persistenceManager?.saveScene(scene.persisted)
        self.saveProject()
    }

    private func deleteScene(_ scene: Scene) {
        self.updateDate()
        self.persistenceManager?.deleteScene(scene.persisted)
        self.saveProject()
    }

    private func saveProject() {
        self.dateUpdated = Date()
        self.persistenceManager?.saveProject(self.persisted)
        self.notifyObservers()
    }

    func addScene(_ scene: Scene) {
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                        .getScenePersistenceManager(of: scene.persisted))
        }
        self.scenes.insert(scene, at: 0)
        self.saveScene(scene)
    }

    func insertScene(_ scene: Scene, at index: Int) {
        if let persistenceManager = persistenceManager {
            scene.setPersistenceManager(to: persistenceManager
                                        .getScenePersistenceManager(of: scene.persisted))
        }
        self.scenes.insert(scene, at: index)
        self.saveScene(scene)
    }

    func deleteScene(at index: Int) {
        let removedScene = self.scenes.remove(at: index)
        self.deleteScene(removedScene)
    }

    func renameProject(to name: String) {
        self.name = name
        self.saveProject()
    }

    func updateDescription(_ directory: Directory? = nil, to description: String) {
        self.description = description
        saveProject()
    }

    func duplicate() -> Project {
        Project(
            name: self.name,
            canvasSize: self.canvasSize,
            scenes: scenes.map({ $0.duplicate() })
        )
    }
}
