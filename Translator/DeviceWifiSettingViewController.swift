//
//  DeviceWifiViewController.swift
//  Translator
//
//  Created by coco on 11/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit
import NetworkExtension

class DeviceWifiSettingViewController: UIViewController {
    
    var eyeImageView: UIImageView!
    var isEyeOn: Bool = false
    var tbSocketSession: TBSocketSession?
    var toast: Toast?
    var isConfigDeviceWifiSuccess: Bool = false
    @IBOutlet weak var ssidTextFiled: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(wifiSelectedAction), name: Notification.Name("wifiSelected"), object: nil)
        
        // ssid textField
        let wifiSelectImageView = UIImageView(image: UIImage(named: "deviceWifiSelectIcon"))
        wifiSelectImageView.center = CGPoint(x: 22, y: 22)
        let ssidRightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let ssidRightViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(ssidRightViewTapAction))
        ssidRightView.addGestureRecognizer(ssidRightViewTapGesture)
        ssidRightView.addSubview(wifiSelectImageView)
        ssidTextFiled.borderStyle = .none
        ssidTextFiled.rightView = ssidRightView
        ssidTextFiled.rightViewMode = .always
        
        // password textField
        passwordTextField.borderStyle = .none
        passwordTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        passwordTextField.rightViewMode = .always
        eyeImageView = UIImageView(image: UIImage(named: "deviceWifiEyeOffIcon"))
        eyeImageView.frame.size.width = 19
        eyeImageView.frame.size.height = 13
        eyeImageView.center = passwordTextField.rightView!.center
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(changePasswordAction))
        eyeImageView.addGestureRecognizer(tapGes)
        eyeImageView.isUserInteractionEnabled = true
        passwordTextField.rightView!.addSubview(eyeImageView)
        
        commitButton.layer.cornerRadius = 22
        
        if let wifiHistory = UserDefaults.standard.value(forKey: "wifiHistory2") as? [[String: String]] {
            ssidTextFiled.text = wifiHistory.last?["ssid"]
            passwordTextField.text = wifiHistory.last?["password"]
        } else if let ssid = AppUtil.getSSID() {
            ssidTextFiled.text = ssid
            passwordTextField.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = AppUtil.themeColor
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func wifiSelectedAction(notification: Notification) {
        if let wifi = notification.object as? [String: String] {
            ssidTextFiled.text = wifi["ssid"]
            passwordTextField.text = wifi["password"]
        }
    }
    
    @objc func changePasswordAction() {
        isEyeOn = !isEyeOn
        if isEyeOn {
            eyeImageView.image = UIImage(named: "deviceWifiEyeOnIcon")
            passwordTextField.isSecureTextEntry = false
        } else {
            eyeImageView.image = UIImage(named: "deviceWifiEyeOffIcon")
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func doConfigWifiAction() {
        if AppUtil.getSSID() == "tangdi" {
            beganConfigDeviceWifiTip() // 开始配网提示
            prepareConfigDeviceWifi()
        } else {
//            if #available(iOS 11.0, *) {
//                beganConfigDeviceWifiTip() // 开始配网提示
//                let hotspotConfig = NEHotspotConfiguration(ssid: "tangdi", passphrase: "12345678", isWEP: false)
//                NEHotspotConfigurationManager.shared.apply(hotspotConfig) { (error) in
//                    if AppUtil.getSSID() == "tangdi" {
//                        self.prepareConfigDeviceWifi()
//                    } else {
//                        self.endConfigDeviceWifiTip(result: false) // 结束配网提示
//                    }
//                }
//            } else {
//                let ac = UIAlertController(title: "提示", message: "请先连接设备WIFI\rssid: tangdi\rpassword: 12345678", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
//                present(ac, animated: true, completion: nil)
//            }
        }
    }
    
    func beganConfigDeviceWifiTip() {
        DispatchQueue.main.async {
            if self.toast == nil {
                self.toast = Toast(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            }
            self.toast?.open(message: "正在配网...", delayCloseTime: 0)
            self.commitButton.isEnabled = false
            self.commitButton.alpha = 0.5
        }
    }
    
    func endConfigDeviceWifiTip(result: Bool) {
        DispatchQueue.main.async {
            if result {
                self.toast?.open(message: "配网成功", delayCloseTime: 3)
                self.saveWifiHistory()
            } else {
                self.toast?.open(message: "配网失败", delayCloseTime: 3)
            }
            self.commitButton.isEnabled = true
            self.commitButton.alpha = 1
        }
    }
    
    /// 准备配置网络
    func prepareConfigDeviceWifi() {
        perform(#selector(startConfigDeviceWifi), with: nil, afterDelay: 3)
    }
    
    /// 开始配置网络
    @objc func startConfigDeviceWifi() {
        isConfigDeviceWifiSuccess = false
        tbSocketSession = TBSocketSession()
        tbSocketSession?.delegate = self
        tbSocketSession?.connect(host: "192.168.1.1", port: 9099)
    }
    
    @objc func ssidRightViewTapAction() {
        present(UINavigationController(rootViewController: DeviceWifiListViewController(style: .grouped)), animated: true, completion: nil)
    }
    
    @objc func passwordRightViewTapAction() {
        
    }
    
    func saveWifiHistory() {
        if let ssid = ssidTextFiled.text {
            if var wifiHistory = UserDefaults.standard.value(forKey: "wifiHistory2") as? [[String: String]] {
                for index in (0..<wifiHistory.count).reversed() {
                    if wifiHistory[index]["ssid"] == ssid {
                        wifiHistory.remove(at: index)
                    }
                }
                if let password = passwordTextField.text {
                    wifiHistory.append(["ssid": ssid, "password": password])
                }
                if wifiHistory.count > 5 {
                    wifiHistory.removeFirst()
                }
                UserDefaults.standard.setValue(wifiHistory, forKey: "wifiHistory2")
            } else {
                if let password = passwordTextField.text {
                    UserDefaults.standard.setValue([["ssid": ssid, "password": password]], forKey: "wifiHistory2")
                }
            }
        }
    }
    
}

extension DeviceWifiSettingViewController: TBSocketSessionDelegate {
    func onConnect() {
        DispatchQueue.main.async {
            let content = ["ssid": self.ssidTextFiled.text,
                           "password": self.passwordTextField.text]
            let message = Message()
            message.type = "apConfig"
            message.content = content
            self.tbSocketSession?.sendMessage(message: message)
        }
    }
    
    func onDisconnect() {
        // 没有配置成功就断开了 提示配网失败
        if !isConfigDeviceWifiSuccess {
            endConfigDeviceWifiTip(result: false)
        }
    }
    
    func onMessage(message: Message) {
        if message.type == "apConfig" {
            if let content = message.content as? [String: Any] {
                if content["resultCode"] as? String == "0" {
                    isConfigDeviceWifiSuccess = true
                    endConfigDeviceWifiTip(result: true)
                    DispatchQueue.main.async {
                        self.perform(#selector(self.doBackToRootAction), with: nil, afterDelay: 1)
                    }
                }
            }
        }
    }
    
    @objc func doBackToRootAction() {
        navigationController?.popViewController(animated: true)
    }
    
}
