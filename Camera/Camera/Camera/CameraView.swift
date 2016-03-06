//
//  CameraView.swift
//  Camera
//
//  Created by  lifirewolf on 16/3/4.
//  Copyright © 2016年  lifirewolf. All rights reserved.
//

import UIKit

let BQCameraViewW = 60

protocol CameraViewDelegate: NSObjectProtocol {
    func cameraDidSelected(camera: CameraView)
}

class CameraView: UIView {
    
    var delegate: CameraViewDelegate?
    
    var link: CADisplayLink!
    var time = 0
    var point = CGPoint(x: 0, y: 0)
    var isPlayerEnd = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        link = CADisplayLink(target: self, selector: "refreshView:")
    }
    
    func refreshView(link: CADisplayLink) {
        setNeedsDisplay()
        time++
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if isPlayerEnd {
            return
        }
        
        isPlayerEnd = true
        if let touch = touches.first {
            point = touch.locationInView(touch.view)
        }
        
        if nil == link {
            setupUI()
        }
        link.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            
        if let delegate = delegate {
            delegate.cameraDidSelected(self)
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if !isPlayerEnd {
            return
        }
        
        let rectValue = CGFloat(BQCameraViewW - time % BQCameraViewW)
        let rectangle = CGRectMake(point.x - rectValue / 2.0, point.y - rectValue / 2.0, rectValue, rectValue)
        
        // 获得上下文句柄
        let currentContext = UIGraphicsGetCurrentContext()
        
        if rectValue <= 30 {
            isPlayerEnd = false
            link.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            link = nil
            time = 0
            
            CGContextClearRect(currentContext, rectangle)
        } else {
            // 创建图形路径句柄
            let path = CGPathCreateMutable()
            // 设置矩形的边界
            // 添加矩形到路径中
            CGPathAddRect(path, nil, rectangle)
            // 添加路径到上下文中
            CGContextAddPath(currentContext, path)
            
            // 填充颜色
            UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0).setFill()
            // 设置画笔颜色
            UIColor.yellowColor().setStroke()
            // 设置边框线条宽度
            CGContextSetLineWidth(currentContext, 1.0)
            // 画图
            CGContextDrawPath(currentContext, CGPathDrawingMode.FillStroke)
        }
    }
    
}
