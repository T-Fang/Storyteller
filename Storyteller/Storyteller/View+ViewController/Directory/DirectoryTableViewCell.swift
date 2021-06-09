//
//  FolderTableViewCell.swift
//  Storyteller
//
//  Created by John Pan on 1/5/21.
//

import UIKit

class DirectoryTableViewCell: UITableViewCell {

    static let identifier: String = "DirectoryTableViewCell"
    static let defaultName: String = "New Folder"
    static let defaultDescription: String = ""
    static let defaultFolderType: DirectoryType = .folder
    static let dateFormatter: String = "yyyy-MM-dd HH:mm"

    static func nib() -> UINib {
        return UINib(nibName: "DirectoryTableViewCell", bundle: nil)
    }

    @IBOutlet weak var directoryImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateUpdatedLabel: UILabel!
    @IBOutlet weak var dateAddedLabel: UILabel!
    @IBOutlet weak var symbolImageView: UIImageView!

    var directoryName: String = defaultName {
        didSet {
            nameLabel.text = directoryName
        }
    }

    var directoryType: DirectoryType = DirectoryTableViewCell.defaultFolderType {
        didSet {
            switch directoryType {
            case .folder:
                directoryImageView.image = UIImage(named: "folder")
            case .project:
                directoryImageView.image = UIImage(named: "project")
            }
        }
    }

    var directoryDescription: String = defaultDescription {
        didSet {
            descriptionLabel.text = directoryDescription
        }
    }

    var dateUpdated: Date = Date() {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = DirectoryTableViewCell.dateFormatter
            dateUpdatedLabel.text = formatter.string(from: dateUpdated)
        }
    }

    var dateAdded: Date = Date() {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = DirectoryTableViewCell.dateFormatter
            dateAddedLabel.text = formatter.string(from: dateAdded)
        }
    }

    var currMode: DirectoryMode = .view {
        didSet {
            switch currMode {
            case .view:
                symbolImageView.image = nil
                isDirectorySelected = false
            case .rearrange:
                symbolImageView.image = UIImage(named: "move-arrows")
            case .select:
                symbolImageView.image = nil
            }
        }
    }

    var isDirectorySelected: Bool = false {
        didSet {
            if isDirectorySelected {
                backgroundColor = .systemGray4
                symbolImageView.image = UIImage(named: "select-tick")
            } else {
                backgroundColor = .white
                symbolImageView.image = nil
            }
        }
    }



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(
        directoryType: DirectoryType,
        name: String,
        description: String,
        dateUpdated: Date,
        dateAdded: Date
    ) {
        self.directoryType = directoryType
        self.directoryName = name
        self.directoryDescription = description
        self.dateUpdated = dateUpdated
        self.dateAdded = dateAdded
        self.currMode = .view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    public func toggleSelected() {
        if isDirectorySelected {
            isDirectorySelected = false
        } else {
            isDirectorySelected = true
        }
    }
    
}

extension DirectoryTableViewCell: DirectoryViewControllerObserver {
    func didModeChange(to mode: DirectoryMode) {
        self.currMode = mode
    }
}
