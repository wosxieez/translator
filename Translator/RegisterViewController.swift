//
//  RegisterViewController.swift
//  TangdiTranslator
//
//  Created by coco on 15/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var mobilePhoneInput: UITextField!
    @IBOutlet weak var mobileCodeInput: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    
    var sendMobileCodeButton:UIButton!
    
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
        mobileCodeInput.keyboardType = UIKeyboardType.phonePad
        
        commitButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default // 黑色字体状态栏
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
    
    var resendTimer:DispatchSourceTimer?
    var resendCount:Int = 30
    
    /**
     用户请求验证码
     */
    @objc func sendMobileCodeAction() -> Void {
        guard AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!) else {
            Toast.show(message: "请输入有效的手机号码".localizable())
            return
        }
        
        // 检查用户是否已经注册了
        AppService.getInstance().checkUser(username: mobilePhoneInput.text!, completionHandler: checkUserCompletionHandler)
    }
    
    func checkUserCompletionHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败".localizable())
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
                Toast.show(message: "请求失败".localizable())
            }
        }
    }
    
    func sendMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败".localizable())
                return
            }
            
            let jsonDic = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any]
            if let resultCode = jsonDic?["resultCode"] {
                if resultCode as? String == "0" {
                    self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                    self.sendMobileCodeButton.setTitleColor(UIColor.gray, for: .normal)
                    self.sendMobileCodeButton.isEnabled = false
                    self.startTimer(count: 30)
                } else if resultCode as? String == "1" {
                    self.sendMobileCodeButton.layer.borderColor = UIColor.gray.cgColor
                    self.sendMobileCodeButton.setTitleColor(UIColor.gray, for: .normal)
                    self.sendMobileCodeButton.isEnabled = false
                    self.startTimer(count: 30 - Int(jsonDic!["timeDiffer"] as! String)!)
                }
                Toast.show(message: jsonDic!["resultMsg"] as? String)
            } else {
                Toast.show(message: "请求失败".localizable())
            }
        }
    }
    
    func startTimer(count:Int) -> Void {
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
    @objc func verifyMobileCode() -> Void {
        if !AppUtil.isPhoneNumber(phoneNumber: mobilePhoneInput.text!) {
            Toast.show(message: "请输入有效的手机号码".localizable())
            return
        }
        if mobileCodeInput.text == nil || mobileCodeInput.text == "" {
            Toast.show(message: "请输入有效的验证码".localizable())
            return
        }
        
        AppService.getInstance().verifyMobileCode(mobilePhone: mobilePhoneInput.text,
                                                  mobileCode: mobileCodeInput.text,
                                                  completionHandler: verifyMobileCodeHandler)
    }
    
    func verifyMobileCodeHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            guard error == nil && data != nil else {
                Toast.show(message: "请求失败".localizable())
                return
            }
            
            let jsonDic = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any]
            if let resultCode = jsonDic?["resultCode"] {
                if resultCode as? String == "0" {
                    DispatchQueue.main.async {
                        AppUtil.uesrnameForRegister = self.mobilePhoneInput.text
                        self.performSegue(withIdentifier: "setPasswordSegue", sender: nil)
                    }
                }
                else {
                    Toast.show(message: jsonDic!["resultMsg"] as? String)
                }
            }
            else {
                Toast.show(message: "请求失败".localizable())
            }
        }
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commitAction() {
        verifyMobileCode()
    }
    
}
