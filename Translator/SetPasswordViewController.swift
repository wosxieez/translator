//
//  SetPasswordViewController.swift
//  Translator
//
//  Created by coco on 2018/4/6.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class SetPasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordInput1: UITextField!
    @IBOutlet weak var newPasswordInput2: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commitButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default // 黑色字体状态栏
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commitAction(_ sender: Any) {
        if !AppUtil.isPassword(value: newPasswordInput1.text) {
            Toast.show(message: "请输入6-18位字符密码")
            return
        }
        
        if newPasswordInput1.text != newPasswordInput2.text {
            Toast.show(message: "两次输入的密码不一致")
            return
        }
        
        AppUtil.passwordForRegister = newPasswordInput1.text
        performSegue(withIdentifier: "selectGenderSegue", sender: nil)
    }
    
}
