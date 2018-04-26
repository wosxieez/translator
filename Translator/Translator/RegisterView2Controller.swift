//
//  RegisterView2Controller.swift
//  Translator
//
//  Created by coco on 13/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class RegisterView2Controller: UITableViewController
{
    @IBOutlet weak var passwordInput: UITextField!
    
    var genderRow = 0;
    var username:String?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellview");
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        tableView.tableFooterView = footerView;
        
        let commitButton:UIButton = UIButton();
        commitButton.translatesAutoresizingMaskIntoConstraints = false;
        commitButton.backgroundColor = AppUtil.themeColor;
        commitButton.setTitle("确定", for: .normal);
        commitButton.addTarget(self, action: #selector(okAction), for: .touchUpInside);
        footerView.addSubview(commitButton);
        
        let topConstraint:NSLayoutConstraint = NSLayoutConstraint(item: commitButton,
                                                                  attribute: .top,
                                                                  relatedBy: .equal,
                                                                  toItem: footerView,
                                                                  attribute: .top,
                                                                  multiplier: 1, constant: 30);
        let leadingConstraint:NSLayoutConstraint = NSLayoutConstraint(item: commitButton,
                                                                      attribute: .leading,
                                                                      relatedBy: .equal,
                                                                      toItem: footerView,
                                                                      attribute: .leadingMargin,
                                                                      multiplier: 1,
                                                                      constant: 10);
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell!;
        if (indexPath.section == 1)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "cellview", for: indexPath);
            if (indexPath.row == 0)
            {
                cell.textLabel?.text = "男";
            }
            else
            {
                cell.textLabel?.text = "女";
            }
            
            if (indexPath.row == genderRow)
            {
                cell.accessoryType = .checkmark;
            }
            else
            {
                cell.accessoryType = .none;
            }
        }
        else
        {
            cell = super.tableView(tableView, cellForRowAt: indexPath);
        }
        
        cell.selectionStyle = .none;
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.section == 1)
        {
            genderRow = indexPath.row;
            tableView.reloadData();
        }
    }
    
    @objc func okAction(_ sender: Any)
    {
        if (!AppUtil.isPassword(value: passwordInput.text))
        {
            Toast.show(message: "请输入6-18位字母数字组合的密码");
            return;
        }
        
        var sex:String!;
        if (genderRow == 0)
        {
            sex = "M";
        }
        else
        {
            sex = "F";
        }
        AppService.getInstance().registerUser(username: username, password: passwordInput.text,
                                              mobile: username, sex: sex, completionHandler: completeHandler);
    }
    
    func completeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
        if (jsonObject != nil)
        {
            let jsonDic:[String: Any]? = jsonObject as? [String: Any];
            if (jsonDic != nil)
            {
                if ((jsonDic!["resultCode"] as? String) == "0")
                {
                    DispatchQueue.main.async {
                        
                        Toast.show(message: "注册成功");
                        
                        for viewController in (self.navigationController?.viewControllers)!
                        {
                            if (viewController is LoginViewController)
                            {
                                self.navigationController?.popToViewController(viewController, animated: true);
                            }
                        }
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
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
//    {
//        return 20;
//    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0001;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var title:String?;
        switch section {
        case 0:
            title = "密码";
        case 1:
            title = "性别";
        default:
            title = nil;
        }
        
        return title;
    }
    
}
