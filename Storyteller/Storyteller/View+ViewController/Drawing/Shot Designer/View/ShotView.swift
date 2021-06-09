//
//  ShotView.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ShotView: UIView {
    @IBOutlet private var onionSkins: UIImageView!

    var layerViews = [LayerView]()
    var toolPicker: PKToolPicker?

    var isInDrawingMode = false {
        didSet {
            updateEffectForSelectedLayer()
        }
    }
    var selectedLayerIndex = 0 {
        didSet {
            guard selectedLayerIndex < layerViews.count, selectedLayerIndex >= 0 else {
                selectedLayerIndex = layerViews.count - 1
                return
            }
            updateEffectForSelectedLayer()
        }
    }

    var selectedLayerView: LayerView {
        layerViews[selectedLayerIndex]
    }

    var currentCanvasView: PKCanvasView? {
        selectedLayerView.topCanvasView
    }

    private func updateEffectForSelectedLayer() {
        guard let canvasView = currentCanvasView,
              !selectedLayerView.isLocked, selectedLayerView.isVisible else {
            selectedLayerView.becomeFirstResponder()
            return
        }
        layerViews.forEach({ $0.isUserInteractionEnabled = false })
        selectedLayerView.isUserInteractionEnabled = true

        canvasView.becomeFirstResponder()
        toolPicker?.setVisible(isInDrawingMode, forFirstResponder: canvasView)
    }
    func setSize(canvasSize: CGSize) {
        bounds.size = canvasSize
        onionSkins.bounds.size = canvasSize
    }

    func setUpLayerViews(_ layerViews: [LayerView], toolPicker: PKToolPicker,
                         PKDelegate: PKCanvasViewDelegate) {
        let originalLayerCount = self.layerViews.count
        reset()
        guard !layerViews.isEmpty else {
            return
        }
        self.toolPicker = toolPicker
        layerViews.forEach({ add(layerView: $0, toolPicker: toolPicker,
                                 PKDelegate: PKDelegate) })
        guard layerViews.count == originalLayerCount else {
            selectedLayerIndex = layerViews.count - 1
            return
        }
        let selected = selectedLayerIndex
        selectedLayerIndex = selected
    }

    func updateOnionSkins(skins: UIImage) {
        onionSkins.image = skins
        bringSubviewToFront(onionSkins)
    }

    func add(layerView: LayerView, toolPicker: PKToolPicker,
             PKDelegate: PKCanvasViewDelegate) {
        layerViews.append(layerView)
        insertSubview(layerView, belowSubview: onionSkins)
        layerView.setUpPK(toolPicker: toolPicker, PKDelegate: PKDelegate)
    }
    func setUpBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }

    func reset() {
        layerViews.forEach({ $0.removeFromSuperview() })
        layerViews = []
    }
}

// MARK: - Update Layer View
extension ShotView {
    func transformedSelectedLayer(using transform: CGAffineTransform) {
        selectedLayerView.transform = selectedLayerView.transform
            .concatenating(transform)
    }
    func resetSelectedLayerTransform() -> CGAffineTransform {
        let transform = selectedLayerView.transform
        selectedLayerView.transform = .identity
        return transform
    }

    func updateLayerView(at index: Int, isLocked: Bool, isVisible: Bool) {
        layerViews[index].isLocked = isLocked
        layerViews[index].isVisible = isVisible
        updateEffectForSelectedLayer()
    }
    func updateLayerViews(newLayerViews: [LayerView]) {
        for i in newLayerViews.indices {
            layerViews[i].isLocked = newLayerViews[i].isLocked
            layerViews[i].isVisible = newLayerViews[i].isVisible

            updateEffectForSelectedLayer()
        }
    }

    func removeLayers(at indices: [Int]) {
        for index in indices.reversed() {
            remove(at: index)
        }
    }
    func remove(at index: Int) {
        let layerView = layerViews.remove(at: index)
        layerView.removeFromSuperview()

        selectedLayerIndex = max(0, index - 1)
    }
    func duplicateLayers(at indices: [Int]) {
        for index in indices.reversed() {
            duplicate(at: index)
        }
    }
    func duplicate(at index: Int) {
        let duplicatedlayer = layerViews[index].duplicate()
        insert(duplicatedlayer, at: index + 1)
        selectedLayerIndex = index + 1
    }
    func groupLayers(at indices: [Int]) {
        guard let lastIndex = indices.last else {
            return
        }
        let newIndex = lastIndex - (indices.count - 1)

        var selectedLayerViews = [LayerView]()
        for index in indices {
            let layerView = layerViews[index]
            layerView.isLocked = false
            layerView.isVisible = true
            selectedLayerViews.append(layerView)
        }
        let groupedLayerView = CompositeLayerView(canvasSize: bounds.size,
                                                  children: selectedLayerViews)
        removeLayers(at: indices)
        insert(groupedLayerView, at: newIndex)
    }
    func ungroupLayer(at index: Int) {
        guard let children = (layerViews.remove(at: index)
                                as? CompositeLayerView)?.children else {
            return
        }
        children.reversed().forEach({ insert($0, at: index) })
    }
    func moveLayer(from oldIndex: Int, to newIndex: Int) {
        insert(layerViews.remove(at: oldIndex), at: newIndex)

    }
    func insert(_ layerView: LayerView, at index: Int) {
        layerViews.insert(layerView, at: index)
        guard index > 0 else {
            sendSubviewToBack(layerViews[index])
            return
        }
        insertSubview(layerViews[index], aboveSubview: layerViews[index - 1])
        selectedLayerIndex = index
    }
}
