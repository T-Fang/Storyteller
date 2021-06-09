//
//  ShotCollectionViewCell.swift
//  Storyteller
//
//  Created by John Pan on 5/5/21.
//

import UIKit

class ShotCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "ShotCollectionViewCell"

    @IBOutlet weak var shotImage: UIImageView!
    @IBOutlet weak var highlightIndicator: UIView!
    @IBOutlet weak var selectIndicator: UIImageView!


    var shot: Shot = Shot(
        canvasSize: Constants.defaultCanvasSize,
        backgroundColor: Color(uiColor: .white)
    )

//    override var isHighlighted: Bool {
//        didSet {
//            self.highlightIndicator.isHidden = !self.isHighlighted
//        }
//    }
//
    override var isSelected: Bool {
        didSet {
            self.highlightIndicator.isHidden = !self.isSelected
            self.selectIndicator.isHidden = !self.isSelected
        }
    }

    static func nib() -> UINib {
        return UINib(nibName: ShotCollectionViewCell.identifier, bundle: nil)
    }

    public func set(shot: Shot) {
        self.shot = shot
        self.updateShotView()
        self.shot.observedBy(self)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updateShotView() {
        self.shotImage.image = self.shot.defaultThumbnail
    }

}

extension ShotCollectionViewCell: ShotObserver {
    func modelDidChange() {
        self.updateShotView()
    }
}
