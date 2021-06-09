//
//  SceneHeaderView.swift
//  Storyteller
//
//  Created by John Pan on 21/3/21.
//

import UIKit

class SceneHeaderView: UICollectionReusableView {
    static let identifier = "SceneHeaderView"

    private var index: Int?
    weak var delegate: SceneHeaderDelegate?

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    private let delete: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.setTitle("DELETE", for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return button
    }()

    func configure(sceneIndex: Int, delegate: SceneHeaderDelegate) {
        self.index = sceneIndex
        self.backgroundColor = .gray
        self.label.text = "  Scene \(sceneIndex)"
        self.addSubview(self.label)
        self.addSubview(self.delete)
        self.delegate = delegate
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
        self.delete.frame = CGRect(
            x: self.bounds.maxX - 100,
            y: self.bounds.minY,
            width: 100,
            height: self.bounds.height
        )
    }

    @objc func deleteAction(sender: UIButton!) {
        if let index = self.index {
            self.delegate?.didDeleteScene(at: index)
        }
    }
}

protocol SceneHeaderDelegate: AnyObject {
    func didDeleteScene(at index: Int)
}
