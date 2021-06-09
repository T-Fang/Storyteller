//
//  SceneTableViewCell.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import UIKit

class SceneTableViewCell: UITableViewCell {

    static let identifier: String = "SceneTableViewCell"
    static let defaultSceneName = "New Scene"
    static let defaultSceneDescription = "Scene Description"
    static let dateFormatter: String = "yyyy-MM-dd HH:mm"

    enum Mode {
        case view
        case select
    }

    @IBOutlet weak var sceneNameLabel: UILabel!
    @IBOutlet weak var sceneDescriptionLabel: UILabel!
    @IBOutlet weak var sceneDateUpdatedLabel: UILabel!
    @IBOutlet weak var sceneDateAddedLabel: UILabel!

    @IBOutlet weak var shotsCollectionView: UICollectionView!

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!


    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!

    var scene: Scene = Scene(
        name: defaultSceneName,
        canvasSize: Constants.defaultCanvasSize,
        description: defaultSceneDescription
    )

    var viewControllerDelegate: ProjectSceneViewControllerDelegate?

    var clipboardUtility: ClipboardUtility = ClipboardUtility()


    var currentMode: Mode = .view {
        didSet {
            switch self.currentMode {
            case .view:
                self.addButton.isHidden = false
                self.editButton.isHidden = false
                self.selectButton.isHidden = false
                self.pasteButton.isHidden = false
                self.copyButton.isHidden = true
                self.deleteButton.isHidden = true
                self.doneButton.isHidden = true
                self.shotsCollectionView.allowsMultipleSelection = false
                self.shotsCollectionView.backgroundColor = .systemGray6
                for (key, _) in self.selectedIndexPaths {
                    self.shotsCollectionView.deselectItem(at: key, animated: false)
                }
                self.selectedIndexPaths.removeAll()
            case .select:
                self.addButton.isHidden = true
                self.editButton.isHidden = true
                self.selectButton.isHidden = true
                self.pasteButton.isHidden = true
                self.copyButton.isHidden = false
                self.deleteButton.isHidden = false
                self.doneButton.isHidden = false
                self.shotsCollectionView.allowsMultipleSelection = true
                self.shotsCollectionView.backgroundColor = .systemGray5
            }
        }
    }

    var selectedIndexPaths: [IndexPath: Bool] = [:]

    static func nib() -> UINib {
        return UINib(nibName: SceneTableViewCell.identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shotsCollectionView.register(
            ShotCollectionViewCell.nib(),
            forCellWithReuseIdentifier: ShotCollectionViewCell.identifier
        )
        self.shotsCollectionView.delegate = self
        self.shotsCollectionView.dataSource = self

        self.currentMode = .view

        let gesture = UILongPressGestureRecognizer(
            target: self, action: #selector(self.handleLongPressGesture(_:))
        )
        self.shotsCollectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = self.shotsCollectionView.indexPathForItem(
                    at: gesture.location(in: self.shotsCollectionView)
            ) else {
                return
            }
            self.shotsCollectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            self.shotsCollectionView.updateInteractiveMovementTargetPosition(
                gesture.location(in: self.shotsCollectionView)
            )
        case .ended:
            self.shotsCollectionView.endInteractiveMovement()
        default:
            self.shotsCollectionView.cancelInteractiveMovement()
        }
    }

