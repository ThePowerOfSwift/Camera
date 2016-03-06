//
//  CameraImageView.swift
//  Camera
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit

protocol CameraImageViewDelegate: NSObjectProtocol {
    
    func deleteImageView(imageView: CameraImageView)
}

class CameraImageView: UIImageView {
    
    var delegate: CameraImageViewDelegate?
    
    // 是否是编辑模式
    var edit = false {
        didSet {
            deleteSign.hidden = !edit
        }
    }
    
    var deleteSign: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        userInteractionEnabled = true
        
        deleteSign = UIImageView(frame: CGRect(x: 50, y: 0, width: 25, height: 25))
        deleteSign.image = SourceUtil.imageFromBundleName(ImageName.delete)
        deleteSign.hidden = true
        deleteSign.userInteractionEnabled = true
        deleteSign.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "deleteImage:"))

        addSubview(deleteSign)
    }
    
    func deleteImage(sender: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.deleteImageView(self)
        }
    }
}
