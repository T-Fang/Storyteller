//
//  Clipboard.swift
//  Storyteller
//
//  Created by John Pan on 6/5/21.
//

import Foundation

class ClipBoard {
    static var shots: [Shot] = []
}

class ClipboardUtility {

    func copy(_ copiedShots: [Shot]) {

        var shotsToBeSaved: [Shot] = []

        for shot in copiedShots {
            shotsToBeSaved.append(shot.duplicate())
        }

        ClipBoard.shots.removeAll()
        ClipBoard.shots.append(contentsOf: shotsToBeSaved)

    }

    func paste() -> [Shot] {
        var shotsToBeSent: [Shot] = []

        for shot in ClipBoard.shots {
            shotsToBeSent.append(shot.duplicate())
        }

        return shotsToBeSent
    }
}
