//
//  LayerTableViewCell.swift
//  Storyteller
//
//  Created by TFang on 1/4/21.
//

import UIKit

class LayerTableViewCell: UITableViewCell {
    static let identifier = "LayerCell"

    weak var delegate: LayerCellDelegate?

    var isLayerLocked: Bool {
        lockButton.isChosen
    }
    var isLayerVisible: Bool {
        visibilityButton.isChosen
    }
    @IBOutlet private var layerThumbnail: UIImageView!
    @IBOutlet private var layerName: UILabel!
    @IBOutlet private var layerNameTextField: UITextField!
    @IBOutlet private var lockButton: LayerLockButton!
    @IBOutlet private var visibilityButton: LayerVisibilityButton!

    func setUp(thumbnail: UIImage, name: String, isLocked: Bool, isVisible: Bool) {
        layerThumbnail.image = thumbnail
        layerThumbnail.contentMode = .scaleAspectFit
        layerName.text = name
        layerNameTextField.text = name
        lockButton.isChosen = isLocked
        visibilityButton.isChosen = isVisible
    }

    @IBAction private func toggleLayerLock() {
        lockButton.isChosen.toggle()
        delegate?.didToggleLayerLock(cell: self)
    }

    @IBAction private func toggleLayerVisibility() {
        visibilityButton.isChosen.toggle()
        delegate?.didToggleLayerVisibility(cell: self)
    }
}

protocol LayerCellDelegate: AnyObject {
    func didToggleLayerLock(cell: LayerTableViewCell)
    func didToggleLayerVisibility(cell: LayerTableViewCell)
    func didChangeLayerName(cell: LayerTableViewCell, newName: String)
}
