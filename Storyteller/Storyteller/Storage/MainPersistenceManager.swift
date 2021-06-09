//
//  MainPersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

class MainPersistenceManager {
    private let manager: PersistenceManager

    var url: URL {
        manager.url
    }

    init() {
        self.manager = PersistenceManager()
    }

    // START: Folder methods

    func saveRootId(_ folderId: UUID) {
        guard let data = manager.encodeToJSON(folderId) else {
            return
        }
        manager.saveData(data, toFile: "Root ID")
    }

    func loadRootId() -> UUID? {
        guard let data = manager.loadData("Root ID") else {
            return nil
        }
        return manager.decodeFromJSON(data, as: UUID.self)
    }

    func saveFolder(_ folder: PersistedFolder) {
        guard let data = manager.encodeToJSON(folder) else {
            return
        }
        let fileName = folder.id.uuidString
        manager.saveData(data, toFile: fileName)
    }

    func loadPersistedFolders() -> [PersistedFolder] {
        let data = manager.getAllJsonUrls().compactMap {
            manager.loadData($0.deletingPathExtension().lastPathComponent.description)
        }
        print(data)
        return data.compactMap {
            manager.decodeFromJSON($0, as: PersistedFolder.self)
        }
    }

    func loadPersistedDirectories() -> [PersistedDirectory] {
        var output = [PersistedDirectory]()
        output.append(contentsOf: loadPersistedFolders())
        output.append(contentsOf: loadPersistedProjects())
        return output
    }

    func loadPersistedFolder(id: UUID) -> PersistedFolder? {
        let fileName = id.uuidString
        guard let data = manager.loadData(fileName) else {
            return nil
        }
        return manager.decodeFromJSON(data, as: PersistedFolder.self)
    }

    func deleteFolder(_ folder: PersistedFolder) {
        folder.children.forEach {
            if let subFolder = loadPersistedFolder(id: $0) {
                // NOTE: recursive deletion
                deleteFolder(subFolder)
            } else if let project = loadPersistedProject(id: $0) {
                deleteProject(project)
            }
        }
        manager.deleteFile(folder.id.uuidString)
    }

    // END: Folder methods

    func saveProject(_ project: PersistedProject) {
        guard let data = manager.encodeToJSON(project) else {
            return
        }
        let folderName = project.id.uuidString
        manager.createFolder(named: folderName)
        manager.saveData(data, toFile: "Project Metadata", atFolder: folderName)
    }

    func deleteProject(_ project: PersistedProject) {
        let folderName = project.id.uuidString
        manager.deleteFolder(named: folderName)
    }

    func loadPersistedProject(id: UUID) -> PersistedProject? {
        let folderName = id.uuidString
        guard let data = manager.loadData("Project Metadata", atFolder: folderName) else {
            return nil
        }
        return manager.decodeFromJSON(data, as: PersistedProject.self)
    }

    func getProjectPersistenceManager(of project: PersistedProject) -> ProjectPersistenceManager {
        let folderName = project.id.uuidString
        return ProjectPersistenceManager(at: url.appendingPathComponent(folderName))
    }

    func loadPersistedProjects() -> [PersistedProject] {
        let data = manager.getAllDirectoryUrls().compactMap {
            manager.loadData("Project Metadata", atFolder: $0.lastPathComponent.description)
        }
        return data.compactMap {
            manager.decodeFromJSON($0, as: PersistedProject.self)
        }
    }
}
