//
//  MainViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutHandler), name: NSNotification.Name.init("appLogout"), object: nil)
        self.selectedIndex = 2 // 默认选中
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
        UIApplication.shared.statusBarStyle = .lightContent;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        UIApplication.shared.statusBarStyle = .default;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func logoutHandler(notification:Notification)
    {
        navigationController?.popViewController(animated: true);
        //        dismiss(animated: true, completion: nil);
    }
    
    
}
