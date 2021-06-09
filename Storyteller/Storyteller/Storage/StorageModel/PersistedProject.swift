//
//  PersistedProject.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedProject: Codable, PersistedDirectory {
    var id: UUID
    let name: String
    let canvasSize: CGSize
    var description: String
    var dateAdded: Date
    var dateUpdated: Date
    var scenes: [UUID]

    init(_ project: Project) {
        self.id = project.id
        self.name = project.name
        self.canvasSize = project.canvasSize
        self.description = project.description
        self.dateAdded = project.dateAdded
        self.dateUpdated = project.dateUpdated
        self.scenes = project.scenes.map({ $0.id })
    }
}
