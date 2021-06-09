//
//  LayerTableController.swift
//  Storyteller
//
//  Created by TFang on 30/3/21.
//

import PencilKit

class LayerTableController: UIViewController {
    var numOfRows: Int {
        tableView.numberOfRows(inSection: 0)
    }
    var selectedLayerIndex = 0 {
        didSet {
            guard tableView != nil else {
                return
            }
            guard selectedLayerIndex < numOfRows, selectedLayerIndex >= 0 else {
                selectedLayerIndex = numOfRows - 1
                return
            }
            if !tableView.isEditing {
                tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
                delegate?.didSelectLayer(at: selectedLayerIndex)
            }
        }
    }
    var selectedIndexPath: IndexPath {
        IndexPath(row: selectedLayerIndex, section: 0)
    }
    weak var delegate: LayerTableDelegate?

    @IBOutlet private var tableView: UITableView!

    // should be intialized via segue
    var shot: Shot!
    var onionSkinRange: OnionSkinRange!

    var layerSelection = [Bool]()
    var multipleSelectionIndices: [Int] {
        layerSelection.indices.filter({ layerSelection[$0] })
    }

    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var groupButton: UIButton!
    @IBOutlet private var ungroupButton: UIButton!
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var backgroundColorButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        shot.observedBy(self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setBackgroundColor()
        setUpLayerSelection()
        reselect()
    }
    private func setBackgroundColor() {
        let color = shot.backgroundColor.uiColor
        backgroundColorButton.backgroundColor = color
    }
    private func reselect() {
        let selected = selectedLayerIndex
        selectedLayerIndex = selected
    }
    func setUpLayerSelection() {
        let count = shot.layers.count
        layerSelection = Array(repeating: false, count: count)
    }

}

// MARK: - UITableViewDataSource
extension LayerTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let layerCount = shot.layers.count
        return layerCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LayerTableViewCell.identifier,
                for: indexPath) as? LayerTableViewCell else {
            fatalError("Cannot get reusable cell.")
        }

        let layerOrder = shot.layers
        let layer = layerOrder[indexPath.row]
        cell.setUp(thumbnail: layer.defaultThumbnail, name: layer.name,
                   isLocked: layer.isLocked, isVisible: layer.isVisible)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LayerTableController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            selectSingleLayer(at: indexPath)
            return
        }
        selectLayerDuringEditing(at: indexPath)
    }
    private func selectSingleLayer(at indexPath: IndexPath) {
        guard selectedLayerIndex != indexPath.row else {
            Alert.presentRenameLayerAlert(at: indexPath.row, controlloer: self)
            return
        }
        selectedLayerIndex = indexPath.row
    }
    private func selectLayerDuringEditing(at indexPath: IndexPath) {
        layerSelection[indexPath.row] = true
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }
        layerSelection[indexPath.row] = false
    }
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        delegate?.willMoveLayer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
}
// MARK: - Actions
extension LayerTableController {
    @IBAction private func toggleEditMode(_ sender: Any) {
        let isEditing = tableView.isEditing
        if isEditing {
            exitEditingMode()
        } else {
            enterEditingMode()
        }
    }
    private func enterEditingMode() {
        tableView.setEditing(true, animated: true)
        editButton.setTitle("Done", for: .normal)
        addButton.isHidden = true
        groupButton.isEnabled = true
        ungroupButton.isEnabled = false
    }
    private func exitEditingMode() {
        tableView.setEditing(false, animated: true)
        editButton.setTitle("Edit", for: .normal)
        addButton.isHidden = false
        groupButton.isEnabled = false
        ungroupButton.isEnabled = true

        reselect()
        setUpLayerSelection()
    }
    @IBAction private func changeBackgroundColor() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = shot.backgroundColor.uiColor
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    @IBAction private func increasePrevOnionSkin() {
        onionSkinRange.decreaseLowerBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func decreasePrevOnionSkin() {
        onionSkinRange.increaseLowerBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func increaseNextOnionSkin() {
        onionSkinRange.increaseUpperBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func decreaseNextOnionSkin() {
        onionSkinRange.decreaseUpperBound()
        delegate?.onionSkinsDidChange()
    }

    // MARK: - Layers Actions
    @IBAction private func duplicateLayers() {
        guard tableView.isEditing else {
            delegate?.willDuplicateLayers(at: [selectedLayerIndex])
            return
        }
        delegate?.willDuplicateLayers(at: multipleSelectionIndices)
    }

    @IBAction private func groupLayers() {
        guard let lastIndex = multipleSelectionIndices.last,
              multipleSelectionIndices.count > 1 else {
            return
        }
        delegate?.willGroupLayers(at: multipleSelectionIndices)

        let newIndex = lastIndex - (multipleSelectionIndices.count - 1)
        selectedLayerIndex = newIndex
    }
    @IBAction private func ungroupLayers() {
        delegate?.willUngroupLayer(at: selectedLayerIndex)
    }
    @IBAction private func deleteLayers() {
        guard tableView.isEditing else {
            deleteSingleLayer()
            return
        }
        deleteMultipleLayer()
    }
    private func deleteSingleLayer() {
        guard numOfRows > 1 else {
            Alert.presentAtLeastOneLayerAlert(controller: self)
            selectedLayerIndex = 0
            return
        }
        delegate?.willRemoveLayers(at: [selectedLayerIndex])
        selectedLayerIndex = max(0, selectedLayerIndex - 1)
    }
    private func deleteMultipleLayer() {
        guard numOfRows > multipleSelectionIndices.count else {
            Alert.presentAtLeastOneLayerAlert(controller: self)
            return
        }
        delegate?.willRemoveLayers(at: multipleSelectionIndices)
        selectedLayerIndex = 0
    }
    @IBAction private func addLayer(_ sender: Any) {
        delegate?.willAddLayer()
        selectedLayerIndex = numOfRows - 1
    }
}
// MARK: - UIColorPickerViewControllerDelegate
extension LayerTableController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        backgroundColorButton.backgroundColor = color
        delegate?.backgroundColorWillChange(color: color)
    }
}
// MARK: - ModelManagerObserver
extension LayerTableController: ShotObserver {

    func modelDidChange() {
        tableView.reloadData()

        setUpLayerSelection()

        guard !tableView.isEditing else {
            return
        }
        reselect()
    }
}

// MARK: - LayerCellDelegate
extension LayerTableController: LayerCellDelegate {

    func didToggleLayerLock(cell: LayerTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didToggleLayerLock(at: index)
    }

    func didToggleLayerVisibility(cell: LayerTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didToggleLayerVisibility(at: index)
    }

    func didChangeLayerName(cell: LayerTableViewCell, newName: String) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didChangeLayerName(at: index, newName: newName)
    }
}

protocol LayerTableDelegate: AnyObject {
    func didSelectLayer(at index: Int)
    func didToggleLayerLock(at index: Int)
    func didToggleLayerVisibility(at index: Int)
    func didChangeLayerName(at index: Int, newName: String)

    func willAddLayer()
    func willRemoveLayers(at indices: [Int])
    func willMoveLayer(from oldIndex: Int, to newIndex: Int)
    func willDuplicateLayers(at indices: [Int])
    func willGroupLayers(at indices: [Int])
    func willUngroupLayer(at index: Int)
    func backgroundColorWillChange(color: UIColor)
    func onionSkinsDidChange()
}
