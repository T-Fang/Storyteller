//
//  UIImage+mergeWith.swift
//  Storyteller
//
//  Created by TFang on 28/3/21.
//
import UIKit

/// Adapted from:
/// https://stackoverflow.com/questions/32006128/how-to-merge-two-uiimages
extension UIImage {
  func mergeWith(_ topImage: UIImage) -> UIImage {
    let bottomImage = self

    UIGraphicsBeginImageContext(size)

    let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
    bottomImage.draw(in: areaSize)

    topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

    let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return mergedImage
  }
}
