//
//  Thumbnail.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//
import UIKit
struct Thumbnail {
    var thumbnail: Data
    var redThumbnail: Data
    var greenThumbnail: Data

    init(defaultThumbnail: UIImage = Constants.clearImage,
         redOnionSkin: UIImage = Constants.clearImage,
         greenOnionSkin: UIImage = Constants.clearImage) {
        self.thumbnail = defaultThumbnail.pngData()!
        self.redThumbnail = redOnionSkin.pngData()!
        self.greenThumbnail = greenOnionSkin.pngData()!
    }
}

extension Thumbnail: Codable {
}

extension Thumbnail {
    var defaultThumbnail: UIImage {
        UIImage(data: thumbnail)!
    }
    var redOnionSkin: UIImage {
        UIImage(data: redThumbnail)!
    }
    var greenOnionSkin: UIImage {
        UIImage(data: greenThumbnail)!
    }
}
