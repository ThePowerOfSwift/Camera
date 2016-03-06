//
//  CameraViewController.swift
//  Camera
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO

typealias CameraCallBack = ([CameraImage]) -> Void

let CameraColletionViewW: CGFloat = 80
let CameraColletionViewPadding: CGFloat = 20
let BOTTOM_HEIGHT: CGFloat = 60

class CameraViewController: UIViewController {

    var caramView: CameraView!
    var collectionView: UICollectionView!
    var currentViewController: UIViewController!
    
    // Datas
    var images = [CameraImage]()
    var dictM = [String: AnyObject]()
    
    // AVFoundation
    var session: AVCaptureSession!
    var captureOutput: AVCaptureStillImageOutput!
    var device: AVCaptureDevice!
    
    var input: AVCaptureDeviceInput!
    var output: AVCaptureMetadataOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    // 顶部View
    var topView: UIView!
    
    // 底部View
    var controlView: UIView!
    
    // 拍照的个数限制
    var maxCount = 0
    
    // 完成后回调
    var callback: CameraCallBack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        setupUI()
        if let session = session {
            session.startRunning()
        }
    }
    
    func initialize() {
        // 创建会话层
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Input
        input = try! AVCaptureDeviceInput(device: device)
        
        // Output
        captureOutput = AVCaptureStillImageOutput()
        let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureOutput.outputSettings = outputSettings
        
        // Session
        session = AVCaptureSession()
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(captureOutput) {
            session.addOutput(captureOutput)
        }
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = view.bounds
        
        caramView = CameraView(frame: CGRect(x: 0, y: 40, width: view.frame.width, height: view.frame.height - 40 - BOTTOM_HEIGHT))
        
        caramView.backgroundColor = UIColor.clearColor()
        caramView.delegate = self
        view.addSubview(caramView)
        view.layer.insertSublayer(preview, atIndex:0)
    }
    
    func setupButtonWithImageName(imageName: ImageName, x: CGFloat) -> UIButton {
        let button = UIButton(type: UIButtonType.Custom)
        button.setImage(SourceUtil.imageFromBundleName(imageName), forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.clearColor()
        button.frame = CGRect(x: x, y: 0, width: 50, height: topView.frame.height)

        view.addSubview(button)
        return button
    }
    
    func setupUI() {
        UIApplication.sharedApplication().statusBarHidden = true
        
        let width: CGFloat = 50
        let margin: CGFloat = 20
        
        topView = UIView()
        topView.backgroundColor = UIColor.blackColor()
        topView.frame = CGRectMake(0, 0, view.frame.width, 40)
        view.addSubview(topView)
        
        // 头部View
        let deviceBtn = setupButtonWithImageName(ImageName.camera, x: view.frame.width - margin - width)
        deviceBtn.addTarget(self, action: "changeCameraDevice:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let flashBtn = setupButtonWithImageName(ImageName.flashlightOn, x: 10)
        flashBtn.addTarget(self, action: "flashCameraDevice:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let closeBtn = setupButtonWithImageName(ImageName.flashlightOff, x: 60)
        closeBtn.addTarget(self, action: "closeFlashlight:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // 底部View
        controlView = UIView(frame: CGRect(x: 0, y: view.frame.height - BOTTOM_HEIGHT, width: view.frame.width, height: BOTTOM_HEIGHT))
        controlView.backgroundColor = UIColor.clearColor()
        controlView.autoresizingMask = [UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleWidth]
        
        let contentView = UIView()
        contentView.frame = controlView.bounds
        contentView.backgroundColor = UIColor.blackColor()
        contentView.alpha = 0.3
        controlView.addSubview(contentView)
        
        let x = (view.frame.width - width) / 3
        // 取消
        let cancalBtn = UIButton(type: UIButtonType.Custom)
        cancalBtn.frame = CGRectMake(margin, 0, x, controlView.frame.height)
        cancalBtn.setTitle("取消", forState: UIControlState.Normal)
        cancalBtn.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        controlView.addSubview(cancalBtn)
        
        // 拍照
        let cameraBtn = UIButton(type: UIButtonType.Custom)
        cameraBtn.frame = CGRectMake(x+margin, margin / 4, x, controlView.frame.height - margin / 2)
        cameraBtn.showsTouchWhenHighlighted = true
        cameraBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cameraBtn.setImage(SourceUtil.imageFromBundleName(ImageName.takePhoto), forState: UIControlState.Normal)
        cameraBtn.addTarget(self, action: "stillImage:", forControlEvents: UIControlEvents.TouchUpInside)
        controlView.addSubview(cameraBtn)
        
        // 完成
        let doneBtn = UIButton(type: UIButtonType.Custom)
        doneBtn.frame = CGRectMake(view.frame.width - 2 * margin - width, 0, width, controlView.frame.height)
        doneBtn.setTitle("完成", forState: UIControlState.Normal)
        doneBtn.addTarget(self, action: "doneAction", forControlEvents: UIControlEvents.TouchUpInside)
        controlView.addSubview(doneBtn)
        
        view.addSubview(controlView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.itemSize = CGSizeMake(CameraColletionViewW, CameraColletionViewW)
        layout.minimumLineSpacing = CameraColletionViewPadding
        
        let collectionViewH = CameraColletionViewW
        let collectionViewY = caramView.frame.height - collectionViewH - 10
        
        collectionView = UICollectionView(frame: CGRectMake(0, collectionViewY, view.frame.width, collectionViewH), collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        caramView.addSubview(collectionView)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // 对焦回调
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "adjustingFocus" {}
    }
}

extension CameraViewController: CameraViewDelegate {
    func cameraDidSelected(camera: CameraView) {
        try! device.lockForConfiguration()
        device.focusMode = AVCaptureFocusMode.AutoFocus
        device.focusPointOfInterest = CGPointMake(50, 50)
        // 操作完成后，记得进行unlock。
        device.unlockForConfiguration()
    }
}

extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
        let camera = images[indexPath.item]
        
        let lastView = cell.contentView.subviews.last as? CameraImageView
        
        if lastView == nil {
            // 解决重用问题
            let imageView = CameraImageView(frame: cell.bounds)
            imageView.delegate = self
            imageView.edit = true
            imageView.image = camera.thumbImage
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            cell.contentView.addSubview(imageView)
        } else {
            lastView?.image = camera.thumbImage
        }
        
        return cell;
    }
}

extension CameraViewController: CameraImageViewDelegate {
    func deleteImageView(imageView: CameraImageView) {
        guard let image = imageView.image else {
            return
        }
        
        for i in 0 ..< self.images.count {
            let camera = self.images[i]
            if let tmp = camera.thumbImage {
                if tmp == image {
                    self.images.removeAtIndex(i)
                    break
                }
            }
        }
        self.collectionView.reloadData()
    }
}

extension CameraViewController {

    func captureImage() {
        // get connection
        var videoConnection: AVCaptureConnection?
        for connection in captureOutput.connections as! [AVCaptureConnection] {
            for port in connection.inputPorts as! [AVCaptureInputPort] {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection = connection
                    break
                }
            }
            if nil != videoConnection {
                break
            }
        }
        
        // get UIImage
        captureOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) { buffer, error in
            
            let exifAttachments = CMGetAttachment(buffer, kCGImagePropertyExifDictionary, nil)
            if nil != exifAttachments {
                // Do something with the attachments.
            }
            
            // Continue as appropriate.
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var t_image = UIImage(data: imageData)!
            
            let formater = NSDateFormatter()
            formater.dateFormat = "yyyyMMddHHmmss"
            let currentTimeStr = formater.stringFromDate(NSDate()).stringByAppendingFormat("_%d", arc4random_uniform(10000))
            
            t_image = self.fixOrientation(t_image)
            
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last! + "/\(currentTimeStr)"
            
            UIImagePNGRepresentation(t_image)?.writeToFile(path, atomically: true)
            
            let data = UIImageJPEGRepresentation(t_image, 0.3)
            let camera = CameraImage()
            camera.imagePath = path
            camera.thumbImage = UIImage(data: data!)
            self.images.append(camera)
            
            self.collectionView.reloadData()
            self.collectionView.selectItemAtIndexPath(NSIndexPath(forItem: self.images.count - 1, inSection: 0), animated: true,  scrollPosition: UICollectionViewScrollPosition.Right)
        }
    }

    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] {
            for device in devices {
                if device.position == position {
                    return device
                }
            }
        }
        return nil
    }
    
    func changeCameraDevice(sender: AnyObject) {
        // 翻转
        UIView.beginAnimations("animation", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: view, cache: true)
        UIView.commitAnimations()
        
        let inputs = session.inputs as! [AVCaptureDeviceInput]
        for input in inputs {
            let device = input.device
            if device.hasMediaType(AVMediaTypeVideo) {
                let position = device.position
                let newCamera: AVCaptureDevice?
                let newInput: AVCaptureDeviceInput
                
                if position == AVCaptureDevicePosition.Front {
                    newCamera = cameraWithPosition(AVCaptureDevicePosition.Back)
                } else {
                    newCamera = cameraWithPosition(AVCaptureDevicePosition.Front)
                }
                
                newInput = try! AVCaptureDeviceInput(device: newCamera!)
                
                session.beginConfiguration()
                
                session.removeInput(input)
                session.addInput(newInput)
                
                // Changes take effect once the outermost commitConfiguration is invoked.
                session.commitConfiguration()
                break
            }
        }
    }
    
    func flashLightModel(codeBlock: (()->Void)?) {
        guard let codeBlock = codeBlock else {
            return
        }
        
        session.beginConfiguration()
        try! device.lockForConfiguration()
        codeBlock()
        device.unlockForConfiguration()
        session.commitConfiguration()
        session.startRunning()
    }
    
    func flashCameraDevice(sender: UIButton) {
        
        flashLightModel() {
            self.device.torchMode = AVCaptureTorchMode.On
        }
    }
    
    func closeFlashlight(sender: UIButton) {
        flashLightModel() {
            self.device.torchMode = AVCaptureTorchMode.Off
        }
    }
    
    func cancel(sender: AnyObject?) {
        UIApplication.sharedApplication().statusBarHidden = false
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // 完成、取消
    func doneAction() {
        // 关闭相册界面
        if let callback = callback {
            callback(self.images);
        }
        cancel(nil)
    }
    
    // 拍照
    func stillImage(sender: AnyObject) {
        // 判断图片的限制个数
        if (maxCount > 0 && images.count >= maxCount) {
            let alertView = UIAlertView(title: "提示", message: "拍照的个数不能超过\(maxCount)", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "好的")
            alertView.show()
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.01 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.captureImage()
            let maskView = UIView()
            maskView.frame = self.view.bounds
            maskView.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(maskView)
            
            UIView.animateWithDuration(0.5,
                animations: {
                    maskView.alpha = 0
                }, completion: { finish in
                    maskView.removeFromSuperview()
                }
            )
        }
    }
    
    func fixOrientation(srcImg: UIImage) -> UIImage {
        if srcImg.imageOrientation == UIImageOrientation.Up {
            return srcImg
        }
        
        var transform = CGAffineTransformIdentity
        switch (srcImg.imageOrientation) {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))

        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch (srcImg.imageOrientation) {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)

        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break;
        }
        
        let ctx = CGBitmapContextCreate(nil, Int(srcImg.size.width), Int(srcImg.size.height),
            CGImageGetBitsPerComponent(srcImg.CGImage), 0,
            CGImageGetColorSpace(srcImg.CGImage),
            CGImageGetBitmapInfo(srcImg.CGImage).rawValue)
        CGContextConcatCTM(ctx, transform)
        
        switch (srcImg.imageOrientation) {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage)
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage)
        }
        
        let cgimg = CGBitmapContextCreateImage(ctx)!
        let img = UIImage(CGImage: cgimg)

        return img
    }

}
