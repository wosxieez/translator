//
//  ChangePasswordViewController.swift
//  Translator
//
//  Created by coco on 17/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UITableViewController {
    
    @IBOutlet weak var oldPasswordInput: UITextField!
    @IBOutlet weak var newPasswordInput1: UITextField!
    @IBOutlet weak var newPasswordInput2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false;
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        tableView.tableFooterView = footerView;
        
        let commitButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 44));
        commitButton.setTitle("确定", for: .normal);
        commitButton.backgroundColor = AppUtil.themeColor;
        commitButton.translatesAutoresizingMaskIntoConstraints = false;
        commitButton.addTarget(self, action: #selector(commitAction), for: .touchUpInside);
        footerView.addSubview(commitButton);
        
        let centerY = NSLayoutConstraint(item: commitButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: footerView,
                                         attribute: .centerY, multiplier: 1, constant: 0);
        let leading:NSLayoutConstraint = NSLayoutConstraint(item: commitButton, attribute: .leading,
                                                            relatedBy: .equal, toItem: footerView,
                                                            attribute: .leadingMargin, multiplier: 1, constant: 10);
        
        let trailing:NSLayoutConstraint = NSLayoutConstraint(item: footerView, attribute: .trailingMargin,
                                                            relatedBy: .equal, toItem: commitButton,
                                                            attribute: .trailing, multiplier: 1, constant: 10);
        footerView.addConstraint(centerY);
        footerView.addConstraint(leading);
        footerView.addConstraint(trailing);
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: commitButton, attribute: .height,
                                                           relatedBy: .equal, toItem: nil,
                                                           attribute: .height, multiplier: 1, constant: 44.0);
        commitButton.addConstraint(height);
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func commitAction() -> Void
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
        
        AppService.getInstance().changePassword(username: AppUtil.username, oldPassword: AppUtil.password,
                                                newPassword: newPasswordInput1.text, completionHandler: changePasswordHandler);
    }
    
    func changePasswordHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        if (data != nil)
        {
            let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
            let jsonDic:[String: Any]? = jsonObject as? [String: Any];
            if (jsonDic != nil)
            {
                if (jsonDic!["resultCode"] as? String == "00")
                {
                    // 密码修改成功
                    DispatchQueue.main.async {
                        AppUtil.password = self.newPasswordInput1.text;
                        self.oldPasswordInput.text = "";
                        self.newPasswordInput1.text = "";
                        self.newPasswordInput2.text = "";
                        self.navigationController?.popViewController(animated: true);
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        Toast.show(message: jsonDic!["resultMsg"] as? String);
                    }
                }
            }
        }
    }
    
    @IBAction func didEndOnExit(_ sender: Any)
    {
        (sender as? UITextField)?.resignFirstResponder();
    }
    
}
