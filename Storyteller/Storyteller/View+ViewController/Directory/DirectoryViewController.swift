//
//  FolderViewController.swift
//  Storyteller
//
//  Created by John Pan on 1/5/21.
//

import UIKit

class DirectoryViewController: UIViewController {

    static let addPopoverSegueIdentifier = "DirectoryAddPopoverSegue"
    static let moveModalSegueIdentifier = "DirectoryMoveModalSegue"
    static let projectSceneViewControllerSegue = "ProjectSceneViewControllerSegue"
    static let defaultFolderName = "Storyteller"
    static let defaultFolderDescription = "Storyteller"

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var rearrangeButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    var folder: Folder = Folder.retrieveMainFolder()
    var observers: [DirectoryViewControllerObserver] = []
    var selectedIndexes: [Int] = []

    var currMode: DirectoryMode = .view {
        didSet {
            switch currMode {
            case .view:
                deleteButton.image = nil
                deleteButton.isEnabled = false
                moveButton.image = nil
                moveButton.isEnabled = false
                rearrangeButton.image = UIImage(systemName: "filemenu.and.cursorarrow.rtl")
                rearrangeButton.isEnabled = true
                selectButton.image = UIImage(systemName: "hand.point.up.left.fill")
                selectButton.isEnabled = true
                addButton.image = UIImage(systemName: "plus")
                addButton.isEnabled = true
                doneButton.title = nil
                doneButton.isEnabled = false
                tableView.isEditing = false
                selectedIndexes = []
                observers.forEach({ $0.didModeChange(to: .view) })
            case .rearrange:
                deleteButton.image = nil
                deleteButton.isEnabled = false
                moveButton.image = nil
                moveButton.isEnabled = false
                rearrangeButton.image = nil
                rearrangeButton.isEnabled = false
                selectButton.image = nil
                selectButton.isEnabled = false
                addButton.image = nil
                addButton.isEnabled = false
                doneButton.title = "Done"
                doneButton.isEnabled = true
                tableView.isEditing = true
                selectedIndexes = []
                self.observers.forEach({ $0.didModeChange(to: .rearrange) })
            case .select:
                deleteButton.image = UIImage(systemName: "trash")
                deleteButton.isEnabled = true
                moveButton.image = UIImage(systemName: "move.3d")
                moveButton.isEnabled = true
                rearrangeButton.image = nil
                rearrangeButton.isEnabled = false
                selectButton.image = nil
                selectButton.isEnabled = false
                addButton.image = nil
                addButton.isEnabled = false
                doneButton.title = "Done"
                doneButton.isEnabled = true
                tableView.isEditing = false
                selectedIndexes = []
                self.observers.forEach({ $0.didModeChange(to: .select) })
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.folder.name

        /// Set the Table View
        self.tableView.register(
            DirectoryTableViewCell.nib(),
            forCellReuseIdentifier: DirectoryTableViewCell.identifier
        )
        self.tableView.delegate = self
        self.tableView.dataSource = self

        /// Set the Current Mode
        self.currMode = .view

        /// ModelManager
        self.folder.observedBy(self)

        self.navigationItem.hidesBackButton = false

        let gesture = UILongPressGestureRecognizer(
            target: self, action: #selector(self.handleLongPressGesture(_:))
        )
        self.tableView.addGestureRecognizer(gesture)
    }

    public func configure(folder: Folder) {
        self.folder = folder
    }
    
    @IBAction func selectButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .select
    }

    @IBAction func rearrangeButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .rearrange
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .view
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    

    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        if currMode == .select {
            folder.deleteChildren(at: selectedIndexes)
            selectedIndexes = []
            currMode = .view
        }
    }

    @IBAction func moveButtonPressed(_ sender: UIBarButtonItem) {

    }

    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = self.tableView.indexPathForRow(
                at: gesture.location(in: self.tableView)) else {
                return
            }

            let targetDirectory = self.folder.children[indexPath.row]

            let alertController = UIAlertController(title: "Rename", message: "Update name and description", preferredStyle: .alert)

