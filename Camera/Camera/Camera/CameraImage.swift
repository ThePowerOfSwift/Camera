//
//  CameraImage.swift
//  Camera
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit

class CameraImage: NSObject {
    var imagePath: String!
    var thumbImage: UIImage!
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: imagePath)
    }
}
