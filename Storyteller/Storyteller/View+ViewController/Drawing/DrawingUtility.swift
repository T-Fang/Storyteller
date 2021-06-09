//
//  DrawingUtility.swift
//  Storyteller
//
//  Created by TFang on 21/3/21.
//
import UIKit
class DrawingUtility {
    static func generateLayerView(for layer: Layer) -> LayerView {
        let layerView = layer.component.merge(merger: NormalLayerMerger())
        layerView.isLocked = layer.isLocked
        layerView.isVisible = layer.isVisible
        return layerView
    }
    static func generateLayerViews(for shot: Shot) -> [LayerView] {
        shot.layers.map({ generateLayerView(for: $0) })
    }
    static func generateShotThumbnail(for shot: Shot) -> UIImage {
        let shotView = UIView(frame: shot.canvasSize.rectAtOrigin)
        generateLayerViews(for: shot).forEach({ shotView.addSubview($0) })
        return shotView.asImage()
    }
}
