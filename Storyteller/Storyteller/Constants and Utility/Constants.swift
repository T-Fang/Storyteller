//
//  Constants.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//

import UIKit

class Constants {
    // MARK: - Alert title
    static let okTitle = "OK"
    static let errorTitle = "Error"

    // MARK: - Alert message
    static let atLeastOneLayerMessage = "There must be at least one layer"

    static let defaultDrawingLayerName = "New Drawing"
    static let defaultImageLayerName = "New Image"
    static let defaultGroupedLayerName = "Grouped Layer"
    static let defaultUngroupedLayerName = "Ungrouped Layer"
    // MARK: - Numbers
    static let horizontalCanvasMargin = CGFloat(20)
    static let verticalCanvasMargin = CGFloat(20)

    static let defaultCanvasSize = UIScreen.main.bounds.size

    static let maxLayerZoomScale = CGFloat(3)
    static let minLayerZoomScale = CGFloat(0.2)

    static let layerBorderWidth = CGFloat(0.5)

    static let clearImage = UIImage.solidImage(ofColor: .clear,
                                               ofSize: Constants.defaultCanvasSize)
}
