//
//  ShotDesignerController.swift
//  Storyteller
//
//  Created by TFang on 20/3/21.
//
import PencilKit

class ShotDesignerViewController: UIViewController {
    @IBOutlet private var shotView: ShotView! {
        didSet {
            shotView.clipsToBounds = true
            shotView.addInteraction(UIDropInteraction(delegate: self))
        }
    }

    @IBOutlet private var transformLayerButton: TransformLayerButton!
    @IBOutlet private var drawingModeButton: DrawingModeButton!

    var editingMode = EditingMode.free {
        didSet {
            switch editingMode {
            case .free:
                transformLayerButton.deselect()
                drawingModeButton.deselect()
                shotView.isInDrawingMode = false
            case .transformLayer:
                transformLayerButton.select()
                drawingModeButton.deselect()
                shotView.isInDrawingMode = false
            case .drawing:
                transformLayerButton.deselect()
                drawingModeButton.select()
                shotView.isInDrawingMode = true
            }
        }
    }
    var onionSkinRange = OnionSkinRange()
    var toolPicker = PKToolPicker()
    // should be intialized via segue
    var shot: Shot!
    var scene: Scene!

    var canvasTransform = CGAffineTransform.identity {
        didSet {
            updateShotTransform()
        }
    }

    var canvasSize: CGSize {
        shot.canvasSize
    }

    var selectedLayerIndex: Int {
        get {
            shotView.selectedLayerIndex
        }
        set {
            shotView.selectedLayerIndex = newValue
        }
    }

    var selectedLayer: Layer {
        shot.layers[selectedLayerIndex]
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        toolPicker.addObserver(self)

        shotView.setSize(canvasSize: canvasSize)
        setUpShot()

        editingMode = .drawing
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateShotTransform()
    }

    private func setUpShot() {
        shotView.backgroundColor = shot.backgroundColor.uiColor
        let layers = shot.layers
        if layers.isEmpty {
            return
        }

        let layerViews = layers.map({ DrawingUtility.generateLayerView(for: $0) })
        shotView.setUpLayerViews(layerViews, toolPicker: toolPicker, PKDelegate: self)
        updateOnionSkins()
        updateShotTransform()
    }

    private func updateOnionSkins() {
        guard shotView != nil else {
            return
        }
        let redOnionSkin = onionSkinRange.redIndicies.compactMap({ scene.getShot($0, after: shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), { $0.mergeWith($1.redOnionSkin) })
        let greenOnionSkin = onionSkinRange.greenIndicies.compactMap({ scene.getShot($0, after: shot) })
            .reduce(UIImage.solidImage(ofColor: .clear, ofSize: canvasSize), { $0.mergeWith($1.greenOnionSkin) })
        shotView.updateOnionSkins(skins: redOnionSkin.mergeWith(greenOnionSkin))
    }

    private func updateShotTransform() {
        shotView.transform = .identity
        shotView.transform = zoomToFitTransform.concatenating(canvasTransform)
        shotView.center = canvasCenter
    }

    private var panPosition = CGPoint.zero
    private var additionalLayerTransform = CGAffineTransform.identity
}

// MARK: - Gestures
extension ShotDesignerViewController {

    @IBAction private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            panPosition = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let offsetX = location.x - panPosition.x
            let offsetY = location.y - panPosition.y
            panPosition = location

            switch editingMode {
            case .transformLayer:
                transformLayer(
                    using: CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            case .free, .drawing:
                canvasTransform = canvasTransform.concatenating(
                    CGAffineTransform(translationX: offsetX, y: offsetY)
                )
            }
        case .ended:
            switch editingMode {
            case .transformLayer:
                guard selectedLayer.canTransform else {
                    return
                }
                endTransform()
            case .free, .drawing:
                return
            }
        default:
            return
        }
    }

    @IBAction private func handlePinch(_ sender: UIPinchGestureRecognizer) {
        switch editingMode {
        case .transformLayer:
            scaleLayer(sender)
        case .free, .drawing:
            scaleCanvas(sender)
        }
    }

    private func scaleCanvas(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        canvasTransform = canvasTransform.scaledBy(x: scale, y: scale)
    }

