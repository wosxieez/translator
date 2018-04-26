//
//  TranslateViewController.swift
//  Translator
//
//  Created by coco on 08/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslateViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 修改导航条样式 透明/没有底线
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        popToRootViewController(animated: false)
    }

}
