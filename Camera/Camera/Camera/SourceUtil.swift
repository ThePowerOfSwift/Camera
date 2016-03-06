//
//  UIIMage+Extension.swift
//  ImageLib
//
//  Created by XLHIOS01 on 15/10/16.
//  Copyright © 2015年 XLHIOS01. All rights reserved.
//

import UIKit

class SourceUtil {
    static func imageFromBundleName(name: ImageName) -> UIImage {
        return UIImage(named: "ImageLib.bundle/\(name.rawValue)")!
    }
}

enum ImageName: String {
    case delete = "delete"
    case takePhoto = "takePhoto"
    case camera = "camera"
    case flashlightOn = "flashlightOn"
    case flashlightOff = "flashlightOff"
}