            alertController.addTextField{ (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Name"
                textField.text = targetDirectory.name
            }

            alertController.addTextField{ (textField : UITextField!) -> Void in
                textField.placeholder = "Enter Description"
                textField.text = targetDirectory.description
            }


            let saveAction = UIAlertAction(
                title: "Save",
                style: .default,
                handler: { alert -> Void in
                    let nameTextField = alertController.textFields![0] as UITextField
                    let descriptionTextField = alertController.textFields![1] as UITextField
                    let name = nameTextField.text ?? String()
                    let description = descriptionTextField.text ?? String()
                    if let targetFolder = targetDirectory as? Folder {
                        self.folder.renameDirectory(targetFolder, to: name)
                        self.folder.updateDescription(targetFolder, to: description)
                    }
                    else if let targetProject = targetDirectory as? Project {
                        self.folder.renameDirectory(targetProject, to: name)
                        self.folder.updateDescription(targetProject, to: description)
                    }
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
        default:
            return
        }
    }







    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



}


extension DirectoryViewController: UITableViewDelegate {

}


extension DirectoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.folder.swapChildrenAt(index1: sourceIndexPath.row, index2: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.folder.deleteChildren(at: [indexPath.row])
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currMode {

        case .select:

            tableView.deselectRow(at: indexPath, animated: false)

            guard let selectedTableCell = tableView.cellForRow(at: indexPath)
                    as? DirectoryTableViewCell else {
                return
            }

            if selectedTableCell.isDirectorySelected {
                guard let index = selectedIndexes.first(where: { $0 == indexPath.row }) else {
                    return
                }
                selectedIndexes.removeAll(where: { $0 == index })
                selectedTableCell.isDirectorySelected = false
            } else {
                selectedIndexes.append(indexPath.row)
                selectedTableCell.isDirectorySelected = true
            }

        case .rearrange:
            return

        case .view:

            tableView.deselectRow(at: indexPath, animated: false)

            let targetDirectory = self.folder.children[indexPath.row]

            if let targetFolder = targetDirectory as? Folder {
                guard let directoryViewController = self.storyboard?
                        .instantiateViewController(identifier: "DirectoryViewController") as? DirectoryViewController else {
                    return
                }
                directoryViewController.modalPresentationStyle = .fullScreen
                directoryViewController.configure(folder: targetFolder)
                self.navigationController?.pushViewController(directoryViewController, animated: true)
            }

            else if let targetProject = targetDirectory as? Project {
                self.performSegue(withIdentifier: DirectoryViewController.projectSceneViewControllerSegue, sender: targetProject)
            }



        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.children.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: DirectoryTableViewCell.identifier, for: indexPath)
                as? DirectoryTableViewCell else {
            return UITableViewCell()
        }
        let directory = folder.children[indexPath.row]
        let directoryType: DirectoryType = (directory is Project) ? .project : .folder

        tableCell.configure(
            directoryType: directoryType,
            name: directory.name,
            description: directory.description,
            dateUpdated: directory.dateUpdated,
            dateAdded: directory.dateAdded
        )
        self.observers.append(tableCell)
        return tableCell
    }
}

extension DirectoryViewController: UIPopoverPresentationControllerDelegate {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DirectoryViewController.addPopoverSegueIdentifier && self.currMode == .view {
            guard let addPopoverViewController = segue.destination as? DirectoryAddPopoverViewController else {
                return
            }
            addPopoverViewController.modalPresentationStyle = .popover
            addPopoverViewController.preferredContentSize = CGSize(width: 200, height: 100)
            addPopoverViewController.set(delegate: self)

        }

        if segue.identifier == DirectoryViewController.moveModalSegueIdentifier {

            guard let moveModalViewController = segue.destination as? DirectoryMoveModalViewController else {
                return
            }

            let parentFolder: Folder? = folder.parent // as? Folder
            var childrenFolders: [Folder] = []
            for (index, child) in folder.children.enumerated() {
                if !selectedIndexes.contains(index) {
                    if let childFolder = child as? Folder {
                        childrenFolders.append(childFolder)
                    }
                }
            }
            moveModalViewController.configure(parentFolder: parentFolder, childrenFolders:childrenFolders, delegate: self)
        }

        if segue.identifier == DirectoryViewController.projectSceneViewControllerSegue {
            guard let projectSceneViewController = segue.destination as? ProjectSceneViewController else {
                return
            }

            guard let project = sender as? Project else {
                return
            }

            projectSceneViewController.set(project: project)
            projectSceneViewController.modalPresentationStyle = .fullScreen

        }

    }

}

extension DirectoryViewController: DirectoryViewControllerDelegate {

    func didAddProject(project: Project) {
        self.folder.addDirectory(project)
    }

    func didAddFolder(folder: Folder) {
        self.folder.addDirectory(folder)
    }

    func didSelectedDirectoriesMove(to folder: Folder) {
        self.folder.moveChildren(indices: selectedIndexes, to: folder)
        self.currMode = .view
    }

}

extension DirectoryViewController: FolderObserver {
    func modelDidChange() {
        self.tableView.reloadData()
    }
}

protocol DirectoryViewControllerDelegate {
    func didSelectedDirectoriesMove(to folder: Folder)
    func didAddProject(project: Project)
    func didAddFolder(folder: Folder)
}

protocol DirectoryViewControllerObserver {
    func didModeChange(to mode: DirectoryMode)
}
