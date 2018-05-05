//
//  Localizable.swift
//  Translator
//
//  Created by coco on 2018/5/5.
//  Copyright © 2018 coco. All rights reserved.
//

import Foundation


extension String {
    
    func localizable() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
}
