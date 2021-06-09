//
//  ProjectSceneViewController.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import UIKit

class ProjectSceneViewController: UIViewController {

    static let shotDesignerViewControllerSegueIdentifier = "ShotDesignerViewControllerSegue"
    static let defaultProjectName = "My Project"

    var project: Project = Project(
        name: ProjectSceneViewController.defaultProjectName,
        canvasSize: Constants.defaultCanvasSize
    )

    @IBOutlet var sceneTableView: UITableView!

    enum Mode {
        case view
        case select
        case reorder
    }

    var currentMode: Mode = .view {
        didSet {
            switch self.currentMode {
            case .view:
                self.sceneTableView.isEditing = false
                self.navigationItem.rightBarButtonItems = [
                    self.addSceneButton,  self.reorderScenesButton, self.deleteSceneButton, self.duplicateSceneButton
                ]
            case .select:
                return
            case .reorder:
                self.sceneTableView.isEditing = true
                self.navigationItem.rightBarButtonItems = [
                    self.doneButton
                ]
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Project (Mock)


        /// Navigation Bar
        self.navigationItem.title = self.project.name

        /// Current Mode
        self.currentMode = .view

        /// Scene Table
        self.sceneTableView.register(
            SceneTableViewCell.nib(),
            forCellReuseIdentifier: SceneTableViewCell.identifier
        )
        self.sceneTableView.delegate = self
        self.sceneTableView.dataSource = self

        /// Observer
        self.project.observedBy(self)
    }

    public func set(project: Project) {
        self.project = project
    }

    // MARK: - Add Scene Button
    lazy var addSceneButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(self.didAddSceneButtonPressed(_:))
        )
    }()

    @objc func didAddSceneButtonPressed(_ sender: UIButton) {
        self.addSceneAlert()
    }

    // MARK: - Reorder Scenes Button
    lazy var reorderScenesButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "filemenu.and.cursorarrow"),
            style: .plain,
            target: self,
            action: #selector(self.didReorderScenesButtonPressed(_:))
        )
    }()

    @objc func didReorderScenesButtonPressed(_ sender: UIButton) {
        self.currentMode = .reorder
    }

    // MARK: - Done Button
    lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(self.didDoneButtonPressed(_:))
        )
    }()

    @objc func didDoneButtonPressed(_ sender: UIButton) {
        self.currentMode = .view
    }

    // MARK: - Delete Scene Button
    lazy var deleteSceneButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(self.didDeleteSceneButtonPressed(_:))
        )
    }()

    @objc func didDeleteSceneButtonPressed(_ sender: UIButton) {
        guard let index = self.sceneTableView.indexPathForSelectedRow?.row else {
            return
        }
        self.project.deleteScene(at: index)
    }

    // MARK: - Delete Scene Button
    lazy var duplicateSceneButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc.fill"),
            style: .plain,
            target: self,
            action: #selector(self.didDuplicateSceneButtonPressed(_:))
        )
    }()

    @objc func didDuplicateSceneButtonPressed(_ sender: UIButton) {
        guard let index = self.sceneTableView.indexPathForSelectedRow?.row else {
            return
        }
        let scene = self.project.scenes[index]
        let newScene = scene.duplicate()
        self.project.insertScene(newScene, at: index + 1)
    }

}


// MARK: - Segue
extension ProjectSceneViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ProjectSceneViewController.shotDesignerViewControllerSegueIdentifier {
            guard let shotDesignerController = segue.destination as? ShotDesignerViewController else {
                return
            }

            guard let data = sender as? (Scene, Shot) else {
                return
            }

            shotDesignerController.scene = data.0
            shotDesignerController.shot = data.1

            shotDesignerController.modalPresentationStyle = .fullScreen
        }
    }
}

extension ProjectSceneViewController {

    static let addSceneTitle = "Add Scene"
    static let addSceneMessage = "Add name and description"
    static let addSceneNamePlaceholder = "Enter Scene Name"
    static let addSceneDescriptionPlaceholder = "Enter Scene Description"

    func addSceneAlert() {
        let alertController = UIAlertController(
            title: ProjectSceneViewController.addSceneTitle,
            message: ProjectSceneViewController.addSceneMessage,
            preferredStyle: .alert
        )

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = ProjectSceneViewController.addSceneNamePlaceholder
        }

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = ProjectSceneViewController.addSceneDescriptionPlaceholder
        }


        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { alert -> Void in
                let nameTextField = alertController.textFields![0] as UITextField
                let descriptionTextField = alertController.textFields![1] as UITextField
                let name = nameTextField.text ?? String()
                let description = descriptionTextField.text ?? String()
                let newScene = Scene(name: name, canvasSize: Constants.defaultCanvasSize, description: description)
                let newShot = Shot(canvasSize: Constants.defaultCanvasSize, backgroundColor: Color(uiColor: .white))
                newScene.addShot(newShot)
                self.project.addScene(newScene)
            }
        )

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default, handler: {
            (action : UIAlertAction!) -> Void in }
        )

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

}



extension ProjectSceneViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.project.scenes.count
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sceneTableCell = tableView.dequeueReusableCell(withIdentifier: SceneTableViewCell.identifier, for: indexPath)
                as? SceneTableViewCell else {
            return UITableViewCell()
        }
        let scene = self.project.scenes[indexPath.row]
        sceneTableCell.set(scene: scene, delegate: self)
        return sceneTableCell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.project.scenes.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }


}


extension ProjectSceneViewController: ProjectObserver {
    func modelDidChange() {
        self.sceneTableView.reloadData()
    }
}

extension ProjectSceneViewController: ProjectSceneViewControllerDelegate {
    func didShowShotDesigner(scene: Scene, shot: Shot) {
        performSegue(
            withIdentifier: ProjectSceneViewController.shotDesignerViewControllerSegueIdentifier,
            sender: (scene, shot)
        )
    }

    func present(alert: UIAlertController) {
        self.present(alert, animated: false, completion: nil)
    }
}


protocol ProjectSceneViewControllerDelegate {
    func didShowShotDesigner(scene: Scene, shot: Shot)
    func present(alert: UIAlertController)
}
