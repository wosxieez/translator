//
//  CaptureOverView.swift
//  Translator
//
//  Created by coco on 10/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class CaptureOverView: UIView
{
    var _beganPoint:CGPoint?;
    var beganPoint:CGPoint?
    {
        get
        {
            return _beganPoint;
        }
        set
        {
            _beganPoint = newValue;
            setNeedsDisplay();
        }
    }
    
    var _endPoint:CGPoint?;
    var endPoint:CGPoint?
    {
        get
        {
            return _endPoint;
        }
        set
        {
            _endPoint = newValue;
            setNeedsDisplay();
        }
    }
    
    var _isIndicate:Bool = true;
    
    var isIndicate:Bool
    {
        get
        {
            return _isIndicate;
        }
        set
        {
            _isIndicate = newValue;
            _endPoint = nil;
            _beganPoint = nil;
            setNeedsDisplay();
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        backgroundColor = UIColor.clear;
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (isIndicate)
        {
            return;
        }
        
        endPoint = nil;
        beganPoint = touches.first?.location(in: self);
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (isIndicate)
        {
            return;
        }
        
        endPoint = touches.first?.location(in: self);
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (isIndicate)
        {
            return;
        }
        
        endPoint = touches.first?.location(in: self);
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect);
        
        if (isIndicate)
        {
            UIColor.white.setStroke();
            let path:UIBezierPath = UIBezierPath(rect: bounds);
            path.lineWidth = 0.5;
            path.move(to: CGPoint(x: bounds.width / 3, y: 0));
            path.addLine(to: CGPoint(x: bounds.width / 3, y: bounds.height));
            path.move(to: CGPoint(x: bounds.width * 2 / 3, y: 0));
            path.addLine(to: CGPoint(x: bounds.width * 2 / 3, y: bounds.height));
            path.move(to: CGPoint(x: 0, y: bounds.height / 3));
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 3));
            path.move(to: CGPoint(x: 0, y: bounds.height * 2 / 3));
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height * 2 / 3));
            path.stroke();
        }
        else
        {
            if (beganPoint != nil && endPoint != nil)
            {
                UIColor(white: 0, alpha: 0.5).setFill();
                
                let path:UIBezierPath = UIBezierPath(rect: bounds);
                let path2:UIBezierPath = UIBezierPath(rect: CGRect(x: beganPoint!.x,
                                                                   y: beganPoint!.y,
                                                                   width: endPoint!.x - beganPoint!.x,
                                                                   height: endPoint!.y - beganPoint!.y));
                path.append(path2);
                path.usesEvenOddFillRule = true;
                path.fill();
            }
        }
    }
    
}
