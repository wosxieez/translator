//
//  RegisterViewController.swift
//  TangdiTranslator
//
//  Created by coco on 15/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController {
    
    @IBOutlet weak var mobilePhoneInput: UITextField!
    @IBOutlet weak var mobileCodeInput: UITextField!;
    
    var sendMobileCodeButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false;// 禁止滚动
        
        // 给验证码输入框右边增加 发送验证码按钮
        sendMobileCodeButton = UIButton(type: .custom);
        sendMobileCodeButton.frame = CGRect(x: 0, y: 0, width: 80, height: 25);
        sendMobileCodeButton.setTitle("发送验证码", for: .normal);
        sendMobileCodeButton.layer.cornerRadius = 5;
        sendMobileCodeButton.layer.borderColor = AppUtil.themeColor.cgColor;
        sendMobileCodeButton.layer.borderWidth = 1;
        sendMobileCodeButton.setTitleColor(AppUtil.themeColor, for: .normal);
        sendMobileCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12);
        sendMobileCodeButton.addTarget(self, action: #selector(sendMobileCodeAction), for: .touchUpInside);
        
        mobileCodeInput.rightView = sendMobileCodeButton;
        mobileCodeInput.rightViewMode = .always;
        mobilePhoneInput.keyboardType = UIKeyboardType.phonePad;
        
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        tableView.tableFooterView = footerView;
        
        let okButton:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44));
        okButton.backgroundColor = UIColor(red: 58/255, green: 187/255, blue: 255/255, alpha: 1);
        okButton.translatesAutoresizingMaskIntoConstraints = false;
        okButton.setTitle("确定", for: .normal);
        okButton.addTarget(self, action: #selector(verifyMobileCode), for: .touchUpInside);
        footerView.addSubview(okButton);
        
        let topConstraint:NSLayoutConstraint = NSLayoutConstraint(item: okButton,
                                                                  attribute: .top,
                                                                  relatedBy: .equal,
                                                                  toItem: footerView,
                                                                  attribute: .top,
                                                                  multiplier: 1,
                                                                  constant: 30);
        let leftConstraint:NSLayoutConstraint = NSLayoutConstraint(item: okButton,
                                                                   attribute: .leading,
                                                                   relatedBy: .equal,
                                                                   toItem: footerView,
                                                                   attribute: .leadingMargin,
                                                                   multiplier: 1,
                                                                   constant: 10);
        let rightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: footerView,
                                                                    attribute: .trailingMargin,
                                                                    relatedBy: .equal,
                                                                    toItem: okButton,
                                                                    attribute: .trailing,
                                                                    multiplier: 1,
                                                                    constant: 10);
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: okButton,
                                                                     attribute: .height,
                                                                     relatedBy: .equal,
                                                                     toItem: nil,
                                                                     attribute: .notAnAttribute,
                                                                     multiplier: 1,
                                                                     constant: 44);
        footerView.addConstraint(topConstraint);
        footerView.addConstraint(leftConstraint);
        footerView.addConstraint(rightConstraint);
        okButton.addConstraint(heightConstraint);
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(false, animated: animated);
        UIApplication.shared.statusBarStyle = .lightContent;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func dataHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
        if (jsonObject != nil)
        {
            let jsonData:[String: Any] = jsonObject as! [String: Any];
            DispatchQueue.main.async {
                Toast.show(message: jsonData["RESP_MSG"] as? String);
            }
        }
    }
    
    var resendTimer:DispatchSourceTimer?;
    var resendCount:Int = 30;
    
    /**
     用户请求验证码
     */
    @objc func sendMobileCodeAction() -> Void {
        guard AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!) else {
            Toast.show(message: "请输入有效的手机号码")
            return
        }
        
        // 检查用户是否已经注册了
        AppService.getInstance().checkUser(username: mobilePhoneInput.text!, completionHandler: checkUserCompletionHandler)
    }
    
    func checkUserCompletionHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败")
                return
            }
            
            let jsonDic = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any]
            if let regFlag = jsonDic?["regFlag"] {
                if regFlag as? String == "0" {
                    AppService.getInstance().pushMobileCode(tomobile: self.mobilePhoneInput.text,
                                                            completionHandler: self.sendMobileCodeHandler)
                } else {
                    Toast.show(message: jsonDic!["resultMsg"] as? String)
                }
            }
            else {
                Toast.show(message: "请求失败")
            }
        }
    }
    
    func sendMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败")
                return
            }
            
            let jsonDic = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any]
            if let resultCode = jsonDic?["resultCode"] {
                if resultCode as? String == "0" {
                    self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                    self.sendMobileCodeButton.backgroundColor = UIColor.gray
                    self.sendMobileCodeButton.setTitleColor(UIColor.white, for: .normal)
                    self.sendMobileCodeButton.isEnabled = false
                    self.startTimer(count: 30)
                } else if resultCode as? String == "1" {
                    self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                    self.sendMobileCodeButton.backgroundColor = UIColor.gray
                    self.sendMobileCodeButton.setTitleColor(UIColor.white, for: .normal)
                    self.sendMobileCodeButton.isEnabled = false
                    self.startTimer(count: 30 - Int(jsonDic!["timeDiffer"] as! String)!)
                }
                Toast.show(message: jsonDic!["resultMsg"] as? String)
            } else {
                Toast.show(message: "请求失败")
            }
        }
    }
    
    func startTimer(count:Int) -> Void {
        resendCount = count;
        
        // 创建一个DispatchSourceTimer 用来验证码倒计时
        resendTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global());
        resendTimer?.schedule(deadline: DispatchTime.now(),
                              repeating: DispatchTimeInterval.seconds(1),
                              leeway: DispatchTimeInterval.milliseconds(1));
        resendTimer?.setEventHandler(handler: {
            self.resendCount = self.resendCount - 1;
            
            // 到主队列去更新倒计时秒数
            DispatchQueue.main.async {
                self.sendMobileCodeButton.setTitle(String(self.resendCount) + "后再试", for: .normal);
            }
            
            if (self.resendCount <= 0)
            {
                self.resendTimer?.cancel();
                DispatchQueue.main.async {
                    self.sendMobileCodeButton.layer.borderColor = AppUtil.themeColor.cgColor;
                    self.sendMobileCodeButton.backgroundColor = UIColor.white;
                    self.sendMobileCodeButton.setTitleColor(AppUtil.themeColor, for: .normal);
                    self.sendMobileCodeButton.isEnabled = true;
                    self.sendMobileCodeButton.setTitle("发送验证码", for: .normal);
                }
            }
        });
        resendTimer?.resume();
    }
    
    /// 校验手机验证码
    @objc func verifyMobileCode() -> Void {
        if !AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!) {
            Toast.show(message: "请输入有效的手机号码")
            return
        }
        if mobileCodeInput.text == nil || mobileCodeInput.text == "" {
            Toast.show(message: "请输入有效的验证码")
            return
        }
        
        AppService.getInstance().verifyMobileCode(mobilePhone: mobilePhoneInput.text,
                                                  mobileCode: mobileCodeInput.text,
                                                  completionHandler: verifyMobileCodeHandler)
    }
    
    func verifyMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败")
                return
            }
            
            let jsonDic = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any]
            if let resultCode = jsonDic?["resultCode"] {
                if resultCode as? String == "0" {
                    if let registerView2Controller = self.storyboard?.instantiateViewController(withIdentifier: "registerView2Controller") as? RegisterView2Controller {
                        registerView2Controller.username = self.mobilePhoneInput.text;
                        self.navigationController?.pushViewController(registerView2Controller, animated: true);
                    }
                }
                else {
                    Toast.show(message: jsonDic!["resultMsg"] as? String);
                }
            }
            else {
                Toast.show(message: "请求失败")
            }
        }
    }
    
}
