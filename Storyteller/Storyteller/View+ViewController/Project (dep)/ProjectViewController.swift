//
//  ProjectViewController.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

/* import UIKit

class ProjectViewController: UIViewController {

    enum Mode {
        case view
        case select
    }

    @IBOutlet private var collectionView: UICollectionView!

    var folder = Folder(name: "Root", description: "This is the fixed root folder")
    private var NumOfProjects: Int = 0

    lazy var addBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(didAddButtonClicked(_:))
        )
        return barButtonItem
    }()

    lazy var renameBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Rename",
            style: .plain,
            target: self,
            action: #selector(didRenameButtonClicked(_:))
        )
        return barButtonItem
    }()

    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Select",
            style: .plain,
            target: self,
            action: #selector(didSelectButtonClicked(_:))
        )
        return barButtonItem
    }()

    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(self.didDeleteButtonClicked(_:))
        )
        return barButtonItem
    }()

    override var prefersStatusBarHidden: Bool {
        true
    }

    private var mode: Mode = .view {
        didSet {
            switch self.mode {
            case .view:
                for (key, value) in self.selectedIndexPath where value {
                    self.collectionView.deselectItem(at: key, animated: true)
                }
                self.selectedIndexPath.removeAll()
                self.selectBarButton.title = "Select"
                self.navigationItem.rightBarButtonItems = [self.selectBarButton, self.addBarButton]
                self.navigationItem.leftBarButtonItem = nil
            case .select:
                self.selectBarButton.title = "Cancel"
                self.navigationItem.rightBarButtonItems = [self.selectBarButton]
                self.navigationItem.leftBarButtonItem = self.deleteBarButton
                self.collectionView.allowsMultipleSelection = true
            }
        }
    }

    private var selectedIndexPath: [IndexPath: Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.folder.observedBy(self)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
        self.collectionView.backgroundColor = .systemGray
        self.collectionView.register(
            ProjectViewCell.self,
            forCellWithReuseIdentifier: ProjectViewCell.identifier
        )
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)

        self.NumOfProjects = self.folder.projects.count

        self.navigationItem.title = "My Projects"
        self.navigationItem.rightBarButtonItems = [
            self.selectBarButton, self.addBarButton
        ]
    }

    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        self.mode = self.mode == .view ? .select : .view
    }

    @objc func didDeleteButtonClicked(_ sender: UIBarButtonItem) {
        var toDeleteIndexPath: [IndexPath] = []
        for (key, value) in self.selectedIndexPath where value {
            toDeleteIndexPath.append(key)
        }
        for indexPath in toDeleteIndexPath {
            let index = min(indexPath.row, self.folder.projects.count - 1)
            if let project = self.folder.loadProject(at: index) {
                self.folder.removeProject(project)
            }
        }
        self.selectedIndexPath.removeAll()
        self.mode = .view
    }

    @objc func didAddButtonClicked(_ sender: UIButton) {
        let canvasSize = Constants.defaultCanvasSize
        let projectTitle = "Project \(self.NumOfProjects)"
        let project = Project(name: projectTitle, canvasSize: canvasSize)
        self.folder.addDirectory(project)
        self.NumOfProjects += 1
        self.collectionView.reloadData()
    }

    @objc func didRenameButtonClicked(_ sender: UIButton) {

//        for projectId in self.folder.projectOrder {
//            let project = self.folder.projects[projectId]!
//            let projectLabel = project.label
//            self.folder.removeProject(of: projectLabel)
//        }

        var index = 0
        for (key, value) in self.selectedIndexPath where value {
            index = key.row
        }

        let project = self.folder.loadProject(at: index)
        let projectName = project?.name ?? "UNTITLED"

        let alertController = UIAlertController(
            title: "Rename",
            message: "",
            preferredStyle: .alert
        )
        alertController.addTextField { textField in
            textField.text = projectName
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newProjectName = alertController.textFields?[0].text else {
                return
            }
            guard let project = project else {
                return
            }
            self.folder.renameDirectory(project, to: newProjectName)
            self.collectionView.reloadData()
            self.mode = .view
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ProjectViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let project = self.folder.loadProject(at: indexPath.row)
        guard let projectViewCell = self.collectionView
                .dequeueReusableCell(withReuseIdentifier: ProjectViewCell.identifier,
                                     for: indexPath) as? ProjectViewCell else {
            return UICollectionViewCell()
        }
        projectViewCell.setTitle(to: project?.name ?? "UNTITLED")
        return projectViewCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.mode {
        case .view:
            self.collectionView.deselectItem(at: indexPath, animated: true)
            guard let sceneViewController = self.storyboard?
                    .instantiateViewController(identifier: "SceneViewController") as? SceneViewController else {
                return
            }
            guard let project = self.folder.loadProject(at: indexPath.row) else {
                return
            }
            sceneViewController.modalPresentationStyle = .fullScreen
            sceneViewController.setProject(to: project)
            self.navigationController?.pushViewController(sceneViewController, animated: true)
        case .select:
            self.selectedIndexPath[indexPath] = true
            if self.numberOfSelectedItems() == 1 {
                self.navigationItem.rightBarButtonItems = [self.selectBarButton, self.renameBarButton]
            } else {
                self.navigationItem.rightBarButtonItems = [self.selectBarButton]
            }
         }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if self.mode == .select {
            self.selectedIndexPath[indexPath] = false
            if self.numberOfSelectedItems() == 1 {
                self.navigationItem.rightBarButtonItems = [self.selectBarButton, self.renameBarButton]
            } else {
                self.navigationItem.rightBarButtonItems = [self.selectBarButton]
            }
        }
    }

    func numberOfSelectedItems() -> Int {
        var count = 0
        for (_, value) in self.selectedIndexPath where value {
            count += 1
        }
        return count
    }
}

extension ProjectViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.folder.projects.count
    }

}

extension ProjectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width / 5) - 5
        let itemHeight = (self.view.frame.width / 5) - 5
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        3
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    }
}

// MARK: - FolderObserver
extension ProjectViewController: FolderObserver {
    func modelDidChange() {
        self.collectionView.reloadData()
    }
}
*/
