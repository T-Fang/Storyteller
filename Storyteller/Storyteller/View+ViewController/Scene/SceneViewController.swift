//
//  SceneViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import PencilKit

class SceneViewController: UIViewController {

    @IBOutlet private var collectionView: UICollectionView!

    var project: Project?

    lazy var addSceneBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Add Scene",
            style: .plain,
            target: self,
            action: #selector(didAddSceneButtonClicked(_:))
        )
        return barButtonItem
    }()

    func setProject(to project: Project) {
        self.project = project
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isOpaque = true

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .systemGray
        self.collectionView.register(
            SceneShotViewCell.self,
            forCellWithReuseIdentifier: SceneShotViewCell.identifier
        )
        self.collectionView.register(
            AddShotViewCell.self,
            forCellWithReuseIdentifier: AddShotViewCell.identifier
        )
        self.collectionView.register(
            SceneHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SceneHeaderView.identifier
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.view.addSubview(collectionView)

        guard let project = self.project else {
            return
        }

        project.observedBy(self)
        project.scenes.forEach {
            $0.shots.forEach {
                // for thumbnail updates
                $0.observedBy(self)
            }
        }
        self.navigationItem.title = project.name
        self.navigationItem.rightBarButtonItem = self.addSceneBarButton

        let gesture = UILongPressGestureRecognizer(
            target: self, action: #selector(self.handleLongPressGesture(_:))
        )
        self.collectionView.addGestureRecognizer(gesture)
    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = self.collectionView.indexPathForItem(
                    at: gesture.location(in: self.collectionView)
            ) else {
                return
            }
            self.collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.collectionView))
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }

    @objc func didAddSceneButtonClicked(_ sender: Any) {
        guard let project = self.project else {
            return
        }

        let newScene = Scene(name: "new", canvasSize: Constants.defaultCanvasSize)
        project.addScene(newScene)
        self.collectionView.reloadData()
    }

    func deleteScene(at index: Int) {
        project?.deleteScene(at: index)
    }
}

extension SceneViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let sceneCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: SceneShotViewCell.identifier,
                                     for: indexPath) as? SceneShotViewCell,
              let addCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: AddShotViewCell.identifier,
                                     for: indexPath) as? AddShotViewCell else {
            return UICollectionViewCell()
        }
        guard let project = self.project
        else {
            return UICollectionViewCell()
        }

        let scene = project.loadScene(at: indexPath.section)

        if let scene = scene, indexPath.row < scene.shots.count {

            let shot = scene.loadShot(at: indexPath.row)
            if let shot = shot, !shot.layers.isEmpty {
                sceneCell.setImage(image: shot.defaultThumbnail)
//
//                let thumbnail = shot.orderedLayers[0].drawing
//                    .image(from: CGRect(x: 0, y: 0,
//                                        width: Constants.screenWidth,
//                                        height: Constants.screenHeight), scale: 1.0)
//                sceneCell.setImage(image: thumbnail)
            }
            return sceneCell
        } else {
            return addCell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sceneHeader = self.collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SceneHeaderView.identifier, for: indexPath) as? SceneHeaderView else {
            fatalError("cannot get scene header!")
        }
        sceneHeader.configure(sceneIndex: indexPath.section, delegate: self)
        return sceneHeader
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)

        guard let shotDesignerController = self.storyboard?
                .instantiateViewController(identifier: "ShotDesignerViewController")
                as? ShotDesignerViewController else {
            return
        }
        shotDesignerController.modalPresentationStyle = .fullScreen

        guard let project = self.project
        else {
            return
        }
        guard let scene = project.loadScene(at: indexPath.section) else {
            return
        }

        if let shot = scene.loadShot(at: indexPath.row) {
            shotDesignerController.shot = shot
            shotDesignerController.scene = scene
            shotDesignerController.modalTransitionStyle = .flipHorizontal
            self.navigationController?.pushViewController(shotDesignerController, animated: true)
        } else {
            let newShot = Shot(canvasSize: scene.canvasSize, backgroundColor: Color(uiColor: .white))
            /* if newShot.layers.isEmpty {
                let layer = Layer(withDrawing: PKDrawing(), canvasSize: newShot.canvasSize)
                newShot.addLayer(layer)
            } */
            scene.addShot(newShot)
            self.collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        true
    }

    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section != destinationIndexPath.section {
            return
        }

        guard let project = self.project
        else {
            return
        }

        let scene = project.loadScene(at: sourceIndexPath.section)
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        scene?.swapShots(sourceIndex, destinationIndex)
    }
}

extension SceneViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let project = self.project
        else {
            return 0
        }
        let scene = project.loadScene(at: section)
        return (scene?.shots.count ?? -1) + 1
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let project = self.project else {
            return 0
        }
        return project.scenes.count
    }
}

extension SceneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width / 10) - 8
        let itemHeight = (self.view.frame.width / 10) - 8
        return CGSize(width: itemWidth, height: itemHeight)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: self.view.frame.size.width, height: 50)
    }

}

// MARK: - FolderObserver
extension SceneViewController: ProjectObserver, ShotObserver {
    func modelDidChange() {
        collectionView.reloadData()
    }
}

extension SceneViewController: SceneHeaderDelegate {
    func didDeleteScene(at index: Int) {
        self.deleteScene(at: index)
    }
}
