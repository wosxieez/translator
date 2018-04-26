//
//  AboutMeViewController.swift
//  Translator
//
//  Created by coco on 2018/4/3.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class AboutMeViewController: UIViewController {

    
    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoDic = Bundle.main.infoDictionary
        if let version = infoDic?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "当前版本：" + version
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
}
