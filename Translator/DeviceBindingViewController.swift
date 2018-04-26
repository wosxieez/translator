//
//  DeviceWifiViewController.swift
//  Translator
//
//  Created by coco on 11/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceBindingViewController: UIViewController {
    
    @IBOutlet weak var textField1: UITextView!
    @IBOutlet weak var textField2: UITextView!
    @IBOutlet weak var textField3: UITextView!
    @IBOutlet weak var textField4: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField1.tag = 1
        textField1.delegate = self
        textField1.tintColor = UIColor.white
        textField1.backgroundColor = UIColor.clear
        textField1.becomeFirstResponder()
        textField1.layer.borderColor = UIColor.white.cgColor
        textField1.layer.cornerRadius = 5
        textField1.layer.borderWidth = 0.5
        
        textField2.tag = 2
        textField2.delegate = self
        textField2.tintColor = UIColor.white
        textField2.backgroundColor = UIColor.clear
        textField2.layer.borderColor = UIColor.white.cgColor
        textField2.layer.cornerRadius = 5
        textField2.layer.borderWidth = 0.5
        
        textField3.tag = 3
        textField3.delegate = self
        textField3.tintColor = UIColor.white
        textField3.backgroundColor = UIColor.clear
        textField3.layer.borderColor = UIColor.white.cgColor
        textField3.layer.cornerRadius = 5
        textField3.layer.borderWidth = 0.5
        
        textField4.tag = 4
        textField4.delegate = self
        textField4.tintColor = UIColor.white
        textField4.backgroundColor = UIColor.clear
        textField4.layer.borderColor = UIColor.white.cgColor
        textField4.layer.cornerRadius = 5
        textField4.layer.borderWidth = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = AppUtil.themeColor
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func doConfigWifiAction() {
        let code = textField1.text + textField2.text + textField3.text + textField4.text
        AppService.getInstance().bindDevice(deviceCode: code) { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let dicData = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                if let resultCode = dicData["resultCode"] as? String {
                    DispatchQueue.main.async {
                        switch resultCode {
                        case "00":
                            // 派发设备绑定发送变化通知并切换到设备界面
                            NotificationCenter.default.post(name: AppNotification.NeedUpdateDeviceInfo, object: nil)
                            self.navigationController?.popToRootViewController(animated: true)
                            Toast.show(message: "绑定成功")
                        default:
                            Toast.show(message: dicData["resultMsg"] as? String)
                        }
                    }
                }
            }
        }
    }
    
}

extension DeviceBindingViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            if textView.text.count == 0 {
                // 跳转到上个输入框
                if let preView = view.viewWithTag(textView.tag - 1) as? UITextView {
                    preView.becomeFirstResponder()
                }
            }
        } else {
            if textView.text.count >= 1{
                return false
            }
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count >= 1 {
            // 跳转到下个输入框
            if let nextView = view.viewWithTag(textView.tag + 1) as? UITextView {
                nextView.becomeFirstResponder()
            } else {
                doConfigWifiAction()
            }
        }
    }
    
}
