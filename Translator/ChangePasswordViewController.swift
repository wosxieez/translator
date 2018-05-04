//
//  ChangePasswordViewController.swift
//  Translator
//
//  Created by coco on 17/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput1: UITextField!
    @IBOutlet weak var newPasswordInput2: UITextField!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    @IBOutlet weak var commitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commitButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func commitAction() -> Void
    {
        if (oldPasswordInput.text != AppUtil.password)
        {
            // 提示新密码不匹配
            Toast.show(message: "旧密码不正确");
            return;
        }
        
        if (!AppUtil.isPassword(value: newPasswordInput1.text))
        {
            Toast.show(message: "请输入6-18位字母数字组合的密码");
            return;
        }
        
        if (newPasswordInput1.text != newPasswordInput2.text)
        {
            // 提示新密码不匹配
            Toast.show(message: "两次输入的密码不匹配");
            return;
        }
        
        AppService.getInstance().changePassword(username: AppUtil.username, oldPassword: AppUtil.password, newPassword: newPasswordInput1.text, completionHandler: changePasswordHandler);
    }
    
    func changePasswordHandler(data:Data?, response:URLResponse?, error:Error?) {
        if data != nil {
            let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
            let jsonDic:[String: Any]? = jsonObject as? [String: Any];
            if (jsonDic != nil) {
                if (jsonDic!["resultCode"] as? String == "00") {
                    // 密码修改成功
                    DispatchQueue.main.async {
                        AppUtil.password = self.newPasswordInput1.text;
                        self.oldPasswordInput.text = "";
                        self.newPasswordInput1.text = "";
                        self.newPasswordInput2.text = "";
                        self.navigationController?.popViewController(animated: true);
                    }
                } else {
                    DispatchQueue.main.async {
                        Toast.show(message: jsonDic!["resultMsg"] as? String);
                    }
                }
            }
        }
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
}
