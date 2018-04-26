//
//  SetPasswordViewController.swift
//  Translator
//
//  Created by coco on 2018/4/6.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class SetNewPasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordInput1: UITextField!
    @IBOutlet weak var newPasswordInput2: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commitButton.layer.cornerRadius = 4
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func doBackAction() {
        navigationController?.popToRootViewController(animated: true)
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
        
        AppService.getInstance().resetPassword(username: AppUtil.username, password: newPasswordInput2.text) { (data, response, error) in
            guard error == nil && data != nil else {
                DispatchQueue.main.async {
                    Toast.show(message: "密码重置失败")
                }
                return
            }
            
            if let object = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any] {
                DispatchQueue.main.async {
                    Toast.show(message: object["resultMsg"] as? String)
                    if object["resultMsg"] as? String == "重置成功" {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
}