    private func scaleLayer(_ sender: UIPinchGestureRecognizer) {
        guard selectedLayer.canTransform else {
            return
        }
        let scale = sender.scale
        sender.scale = 1
        transformLayer(using: CGAffineTransform(scaleX: scale, y: scale))
        if sender.state == .ended {
            endTransform()
        }
    }

    @IBAction private func handleRotation(_ sender: UIRotationGestureRecognizer) {
        switch editingMode {
        case .transformLayer:
            rotateLayer(sender)
        case .free, .drawing:
            rotateCanvas(sender)
        }
    }

    private func rotateCanvas(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        sender.rotation = .zero
        canvasTransform = canvasTransform.rotated(by: rotation)
    }

    private func rotateLayer(_ sender: UIRotationGestureRecognizer) {
        guard selectedLayer.canTransform else {
            return
        }
        let rotation = sender.rotation
        sender.rotation = .zero
        transformLayer(using: CGAffineTransform(rotationAngle: rotation))
        if sender.state == .ended {
            endTransform()
        }
    }

    private func transformLayer(using transform: CGAffineTransform) {
        guard selectedLayer.canTransform else {
            return
        }
        shotView.transformedSelectedLayer(using: transform)
        additionalLayerTransform = additionalLayerTransform.concatenating(transform)
    }
    private func endTransform() {
        guard selectedLayer.canTransform else {
            return
        }
        selectedLayer.transform(using: additionalLayerTransform)

        additionalLayerTransform = .identity
        setUpShot()
        shot.generateThumbnailAndSave()
    }

}

// MARK: - Actions
extension ShotDesignerViewController {

    @IBAction private func zoomToFit() {
        canvasTransform = .identity
        updateShotTransform()
    }

    @IBAction private func duplicateShot(_ sender: UIBarButtonItem) {
        if let index = scene.shots.firstIndex(where: { $0 === shot }) {
            let newShot = shot.duplicate()
            scene.addShot(newShot, at: index + 1)
            nextShot()
        }

    }

    @IBAction private func toggleTransformLayer(_ sender: TransformLayerButton) {
        if editingMode == .transformLayer {
            editingMode = .free
        } else {
            editingMode = .transformLayer
        }
    }

    @IBAction private func toggleDrawingMode(_ sender: DrawingModeButton) {
        if editingMode == .drawing {
            editingMode = .free
        } else {
            editingMode = .drawing
        }
    }

    @IBAction private func nextShot() {
        guard let nextShot = scene.getShot(1, after: shot) else {
            return
        }
        shot = nextShot
        setUpShot()
    }

    @IBAction private func previousShot() {
        guard let prevShot = scene.getShot(-1, after: shot) else {
            return
        }
        shot = prevShot
        setUpShot()
    }
}

// MARK: - PKCanvasViewDelegate
extension ShotDesignerViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        selectedLayer.setDrawing(to: canvasView.drawing)
        shot.generateThumbnailAndSave()
    }
}

// MARK: - PKToolPickerObserver {
extension ShotDesignerViewController: PKToolPickerObserver {
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateShotTransform()
    }
}

// MARK: - Segues
extension ShotDesignerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let layerTable = segue.destination as? LayerTableController {

            shot.observedBy(layerTable)

            layerTable.onionSkinRange = onionSkinRange
            layerTable.selectedLayerIndex = selectedLayerIndex
            layerTable.shot = shot
            layerTable.delegate = self
        }
    }
}
// MARK: - Zoom To Fit Resize
extension ShotDesignerViewController {
    var windowSize: CGSize {
        view.frame.size
    }
    var windowWidth: CGFloat {
        windowSize.width
    }
    var windowHeight: CGFloat {
        windowSize.height
    }

    var topInset: CGFloat {
        view.safeAreaInsets.top
    }
    var bottomInset: CGFloat {
        max(view.safeAreaInsets.bottom, toolPicker.frameObscured(in: view).height)
    }

    var canvasMaxHeight: CGFloat {
        windowHeight - topInset - bottomInset - Constants.verticalCanvasMargin * 2
    }
    var canvasMaxWidth: CGFloat {
        windowWidth - Constants.horizontalCanvasMargin * 2
    }
    var canvasMaxSize: CGSize {
        CGSize(width: canvasMaxWidth, height: canvasMaxHeight)
    }

