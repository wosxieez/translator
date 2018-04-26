//
//  DeviceViewController.swift
//  Translator
//
//  Created by coco on 07/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController {
    
    
    @IBOutlet weak var deviceTitleButton: UIButton!
    @IBOutlet weak var deviceStatusLabel: UILabel!
    @IBOutlet weak var topBgImageView: UIImageView!
    @IBOutlet weak var topIconButton: UIButton!
    @IBOutlet weak var devicePowerImageView: UIImageView!
    @IBOutlet weak var deviceWifiImageView: UIImageView!
    @IBOutlet weak var deviceSourceButton: UIButton!
    @IBOutlet weak var deviceTargetButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航透明
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // 监听通知
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessageAction), name: AppNotification.ReceiveMessage, object: nil) // 监听收到消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(needUpdateDeviceInfoAction), name: AppNotification.NeedUpdateDeviceInfo, object: nil) // 监听当前设备发生变化通知
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDeviceInfoAction), name: AppNotification.DidUpdateDeviceInfo, object: nil) // 监听设备发生变化通知
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getBindingDeviceDetail()
        NotificationCenter.default.post(name: AppNotification.CheckSocketStatus, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let scale = view.bounds.width / topBgImageView.image!.size.width
        topBgImageView.frame.size.width = view.bounds.width
        topBgImageView.frame.size.height = topBgImageView.image!.size.height * scale
        
        topIconButton.frame.size.width = topIconButton.backgroundImage(for: .normal)!.size.width * scale
        topIconButton.frame.size.height = topIconButton.backgroundImage(for: .normal)!.size.height * scale
        topIconButton.center.x = view.center.x
        topIconButton.contentMode = .center
        topIconButton.frame.origin.y = 180 * scale
        
        devicePowerImageView.center.y = topIconButton.center.y
        devicePowerImageView.center.x = topIconButton.center.x - topIconButton.frame.size.width / 2 - devicePowerImageView.frame.size.width - 25
        
        deviceWifiImageView.center.y = topIconButton.center.y
        deviceWifiImageView.center.x = topIconButton.center.x + topIconButton.frame.size.width / 2 + 50
    }
    
    @objc func receiveMessageAction(notification: Notification) {
        if let message = notification.object as? Message {
            switch message.type {
            case "devTransmit":
                if let deviceMessage = message.content as? [String: Any] {
                    if let deviceMessageType = deviceMessage["type"] as? String {
                        switch deviceMessageType {
                        case "devStatus":
                            if deviceMessage["username"] as? String == AppUtil.currentDevice?["deviceNo"] as? String {
                                // 设备 wifi 电量状态
                                var newDeivce = AppUtil.currentDevice!
                                newDeivce["wifiname"] = deviceMessage["wifiname"]
                                newDeivce["wifi"] = String(deviceMessage["wifi"] as! Int)
                                newDeivce["power"] = String(deviceMessage["electricity"] as! Int)
                                AppUtil.currentDevice = newDeivce
                            }
                        case "setDeviceTime", "setSpeakTime", "setVoiceType", "setTransLanguage":
                            DispatchQueue.main.async {
                                if deviceMessage["content"] as? String == "success" {
                                    Toast.show(message: "设置成功")
                                    // 设备设置成功 需要重新更新下设备信息
                                    NotificationCenter.default.post(name: AppNotification.NeedUpdateDeviceInfo, object: nil)
                                } else {
                                    Toast.show(message: "设置失败")
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            case "S001":
                if let deviceMessage = message.content as? [String: Any] {
                    if let deviceNo = deviceMessage["deviceNo"] as? String {
                        if let currentDeviceNo = AppUtil.currentDevice?["deviceNo"] as? String {
                            if currentDeviceNo == deviceNo {
                                var newDevice = AppUtil.currentDevice
                                newDevice?["onStatus"] = deviceMessage["status"]
                                AppUtil.currentDevice = newDevice
                            }
                        }
                    }
                }
            case "boundReplace":
                // 设备102018000307461b绑定到其他APP用户,需要重新更新下设备信息
                NotificationCenter.default.post(name: AppNotification.NeedUpdateDeviceInfo, object: nil)
                DispatchQueue.main.async {
                    Toast.show(message: "设备已被其他用户绑定")
                }
            default:
                break
            }
        }
    }
    
    @objc func needUpdateDeviceInfoAction() {
        // 设备绑定发生变化了 重新加载下设备明细
        getBindingDeviceDetail()
    }
    
    @objc func didUpdateDeviceInfoAction() {
        DispatchQueue.main.async {
            self.updateDeviceView()
        }
    }
    
    func updateDeviceView() {
        if let device = AppUtil.currentDevice {
            print(device)
            // 设置电量显示
            if let powerString = device["power"] as? String {
                if let power = Int(powerString) {
                    if power <= 100 && power > 75 {
                        devicePowerImageView.image = UIImage(named: "devicePower4")
                    } else if power <= 75 && power > 50 {
                        devicePowerImageView.image = UIImage(named: "devicePower3")
                    } else if power <= 50 && power > 25 {
                        devicePowerImageView.image = UIImage(named: "devicePower2")
                    } else {
                        devicePowerImageView.image = UIImage(named: "devicePower1")
                    }
                }
            }
            
            // wifi信号
            if let wifiString = device["wifi"] as? String {
                if let wifi = Int(wifiString) {
                    if wifi <= 100 && wifi > 200 / 3 {
                        deviceWifiImageView.image = UIImage(named: "deviceWifi3")
                    } else if wifi <= 200 / 3 && wifi > 100 / 3 {
                        deviceWifiImageView.image = UIImage(named: "deviceWifi2")
                    } else {
                        deviceWifiImageView.image = UIImage(named: "deviceWifi1")
                    }
                }
            }
            
            // 更新设备标题
            if let deviceNo = device["deviceNo"] as? String {
                deviceTitleButton.setTitle("设备" + deviceNo.suffix(5), for: .normal)
                deviceTitleButton.sizeToFit()
            }
            
            // 更新设备在线状态
            if let status = device["onStatus"] as? String {
                if status == "00" {
                    deviceStatusLabel.text = "在线"
                    topIconButton.setBackgroundImage(UIImage(named: "device_top_icon_online.png"), for: .normal)
                } else {
                    deviceStatusLabel.text = "离线"
                    topIconButton.setBackgroundImage(UIImage(named: "device_top_icon_offline.png"), for: .normal)
                }
            }
            
            // 更新源语言
            if let sourceRecognitionCode = device["languageFrom"] as? String {
                if let sourceLanguage = AppUtil.getLanguage(by: sourceRecognitionCode) {
                    deviceSourceButton.setTitle(sourceLanguage.name, for: .normal)
                }
            }
            
            // 更新目标语言
            if let targetRecognitionCode = device["languageTo"] as? String {
                if let targetLanguage = AppUtil.getLanguage(by: targetRecognitionCode) {
                    deviceTargetButton.setTitle(targetLanguage.name, for: .normal)
                }
            }
        } else {
            deviceTitleButton.setTitle("无绑定设备", for: .normal)
            deviceTitleButton.sizeToFit()
            deviceStatusLabel.text = "离线"
            topIconButton.setBackgroundImage(UIImage(named: "device_top_icon_offline.png"), for: .normal)
            deviceWifiImageView.image = UIImage(named: "deviceWifi1")
            devicePowerImageView.image = UIImage(named: "devicePower1")
            deviceSourceButton.setTitle("中文", for: .normal)
            deviceTargetButton.setTitle("英文", for: .normal)
        }
    }
    
    @IBAction func setDeviceSettingAction(_ sender: Any) {
        if let device = AppUtil.currentDevice {
            if device["onStatus"] as? String == "00" {
                performSegue(withIdentifier: "showDeviceSettingVC", sender: nil)
            } else {
                Toast.show(message: "设备离线")
            }
        } else {
            Toast.show(message: "无可用设备")
        }
    }
    
    @IBAction func setDeviceSourceLanguageAction(_ sender: Any) {
        if let device = AppUtil.currentDevice {
            if device["onStatus"] as? String == "00" {
                let viewController = DeviceLanguageViewController()
                viewController.isDeviceSourceLanguage = true
                let navigationViewController = UINavigationController(rootViewController: viewController)
                present(navigationViewController, animated: true, completion: nil)
            } else {
                Toast.show(message: "设备离线")
            }
        } else {
            Toast.show(message: "无可用设备")
        }
    }
    
    @IBAction func setDeviceTargetLanguageAction(_ sender: Any) {
        if let device = AppUtil.currentDevice {
            if device["onStatus"] as? String == "00" {
                let viewController = DeviceLanguageViewController()
                viewController.isDeviceSourceLanguage = false
                present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
            } else {
                Toast.show(message: "设备离线")
            }
        } else {
            Toast.show(message: "无可用设备")
        }
    }
    
    @IBAction func switchDeviceAction(_ send: Any) {
        if AppUtil.currentDevice != nil {
             present(UINavigationController(rootViewController: DeviceListViewController()), animated: true, completion: nil)
        }
    }
    
    /// 获取绑定设备的详细信息
    func getBindingDeviceDetail() {
        AppService.getInstance().queryDeviceList { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) {
                if let object = jsonObject as? [String: Any] {
                    if object["resultCode"] as? String == "00" {
                        if let devList = object["devList"] as? [[String: Any]] {
                            if devList.count > 0 {
                                if let device = devList.first {
                                    AppService.getInstance().queryDeviceDetail(deviceNo: device["deviceNo"] as! String) { (data, response, error) in
                                        guard data != nil && error == nil else { return }
                                        if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) {
                                            if let object = jsonObject as? [String: Any] {
                                                if object["resultCode"] as? String == "0" {
                                                    AppUtil.currentDevice = object
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                AppUtil.currentDevice = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
}
