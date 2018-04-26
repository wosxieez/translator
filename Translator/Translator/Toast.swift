//
//  Toast.swift
//  Translator
//
//  Created by coco on 23/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class Toast: UIView {
    
    var labelDisplay:UILabel!;

    /// 打开一个全局提示框
    @discardableResult
    public static func show(message:String?, delayCloseTime:TimeInterval = 1) -> Toast {
        let toast:Toast = Toast(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        toast.open(message: message, delayCloseTime: delayCloseTime)
        return toast
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black;
        layer.cornerRadius = 2;
        
        labelDisplay = UILabel();
        labelDisplay.textColor = UIColor.white
        labelDisplay.font = UIFont.systemFont(ofSize: 18)
        labelDisplay.textAlignment = NSTextAlignment.center;
        addSubview(labelDisplay);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        labelDisplay.sizeToFit()
    }
    
    /// 打开显示
    func open(message:String?, delayCloseTime:TimeInterval) -> Void {
        labelDisplay.text = message
        UIApplication.shared.keyWindow?.addSubview(self);
        if delayCloseTime > 0 { perform(#selector(close), with: nil, afterDelay: delayCloseTime) }
        setNeedsLayout()
    }
    
    /// 关闭显示
    @objc func close() -> Void {
        removeFromSuperview();
    }
    
}
