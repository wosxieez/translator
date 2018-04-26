//
//  TranslteTableViewCell2.swift
//  Translator
//
//  Created by coco on 28/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslteTableViewCell2: UITableViewCell {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconView:UIView!;
    @IBOutlet weak var sourceDisplay: UILabel!
    @IBOutlet weak var targetDisplay:UILabel!
    
    var language: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.layer.cornerRadius = 20;
        iconView.layer.masksToBounds = true;
        sourceDisplay.numberOfLines = 0;
        targetDisplay.numberOfLines = 0;
    }
    
    @IBAction func speakAction() {
        if targetDisplay.text != nil && targetDisplay.text!.count > 0 {
            AppUtil.speech(q: targetDisplay.text!, language: language)
        }
    }
    
}
