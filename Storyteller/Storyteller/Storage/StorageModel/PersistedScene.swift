//
//  PersistedScene.swift
//  Storyteller
//
//  Created by mmarcus on 29/4/21.
//

import Foundation
import CoreGraphics

struct PersistedScene: Codable {
    var id: UUID
    var name: String
    var canvasSize: CGSize
    var description: String
    let dateAdded: Date
    var dateUpdated: Date
    var shots: [UUID]

    init(_ scene: Scene) {
        self.id = scene.id
        self.name = scene.name
        self.canvasSize = scene.canvasSize
        self.description = scene.description
        self.dateAdded = scene.dateAdded
        self.dateUpdated = scene.dateUpdated
        self.shots = scene.shots.map({ $0.id })
    }
}
