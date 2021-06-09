//
//  LayerMerger.swift
//  Storyteller
//
//  Created by TFang on 27/3/21.
//

import PencilKit

protocol LayerMerger {
    associatedtype T
    func mergeDrawing(component: DrawingComponent) -> T
    func mergeImage(component: ImageComponent) -> T

    func merge(results: [T], composite: CompositeComponent) -> T
}
