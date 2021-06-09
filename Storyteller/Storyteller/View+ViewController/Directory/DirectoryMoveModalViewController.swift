//
//  DirectoryMoveModalViewController.swift
//  Storyteller
//
//  Created by John Pan on 2/5/21.
//

import UIKit

class DirectoryMoveModalViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var parentFolder: Folder?
    var childrenFolders: [Folder] = []

    var delegate: DirectoryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    public func configure(
        parentFolder: Folder?,
        childrenFolders: [Folder],
        delegate: DirectoryViewControllerDelegate
    ) {
        self.parentFolder = parentFolder
        self.childrenFolders = childrenFolders
        self.delegate = delegate
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {

        guard let indexPath = tableView.indexPathForSelectedRow else {
            self.dismiss(animated: false, completion: nil)
            return
        }

        if indexPath.section == 0 {
            guard let folder = parentFolder else {
                self.dismiss(animated: false, completion: nil)
                return
            }
            delegate?.didSelectedDirectoriesMove(to: folder)
            self.dismiss(animated: false, completion: nil)
        } else {
            let folder = childrenFolders[indexPath.row]
            delegate?.didSelectedDirectoriesMove(to: folder)
            self.dismiss(animated: false, completion: nil)
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

extension DirectoryMoveModalViewController: UITableViewDelegate {

}

extension DirectoryMoveModalViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if parentFolder == nil {
                tableView.deselectRow(at: indexPath, animated: false)
            } else {

            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "..."
        } else {
            return "Folders"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return childrenFolders.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MoveCell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = parentFolder != nil ? parentFolder?.name : String()
            return cell
        } else {
            cell.textLabel?.text = childrenFolders[indexPath.row].name
        }

        return cell
    }
}