    var canvasCenterY: CGFloat {
        topInset + Constants.verticalCanvasMargin + canvasMaxHeight / 2
    }
    var canvasCenterX: CGFloat {
        windowWidth / 2
    }
    var canvasCenter: CGPoint {
        CGPoint(x: canvasCenterX, y: canvasCenterY)
    }

    var canvasCenterTranslation: (x: CGFloat, y: CGFloat) {
        (canvasCenterX - shotView.center.x, canvasCenterY - shotView.center.y)
    }

    var canvasScale: CGFloat {
        let widthScale = canvasMaxWidth / shotView.bounds.width
        let heightScale = canvasMaxHeight / shotView.bounds.height
        return min(widthScale, heightScale)
    }

    var zoomToFitTransform: CGAffineTransform {
        CGAffineTransform(scaleX: canvasScale, y: canvasScale)
    }

}

// MARK: - UIGestureRecognizerDelegate
extension ShotDesignerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer is UIRotationGestureRecognizer
            || gestureRecognizer is UIPinchGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
    }
}

extension ShotDesignerViewController: LayerTableDelegate {

    func backgroundColorWillChange(color: UIColor) {
        shotView.backgroundColor = shot.backgroundColor.uiColor
        shot.setBackgroundColor(color: Color(uiColor: color))
        shot.generateThumbnailAndSave()
    }

    func didSelectLayer(at index: Int) {
        selectedLayerIndex = index
    }
    func onionSkinsDidChange() {
        updateOnionSkins()
    }
    func willMoveLayer(from oldIndex: Int, to newIndex: Int) {
        shotView.moveLayer(from: oldIndex, to: newIndex)
        shot.moveLayer(from: oldIndex, to: newIndex)
        shot.generateThumbnailAndSave()
    }

    func didToggleLayerLock(at index: Int) {
        let layer = shot.layers[index]
        layer.isLocked.toggle()
        shotView.updateLayerView(at: index, isLocked: layer.isLocked,
                                 isVisible: layer.isVisible)
        shot.generateThumbnailAndSave()
    }
    func didToggleLayerVisibility(at index: Int) {
        let layer = shot.layers[index]
        layer.isVisible.toggle()
        shotView.updateLayerView(at: index, isLocked: layer.isLocked,
                                 isVisible: layer.isVisible)
        shot.generateThumbnailAndSave()
    }

    func didChangeLayerName(at index: Int, newName: String) {
        let layer = shot.layers[index]
        layer.name = newName
        shot.generateThumbnailAndSave()
    }

    func willAddLayer() {
        let layer = Layer(withDrawing: PKDrawing(), canvasSize: shot.canvasSize)
        shotView.add(layerView: DrawingUtility.generateLayerView(for: layer),
                     toolPicker: toolPicker, PKDelegate: self)
        shot.addLayer(layer)
        selectTopLayer()
        shot.generateThumbnailAndSave()
    }
    private func selectTopLayer() {
        selectedLayerIndex = shot.layers.count - 1
    }
    func willRemoveLayers(at indices: [Int]) {
        guard !indices.isEmpty else {
            return
        }
        shotView.removeLayers(at: indices)
        shot.removeLayers(at: indices)
        shot.generateThumbnailAndSave()
    }

    func willDuplicateLayers(at indices: [Int]) {
        guard !indices.isEmpty else {
            return
        }
        shot.duplicateLayers(at: indices)
        setUpShot()
        shot.generateThumbnailAndSave()
    }

    func willGroupLayers(at indices: [Int]) {
        shot.groupLayers(at: indices)
        setUpShot()
        shot.generateThumbnailAndSave()
    }

    func willUngroupLayer(at index: Int) {
        shot.ungroupLayer(at: index)
        setUpShot()
        shot.generateThumbnailAndSave()
    }
}
// MARK: - UIDropInteractionDelegate
extension ShotDesignerViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: UIImage.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [weak self] imageItems in
            guard let image = imageItems.first as? UIImage,
                  let self = self else {
                return
            }
            let layer = Layer(withImage: image, canvasSize: self.shot.canvasSize)
            self.shot.addLayer(layer)
            self.shotView
                .add(layerView: DrawingUtility.generateLayerView(for: layer),
                     toolPicker: self.toolPicker, PKDelegate: self)
            self.selectTopLayer()
            self.shot.generateThumbnailAndSave()
        }
    }
}
