//
//  重置密码视图管理器
//  Translator
//
//  Created by coco on 16/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UITableViewController {
    
    @IBOutlet weak var passwordInput1:UITextField!;
    @IBOutlet weak var passwordInput2:UITextField!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        tableView.tableFooterView = footerView;
        
        let commitButton:UIButton = UIButton();
        commitButton.backgroundColor = AppUtil.themeColor;
        commitButton.translatesAutoresizingMaskIntoConstraints = false;
        commitButton.setTitle("确定", for: .normal);
        commitButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside);
        footerView.addSubview(commitButton);
        
        let topConstraint:NSLayoutConstraint = NSLayoutConstraint(item: commitButton,
                                                                  attribute: .top,
                                                                  relatedBy: .equal,
                                                                  toItem: footerView,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 10);
        let leadingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: commitButton,
                                                                      attribute: .leading,
                                                                      relatedBy: .equal,
                                                                      toItem: footerView,
                                                                      attribute: .leadingMargin,
                                                                      multiplier: 1, constant: 10);
        let trailingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: footerView,
                                                                       attribute: .trailingMargin,
                                                                       relatedBy: .equal,
                                                                       toItem: commitButton,
                                                                       attribute: .trailing,
                                                                       multiplier: 1,
                                                                       constant: 10);
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: commitButton,
                                                                     attribute: .height,
                                                                     relatedBy: .equal,
                                                                     toItem: nil,
                                                                     attribute: .notAnAttribute,
                                                                     multiplier: 1, constant: 44);
        footerView.addConstraint(topConstraint);
        footerView.addConstraint(leadingConstraint);
        footerView.addConstraint(trailingConstraint);
        commitButton.addConstraint(heightConstraint);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func resetPassword() -> Void
    {
        if (!AppUtil.isPassword(value: passwordInput1.text)) {
            Toast.show(message: "请输入6-18位字母数字组合的密码")
            return
        }
        
        if passwordInput1.text != passwordInput2.text {
            Toast.show(message: "两次输入的密码不匹配")
            return
        }
        
        AppService.getInstance().resetPassword(username: AppUtil.username, password: passwordInput1.text,
                                               completionHandler: completeHandler);
    }
    
    func completeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        DispatchQueue.main.async {
            let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
            if (jsonObject != nil)
            {
                let jsonDic:[String: Any]? = jsonObject as? [String: Any];
                if (jsonDic != nil)
                {
                    Toast.show(message: jsonDic!["resultMsg"] as? String);
                    
                    if ((jsonDic!["resultCode"] as? String) == "0")
                    {
                        for viewController in (self.navigationController?.viewControllers)!
                        {
                            if (viewController is LoginViewController)
                            {
                                self.navigationController?.popToViewController(viewController, animated: true);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
}
