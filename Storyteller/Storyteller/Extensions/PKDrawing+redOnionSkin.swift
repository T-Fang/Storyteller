//
//  PKDrawing+redOnionSkin.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import PencilKit

extension PKDrawing {
    var redOnionSkin: PKDrawing {
        PKDrawing(strokes: strokes.map { stroke in
            let redInk = PKInk(stroke.ink.inkType, color: .red)
            return PKStroke(ink: redInk, path: stroke.path,
                            transform: stroke.transform, mask: stroke.mask)
        })
    }
    var greenOnionSkin: PKDrawing {
        PKDrawing(strokes: strokes.map { stroke in
            let redInk = PKInk(stroke.ink.inkType, color: .green)
            return PKStroke(ink: redInk, path: stroke.path,
                            transform: stroke.transform, mask: stroke.mask)
        })
    }
}
