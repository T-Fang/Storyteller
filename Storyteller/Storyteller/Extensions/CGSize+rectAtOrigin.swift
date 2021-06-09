//
//  CGSize+rectAtOrigin.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import CoreGraphics

extension CGSize {
    var rectAtOrigin: CGRect {
        CGRect(origin: .zero, size: self)
    }
}
