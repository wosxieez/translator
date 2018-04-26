//
//  RegisterViewController.swift
//  TangdiTranslator
//
//  Created by coco on 15/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class FindPasswordViewController: UITableViewController {
    
    @IBOutlet weak var mobilePhoneInput: UITextField!
    @IBOutlet weak var mobileCodeInput: UITextField!;
    
    var sendMobileCodeButton:UIButton!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // 禁止滚动
        tableView.isScrollEnabled = false;
        
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
    
    @objc func sendMobileCodeAction() -> Void
    {
        if (AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!))
        {
            // 发送验证码请求
            AppService.getInstance().pushMobileCode(tomobile: mobilePhoneInput.text,
                                                    completionHandler: sendMobileCodeHandler);
        }
        else
        {
            Toast.show(message: "请输入有效的手机号码");
        }
    }
    
    func sendMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        if (error != nil || data == nil)
        {
            DispatchQueue.main.async {
                Toast.show(message: "请求失败");
            }
            
            return;
        }
        // 请求验证码的结果
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
        if (jsonObject != nil)
        {
            let jsonDic:[String: Any]? = jsonObject as? [String: Any];
            if (jsonDic != nil)
            {
                DispatchQueue.main.async {
                    Toast.show(message: jsonDic!["resultMsg"] as? String);
                }
                
                if (jsonDic!["resultCode"] as? String == "0")
                {
                    DispatchQueue.main.async {
                        self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor;
                        self.sendMobileCodeButton.backgroundColor = UIColor.gray;
                        self.sendMobileCodeButton.setTitleColor(UIColor.white, for: .normal);
                        self.sendMobileCodeButton.isEnabled = false;
                    }
                    startTimer(count: 30);
                }
                else if (jsonDic!["resultCode"] as? String == "1")
                {
                    DispatchQueue.main.async {
                        self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor;
                        self.sendMobileCodeButton.backgroundColor = UIColor.gray;
                        self.sendMobileCodeButton.setTitleColor(UIColor.white, for: .normal);
                        self.sendMobileCodeButton.isEnabled = false;
                    }
                    startTimer(count: 30 - Int(jsonDic!["timeDiffer"] as! String)!);
                }
                else
                {
                    
                }
            }
        }
    }
    
    func startTimer(count:Int) -> Void
    {
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
    @objc func verifyMobileCode() -> Void
    {
        if (!AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!))
        {
            Toast.show(message: "请输入有效的手机号码");
            return;
        }
        
        if (mobileCodeInput.text == nil || mobileCodeInput.text == "")
        {
            Toast.show(message: "请输入有效的验证码");
            return;
        }
        
        AppService.getInstance().verifyMobileCode(mobilePhone: mobilePhoneInput.text,
                                                  mobileCode: mobileCodeInput.text,
                                                  completionHandler: verifyMobileCodeHandler);
    }
    
    func verifyMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves);
        let jsonDic:[String: Any]? = jsonObject as? [String: Any];
        if (jsonDic != nil)
        {
            if (jsonDic!["resultCode"] as? String == "0")
            {
                // 退送到注册密码界面
                DispatchQueue.main.async
                    {
                        AppUtil.username = self.mobilePhoneInput.text;
                        self.performSegue(withIdentifier: "showVC", sender: nil);
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

