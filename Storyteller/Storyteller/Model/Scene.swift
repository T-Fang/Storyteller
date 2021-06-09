//
//  Scene.swift
//  Storyteller
//
//  Created by Marcus on 21/3/21.
//
import PencilKit

class Scene {
    let id: UUID
    var name: String
    let canvasSize: CGSize
    var description: String
    let dateAdded: Date
    var dateUpdated: Date
    var shots: [Shot] = [Shot]()
    private var persistenceManager: ScenePersistenceManager?
    private var observers = [SceneObserver]()

    var persisted: PersistedScene {
        PersistedScene(self)
    }

    func observedBy(_ observer: SceneObserver) {
        observers.append(observer)
    }

    func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }


    init(
        name: String,
        canvasSize: CGSize,
        description: String = "",
        id: UUID = UUID(),
        shots: [Shot] = [],
        dateAdded: Date = Date(),
        dateUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.canvasSize = canvasSize
        self.description = description
        self.dateUpdated = dateUpdated
        self.dateAdded = dateAdded
        self.shots = shots
    }


    func loadShot(at index: Int) -> Shot? {
        guard shots.indices.contains(index) else {
            return nil
        }
        let shot = shots[index]
        if let persistenceManager = persistenceManager {
            shot.setPersistenceManager(to: persistenceManager
                                            .getShotPersistenceManager(of: shot.persisted))
        }
        return shot
    }

    func setPersistenceManager(to persistenceManager: ScenePersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    private func saveScene() {
        self.updateDate()

        print(self.dateUpdated)

        self.persistenceManager?.saveScene(self.persisted)
        self.notifyObservers()
    }

    private func updateDate() {
        self.dateUpdated = Date()
    }

    private func saveShot(_ shot: Shot) {
        self.persistenceManager?.saveShot(shot.persisted)
        saveScene()
    }

    private func deleteShot(_ shot: Shot) {
        self.persistenceManager?.deleteShot(shot.persisted)
        saveScene()
    }

    func swapShots(_ index1: Int, _ index2: Int) {
        self.shots.swapAt(index1, index2)
        saveScene()
    }

    func addShot(_ shot: Shot, at index: Int? = nil) {
        self.shots.insert(shot, at: index ?? shots.endIndex)
        saveShot(shot)
        if let persistenceManager = persistenceManager {
            shot.setPersistenceManager(to: persistenceManager
                                        .getShotPersistenceManager(of: shot.persisted))
        }
        if shot.layers.isEmpty {
            let layer = Layer(withDrawing: PKDrawing(), canvasSize: shot.canvasSize)
            shot.addLayer(layer)
        }
    }

    func removeShot(_ shot: Shot) {
        self.shots.removeAll(where: { $0 === shot })
        saveScene()
    }

    func moveShot(shot: Shot, to newIndex: Int) {
        removeShot(shot)
        addShot(shot, at: newIndex)
    }

    func duplicate() -> Scene {
        Scene(
            name: name,
            canvasSize: canvasSize,
            description: description,
            shots: shots.map({ $0.duplicate() })
        )
    }

    func getShot(_ index: Int, after shot: Shot) -> Shot? {
        guard let currentIndex = self.shots.firstIndex(where: { $0 === shot }),
              self.shots.indices.contains(currentIndex + index) else {
            return nil
        }
        return loadShot(at: currentIndex + index)
    }

    func rename(to name: String) {
        self.name = name
        self.saveScene()
    }

    func updateDescription(to description: String) {
        self.description = description
        self.saveScene()
    }
}
