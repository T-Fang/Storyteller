//
//  UIImage+solidImage.swift
//  Storyteller
//
//  Created by TFang on 31/3/21.
//

import UIKit

extension UIImage {
    static func solidImage(ofColor color: UIColor, ofSize size: CGSize) -> UIImage {
        let rect = size.rectAtOrigin

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }
}
