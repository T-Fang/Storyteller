//
//  UIImage+scaleToFit.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

import UIKit

extension UIImage {
    func scaleToFit(_ size: CGSize) -> UIImage {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let newSize = CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let image = renderer.image { _ in
            self.draw(in: newSize.rectAtOrigin)
        }
        return image
    }
}
