//
//  ViewController.swift
//  Camera
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func takePhoto(sender: AnyObject) {
        
        let cameraVc = CameraViewController()
        // 拍照最多个数
        cameraVc.maxCount = 6
        cameraVc.callback = { photos in
            print(photos.count)
            
            self.imageView.stopAnimating()
            if photos.count == 1 { // 单张图片
                self.imageView.image = photos.last!.thumbImage
                
            } else { // 多张图片
                var images = [UIImage]()
                for photo in photos {
                    images.append(photo.thumbImage)
                }
                self.imageView.animationImages = images
                self.imageView.animationDuration = 0.6
                self.imageView.startAnimating()
            }
        }
        
        presentViewController(cameraVc, animated: true, completion: nil)
        
    }

}

