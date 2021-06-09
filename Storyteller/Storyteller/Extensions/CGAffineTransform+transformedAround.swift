//
//  CGAffineTransform+transformedAround.swift
//  Storyteller
//
//  Created by TFang on 3/4/21.
//

import CoreGraphics

extension CGAffineTransform {
    func transformedAround(_ pointRelativeToAnchor: CGPoint) -> CGAffineTransform {
        CGAffineTransform(translationX: -pointRelativeToAnchor.x,
                          y: -pointRelativeToAnchor.y)
            .concatenating(self)
            .concatenating(CGAffineTransform(translationX: pointRelativeToAnchor.x,
                                             y: pointRelativeToAnchor.y))
    }
}
