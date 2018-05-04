//
//  AppTabBarController.swift
//  Translator
//
//  Created by coco on 2018/5/4.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTranslateViewController), name: Notification.Name("showTranslateViewController"), object: nil)
    }
    
    @objc func showTranslateViewController() {
        if viewControllers!.count < 3 {
            viewControllers?.insert(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "translateVC"), at: 1)
            selectedIndex = 1
        }
    }

}
