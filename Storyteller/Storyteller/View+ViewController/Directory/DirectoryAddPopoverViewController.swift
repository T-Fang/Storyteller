//
//  AddPopoverViewController.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import UIKit

class DirectoryAddPopoverViewController: UIViewController {

    var delegate: DirectoryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func set(delegate: DirectoryViewControllerDelegate) {
        self.delegate = delegate
    }

    @IBAction func addProjectButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Project", message: "Add name and description", preferredStyle: .alert)

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Project Name"
        }

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Project Description"
        }


        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { alert -> Void in
                let nameTextField = alertController.textFields![0] as UITextField
                let descriptionTextField = alertController.textFields![1] as UITextField
                let name = nameTextField.text ?? String()
                let description = descriptionTextField.text ?? String()
                let project = Project(name: name, description: description, canvasSize: Constants.defaultCanvasSize)
                self.delegate?.didAddProject(project: project)
                self.dismiss(animated: true, completion: nil)
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

    @IBAction func addDirectoryButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Folder", message: "Add name and description", preferredStyle: .alert)

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Folder Name"
        }

        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Folder Description"
        }


        let saveAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { alert -> Void in
                let nameTextField = alertController.textFields![0] as UITextField
                let descriptionTextField = alertController.textFields![1] as UITextField
                let name = nameTextField.text ?? String()
                let description = descriptionTextField.text ?? String()
                let folder = Folder(name: name, description: description)
                self.delegate?.didAddFolder(folder: folder)
                self.dismiss(animated: true, completion: nil)
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
