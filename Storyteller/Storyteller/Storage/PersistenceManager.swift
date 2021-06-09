//
//  PersistenceManager.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation

struct PersistenceManager {
    var url: URL

    init(at url: URL? = nil) {
        let defaultUrl = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.url = url ?? defaultUrl

        // print("CHECK")

    }
}

extension PersistenceManager {
    func getAllJsonUrls() -> [URL] {
        let allUrls = (try? FileManager
            .default
            .contentsOfDirectory(at: url,
                                 includingPropertiesForKeys: nil,
                                 options: .skipsSubdirectoryDescendants)) ?? []
        return allUrls.filter({ $0.pathExtension == "json" })
    }

    func getAllDirectoryUrls() -> [URL] {
        (try? FileManager
            .default
            .contentsOfDirectory(at: url,
                                 includingPropertiesForKeys: [.isDirectoryKey],
                                 options: .skipsSubdirectoryDescendants)) ?? []
    }

    func createFolder(named folderName: String) {
        let newFolderUrl = url.appendingPathComponent(folderName)
        try? FileManager.default.createDirectory(at: newFolderUrl, withIntermediateDirectories: false)
    }

    func deleteFolder(named folderName: String) {
        let deletedFolderUrl = url.appendingPathComponent(folderName)
        try? FileManager.default.removeItem(at: deletedFolderUrl)
    }

    func saveData(_ data: Data, toFile fileName: String, atFolder folderName: String? = nil) {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        try? data.write(to: fileUrl)
    }

    func loadData(_ fileName: String, atFolder folderName: String? = nil) -> Data? {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            // print(fileName, folderName)
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        return FileManager.default.contents(atPath: fileUrl.path)
    }

    func deleteFile(_ fileName: String, atFolder folderName: String? = nil) {
        var targetFolderUrl: URL = url
        if let folderName = folderName {
            targetFolderUrl = url.appendingPathComponent(folderName)
        }
        let fileUrl = targetFolderUrl.appendingPathComponent(fileName).appendingPathExtension("json")
        try? FileManager.default.removeItem(at: fileUrl)
    }

    func encodeToJSON<T: Encodable>(_ encodableObject: T) -> Data? {
        try? JSONEncoder().encode(encodableObject)
    }

    func decodeFromJSON<T: Decodable>(_ data: Data, as type: T.Type) -> T? {
        try? JSONDecoder().decode(T.self, from: data)
    }
}
