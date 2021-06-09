//
//  Thumbnailable.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//
import UIKit
protocol Thumbnailable {
    var thumbnail: Thumbnail { get }
}
extension Thumbnailable {
    var defaultThumbnail: UIImage {
        thumbnail.defaultThumbnail
    }
    var redOnionSkin: UIImage {
        thumbnail.redOnionSkin
    }
    var greenOnionSkin: UIImage {
        thumbnail.greenOnionSkin
    }
}
