//
//  File.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import Foundation

protocol File {

    var id: UUID { get }

    var name: String { get set }

    var description: String { get set }

    var dateAdded: Date { get }

    var dateUpdated: Date { get set }
}
