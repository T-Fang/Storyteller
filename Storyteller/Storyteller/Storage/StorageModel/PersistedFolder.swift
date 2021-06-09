//
//  PersistedFolder.swift
//  Storyteller
//
//  Created by mmarcus on 2/5/21.
//

import Foundation

//
//  PersistedFolder.swift
//  Storyteller
//
//  Created by mmarcus on 2/5/21.
//

import Foundation

struct PersistedFolder: Codable, PersistedDirectory {
    var id: UUID
    var name: String
    var description: String
    var dateAdded: Date
    var dateUpdated: Date
    var children: [UUID]

    init(_ folder: Folder) {
        self.id = folder.id
        self.name = folder.name
        self.description = folder.description
        self.dateAdded = folder.dateAdded
        self.dateUpdated = folder.dateUpdated
        self.children = folder.children.map { $0.id }
    }
}

protocol PersistedDirectory {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    var dateAdded: Date { get }
    var dateUpdated: Date { get }
}
