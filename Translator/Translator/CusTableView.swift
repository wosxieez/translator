//
//  CusTableView.swift
//  Translator
//
//  Created by coco on 16/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class CusTableView: UITableView {
    
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
