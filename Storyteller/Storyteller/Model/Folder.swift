//
//  Folder.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class Folder: Directory {
    var description: String
    var name: String
    let id: UUID
    var dateAdded: Date
    var dateUpdated: Date

    private let persistenceManager = MainPersistenceManager()
    var observers = [FolderObserver]()

    var parent: Folder?

    var children: [Directory]

    var projects: [Project] {
        children.compactMap { $0 as? Project }
    }

    var persisted: PersistedFolder {
        PersistedFolder(self)
    }

    static func retrieveMainFolder() -> Folder {
        let loader = PersistedModelLoader()
        guard let rootId = loader.getRootId() else {
            return Folder(name: "Root", description: "This is a root folder")
        }
        let persistedModelTree = loader.loadPersistedModels()

        let persistedDirectories = loader.loadPersistedDirectories()
        let projects = ModelFactory().loadProjectModel(from: persistedModelTree)
        let directories = ModelFactory().loadDirectoryModel(from: persistedDirectories,
                                                            withRootId: rootId,
                                                            withProjects: projects)

        guard let folder = directories as? Folder else {
            return Folder(name: "Root", description: "This is a root folder")
        }
        return folder
    }

    init(name: String,
         description: String,
         id: UUID = UUID(),
         dateAdded: Date = Date(),
         dateUpdated: Date = Date(),
         children: [Directory] = [],
         parent: Folder? = nil) {

        self.description = description
        self.id = id
        self.name = name
        self.dateAdded = dateAdded
        self.dateUpdated = dateUpdated
        self.children = children
        self.parent = parent
        self.children = children
        print(self.id, self.children)
    }

    func setParent(to parent: Folder) {
        self.parent = parent
    }

    private func saveDirectory() {
        saveDirectory(self)
    }

    private func saveDirectory(_ directory: Directory) {
        self.updateDate()
        if let folder = directory as? Folder {
            self.persistenceManager.saveFolder(folder.persisted)
        } else if let project = directory as? Project {
            self.persistenceManager.saveProject(project.persisted)
        }
        if self.parent == nil {
            self.persistenceManager.saveRootId(self.id)
            // self.persistenceManager.saveRootIds(children.map { $0.id })
        }
        self.persistenceManager.saveFolder(self.persisted)
        self.notifyObservers()
    }

    private func deleteDirectory(_ directory: Directory) {
        self.updateDate()
        if let folder = directory as? Folder {
            self.persistenceManager.deleteFolder(folder.persisted)
        } else if let project = directory as? Project {
            self.persistenceManager.deleteProject(project.persisted)
        }
        self.persistenceManager.saveFolder(self.persisted)
        self.notifyObservers()
    }

    func addDirectory(_ directory: Directory) {
        if let project = directory as? Project {
            project
                .setPersistenceManager(to: self.persistenceManager.getProjectPersistenceManager(of: project.persisted))
        } else if let folder = directory as? Folder {
            folder.setParent(to: self)
        }
        self.children.append(directory)
        self.saveDirectory(directory)
    }

    func loadDirectory(at index: Int) -> Directory? {
        guard self.children.indices.contains(index) else {
            return nil
        }
        return self.children[index]
    }

    func removeDirectory(_ directory: Directory) {
        self.children = self.children.filter {
            $0 as? Project !== directory as? Project &&
            $0 as? Folder !== directory as? Folder
        }
        self.deleteDirectory(directory)
    }

    private func updateDate() {
        self.dateUpdated = Date()
    }

    func renameDirectory(_ directory: Directory? = nil, to name: String) {
        if let directory = directory {
            (directory as? Folder)?.renameDirectory(to: name)
            (directory as? Project)?.renameProject(to: name)
        } else {
            self.name = name
        }
        saveDirectory(directory ?? self)
    }

    func updateDescription(_ directory: Directory? = nil, to description: String) {
        if let directory = directory {
            (directory as? Folder)?.updateDescription(to: description)
            (directory as? Project)?.updateDescription(to: description)
        } else {
            self.description = description
        }
        saveDirectory(directory ?? self)
    }

    func observedBy(_ observer: FolderObserver) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach({ $0.modelDidChange() })
    }

    func addDirectories(_ directories: [Directory]) {
        self.children.append(contentsOf: directories)
        directories.forEach { saveDirectory($0) }
        self.saveDirectory()
    }

    func moveChildren(indices selectedIndices: [Int], to folder: Folder) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        let movedChildren: [Directory] = sortedIndices.compactMap {
            children.indices.contains($0) ? children[$0] : nil
        }
        movedChildren.forEach {
            ($0 as? Folder)?.setParent(to: folder)
        }
        folder.addDirectories(movedChildren)
        sortedIndices.forEach { self.children.remove(at: $0) }
        self.saveDirectory(folder)
        self.saveDirectory()
    }

    func deleteChildren(at selectedIndices: [Int]) {
        let sortedIndices = selectedIndices.sorted(by: { $1 < $0 })
        sortedIndices.forEach {
            self.deleteDirectory(self.children.remove(at: $0))
        }
        self.saveDirectory()
    }

    func swapChildrenAt(index1: Int, index2: Int) {
        self.children.swapAt(index1, index2)
        self.saveDirectory()
    }
}
