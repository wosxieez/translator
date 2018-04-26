//
//  AddDeviceViewController.swift
//  Translator
//
//  Created by coco on 05/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class AddDeviceViewController: UIViewController {
    
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var configWifiButton: UIButton!
    @IBOutlet weak var bindingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configWifiButton.layer.cornerRadius = 25
        configWifiButton.backgroundColor = AppUtil.themeColor
        view.addSubview(configWifiButton)
        
        bindingButton.layer.cornerRadius = 25
        bindingButton.setTitle("设备绑定", for: .normal)
        bindingButton.backgroundColor = UIColor.clear
        bindingButton.setTitleColor(AppUtil.themeColor, for: .normal)
        bindingButton.layer.borderColor = AppUtil.themeColor.cgColor
        bindingButton.layer.borderWidth = 1
        view.addSubview(bindingButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let scale = view.bounds.width / topBgImageView.image!.size.width
        topBgImageView.frame.size.width = view.bounds.width
        topBgImageView.frame.size.height = topBgImageView.image!.size.height * scale
    }
    
}
