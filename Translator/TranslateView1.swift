//
//  TranslateView1.swift
//  Translator
//
//  Created by coco on 10/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslateView1: UIView
{
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        let hisTestView:UIView? = super.hitTest(point, with: event);

        if (!(hisTestView is UITextView) || !(hisTestView as! UITextView).isEditable)
        {
            endEditing(true);
        }
        
        return hisTestView;
    }
    
}
