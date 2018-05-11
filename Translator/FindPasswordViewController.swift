//
//  RegisterViewController.swift
//  TangdiTranslator
//
//  Created by coco on 15/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class FindPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var mobilePhoneInput: UITextField!
    @IBOutlet weak var mobileCodeInput: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    var sendMobileCodeButton: UIButton!
    var resendTimer: DispatchSourceTimer?
    var resendCount: Int = 30
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 给验证码输入框右边增加 发送验证码按钮
        sendMobileCodeButton = UIButton(type: .custom)
        sendMobileCodeButton.frame = CGRect(x: 0, y: 0, width: 80, height: 28)
        sendMobileCodeButton.setTitle("获取验证码".localizable(), for: .normal)
        sendMobileCodeButton.layer.cornerRadius = 5
        sendMobileCodeButton.layer.borderColor = AppUtil.themeColor.cgColor
        sendMobileCodeButton.layer.borderWidth = 1
        sendMobileCodeButton.setTitleColor(AppUtil.themeColor, for: .normal)
        sendMobileCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sendMobileCodeButton.addTarget(self, action: #selector(sendMobileCodeAction), for: .touchUpInside)
        
        mobilePhoneInput.rightView = sendMobileCodeButton
        mobilePhoneInput.rightViewMode = .always
        mobilePhoneInput.keyboardType = UIKeyboardType.phonePad
        
        commitButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func dataHandler(data:Data?, response:URLResponse?, error:Error?) {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
        if jsonObject != nil {
            let jsonData:[String: Any] = jsonObject as! [String: Any]
            DispatchQueue.main.async {
                Toast.show(message: jsonData["RESP_MSG"] as? String)
            }
        }
    }
    
    @objc func sendMobileCodeAction() {
        if AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!) {
            AppService.getInstance().pushMobileCode(tomobile: mobilePhoneInput.text,
                                                    completionHandler: sendMobileCodeHandler)
        } else {
            Toast.show(message: "请输入有效的手机号码".localizable())
        }
    }
    
    func sendMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) {
        if error != nil || data == nil {
            DispatchQueue.main.async {
                Toast.show(message: "请求失败".localizable())
            }
            return
        }
        // 请求验证码的结果
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
        if (jsonObject != nil)
        {
            let jsonDic:[String: Any]? = jsonObject as? [String: Any]
            if (jsonDic != nil)
            {
                DispatchQueue.main.async {
                    Toast.show(message: jsonDic!["resultMsg"] as? String)
                }
                
                if (jsonDic!["resultCode"] as? String == "0")
                {
                    DispatchQueue.main.async {
                        self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                        self.sendMobileCodeButton.setTitleColor(UIColor.gray, for: .normal)
                        self.sendMobileCodeButton.isEnabled = false
                    }
                    startTimer(count: 30)
                }
                else if (jsonDic!["resultCode"] as? String == "1")
                {
                    DispatchQueue.main.async {
                        self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                        self.sendMobileCodeButton.setTitleColor(UIColor.gray, for: .normal)
                        self.sendMobileCodeButton.isEnabled = false
                    }
                    startTimer(count: 30 - Int(jsonDic!["timeDiffer"] as! String)!)
                }
                else
                {
                    
                }
            }
        }
    }
    
    func startTimer(count:Int) -> Void
    {
        resendCount = count
        
        // 创建一个DispatchSourceTimer 用来验证码倒计时
        resendTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        resendTimer?.schedule(deadline: DispatchTime.now(),
                              repeating: DispatchTimeInterval.seconds(1),
                              leeway: DispatchTimeInterval.milliseconds(1))
        resendTimer?.setEventHandler(handler: {
            self.resendCount = self.resendCount - 1
            
            // 到主队列去更新倒计时秒数
            DispatchQueue.main.async {
                self.sendMobileCodeButton.setTitle("重新获取".localizable() + "(" + String(self.resendCount) + ")", for: .normal)
            }
            
            if (self.resendCount <= 0)
            {
                self.resendTimer?.cancel()
                DispatchQueue.main.async {
                    self.sendMobileCodeButton.layer.borderColor = AppUtil.themeColor.cgColor
                    self.sendMobileCodeButton.backgroundColor = UIColor.white
                    self.sendMobileCodeButton.setTitleColor(AppUtil.themeColor, for: .normal)
                    self.sendMobileCodeButton.isEnabled = true
                    self.sendMobileCodeButton.setTitle("获取验证码".localizable(), for: .normal)
                }
            }
        })
        resendTimer?.resume()
    }
    
    /// 校验手机验证码
    @IBAction func verifyMobileCode() -> Void
    {
        if (!AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!))
        {
            Toast.show(message: "请输入有效的手机号码".localizable())
            return
        }
        
        if (mobileCodeInput.text == nil || mobileCodeInput.text == "")
        {
            Toast.show(message: "请输入有效的验证码".localizable())
            return
        }
        
        AppService.getInstance().verifyMobileCode(mobilePhone: mobilePhoneInput.text,
                                                  mobileCode: mobileCodeInput.text,
                                                  completionHandler: verifyMobileCodeHandler)
    }
    
    func verifyMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
        let jsonDic:[String: Any]? = jsonObject as? [String: Any]
        if (jsonDic != nil)
        {
            if (jsonDic!["resultCode"] as? String == "0")
            {
                // 退送到注册密码界面
                DispatchQueue.main.async
                    {
                        AppUtil.username = self.mobilePhoneInput.text
                        self.performSegue(withIdentifier: "setNewPasswordSegue", sender: nil)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    Toast.show(message: jsonDic!["resultMsg"] as? String)
                }
            }
        }
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
}