    func set(scene: Scene, delegate: ProjectSceneViewControllerDelegate) {
        self.scene = scene
        self.updateSceneView()
        self.scene.observedBy(self)
        self.viewControllerDelegate = delegate
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateSceneView() {
        self.sceneNameLabel.text = !self.scene.name.isEmpty ? self.scene.name : SceneTableViewCell.defaultSceneName
        self.sceneDescriptionLabel.text = "Description: " + self.scene.description

        let formatter = DateFormatter()
        formatter.dateFormat = DirectoryTableViewCell.dateFormatter
        self.sceneDateUpdatedLabel.text = "Date Updated: " + formatter.string(from: self.scene.dateUpdated)
        self.sceneDateAddedLabel.text = "Date Added: " + formatter.string(from: self.scene.dateAdded)

        self.shotsCollectionView.reloadData()
    }

    @IBAction func editButtonPressed(_ sender: UIButton) {
        self.editSceneAlert(sceneName: self.scene.name, sceneDescription: self.scene.description)
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        let shot = Shot(canvasSize: self.scene.canvasSize, backgroundColor: Color(uiColor: .white))
        self.scene.addShot(shot)
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        var deleteNeededIndexes: [Int] = []

        for (key, value) in self.selectedIndexPaths {
            if value {
                deleteNeededIndexes.append(key.row)
            }
        }

        for i in deleteNeededIndexes.sorted(by: { $0 > $1 }) {
            let shot = self.scene.shots[i]
            self.scene.removeShot(shot)
        }

        self.currentMode = .view
    }

    @IBAction func selectButtonPressed(_ sender: UIButton) {
        self.currentMode = .select
    }

    @IBAction func pasteButtonPressed(_ sender: UIButton) {
        let shotsToBePasted = self.clipboardUtility.paste()
        for shot in shotsToBePasted {
            self.scene.addShot(shot)
        }
    }

    @IBAction func copyButtonPressed(_ sender: UIButton) {
        var shotsSelected: [Shot] = []

        for (key, value) in self.selectedIndexPaths {
            if value {
                guard let shot = self.scene.loadShot(at: key.row) else {
                    return
                }
                shotsSelected.append(shot)
            }
        }
        self.clipboardUtility.copy(shotsSelected)
        self.currentMode = .view
    }

    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.currentMode = .view
    }



}

extension SceneTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.scene.shots.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.currentMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: false)
            guard let shot = self.scene.loadShot(at: indexPath.row) else {
                return
            }
            self.viewControllerDelegate?.didShowShotDesigner(scene: self.scene, shot: shot)
        case .select:
            self.selectedIndexPaths[indexPath] = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.selectedIndexPaths[indexPath] = false
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let shotCollectionCell = self.shotsCollectionView.dequeueReusableCell(withReuseIdentifier: ShotCollectionViewCell.identifier, for: indexPath)
            as? ShotCollectionViewCell else {
                return UICollectionViewCell()
            }
        guard let shot = self.scene.loadShot(at: indexPath.row) else {
            return UICollectionViewCell()
        }
        shotCollectionCell.set(shot: shot)
        return shotCollectionCell
    }


    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            return
        }

        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        self.scene.swapShots(sourceIndex, destinationIndex)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
}

extension SceneTableViewCell {

    static let editSceneTitle = "Edit Scene"
    static let editSceneMessage = "Edit name and description"
    static let editSceneNamePlaceholder = "Enter Scene Name"
    static let editSceneDescriptionPlaceholder = "Enter Scene Description"

    func editSceneAlert(sceneName: String, sceneDescription: String) {

        let alertController = UIAlertController(
            title: SceneTableViewCell.editSceneTitle,
            message: SceneTableViewCell.editSceneMessage,
            preferredStyle: .alert
        )

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.text = sceneName
            textField.placeholder = SceneTableViewCell.editSceneNamePlaceholder
        }

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.text = sceneDescription
            textField.placeholder = SceneTableViewCell.editSceneDescriptionPlaceholder
        }


        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { alert -> Void in
                let nameTextField = alertController.textFields![0] as UITextField
                let descriptionTextField = alertController.textFields![1] as UITextField
                let name = nameTextField.text ?? String()
                let description = descriptionTextField.text ?? String()
                self.scene.rename(to: name)
                self.scene.updateDescription(to: description)
            }
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default, handler: {
            (action : UIAlertAction!) -> Void in }
        )

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.viewControllerDelegate?.present(alert: alertController)
    }
}


extension SceneTableViewCell: SceneObserver {
    func modelDidChange() {
        self.updateSceneView()
    }
}
