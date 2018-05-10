//
//  DeviceSettingViewController.swift
//  Translator
//
//  Created by coco on 20/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceSettingViewController: UITableViewController {
    
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var speakTimeCell: UITableViewCell!
    @IBOutlet weak var shutdownTimeCell: UITableViewCell!
    @IBOutlet weak var standbyTimeCell: UITableViewCell!
    @IBOutlet weak var deviceVersionCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        title = "设备设置".localizable()
        view.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateDeviceInfoAction), name: AppNotification.DidUpdateDeviceInfo,  object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        navigationController?.navigationBar.tintColor = AppUtil.themeColor // 导航栏颜色设置为主题色
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.isUserInteractionEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 1 else { return }
        
        switch indexPath.row {
        case 0: // 自动关机时间
            let deviceSettingTableViewController = DeviceSettingTableViewController(flat: 0)
            show(deviceSettingTableViewController, sender: nil)
        case 1: // 待机时长
            let deviceSettingTableViewController = DeviceSettingTableViewController(flat: 1)
            show(deviceSettingTableViewController, sender: nil)
        case 2: // 录音时长
            let deviceSettingTableViewController = DeviceSettingTableViewController(flat: 2)
            show(deviceSettingTableViewController, sender: nil)
        case 3:
            // 版本信息
            break
        case 4:
            // 删除设备
            let alertController = UIAlertController(title: "提示".localizable(), message: "确定要删除当前设备吗？".localizable(), preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "取消".localizable(), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "确定".localizable(), style: .destructive, handler: { (action) in
                AppService.getInstance().deleteDevice(deviceNo: AppUtil.currentDevice?["deviceNo"] as? String, completionHandler: { (data, response, error) in
                    guard data != nil && error == nil else { return }
                    if let object = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any] {
                        DispatchQueue.main.async {
                            if object["resultCode"] as? String == "00" {
                                Toast.show(message: "设备删除成功".localizable())
                                NotificationCenter.default.post(name: AppNotification.NeedUpdateDeviceInfo, object: nil)
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                Toast.show(message: "设备删除失败".localizable())
                            }
                        }
                    }
                })
            }))
            present(alertController, animated: true, completion: nil)
        default:
            break
        }
        
        // 操作完毕后 取消选中
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func deviceChangedAction() {
        
    }
    
    @objc func didUpdateDeviceInfoAction() {
        DispatchQueue.main.async {
            // 如果当前设备为空，直接返回到设备界面
            if let device = AppUtil.currentDevice {
                if device["onStatus"] as? String == "01" {
                    Toast.show(message: "设备离线".localizable())
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.updateView()
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    ///
    /// 更新界面显示
    ///
    func updateView() {
        // 设置发音人性别 男/女
        if AppUtil.currentDevice?["voiceSex"] as? String == "female" {
            refreshGenderView(isMale: false)
        } else {
            refreshGenderView(isMale: true)
        }
        
        // 设置录音时长
        if let speakTime = AppUtil.currentDevice?["speakTime"] as? Int {
            speakTimeCell.detailTextLabel?.text = String(speakTime) + "秒".localizable()
        } else {
            speakTimeCell.detailTextLabel?.text = ""
        }
        
        // 设置自动关机时间
        if let shutdownTime  = AppUtil.currentDevice?["shutdownTime"] as? Int {
            shutdownTimeCell.detailTextLabel?.text = String(shutdownTime) + "分钟".localizable()
        } else {
            shutdownTimeCell.detailTextLabel?.text = ""
        }
        
        // 设置待机时间
        if let standbyTime = AppUtil.currentDevice?["standbyTime"] as? Int {
            standbyTimeCell.detailTextLabel?.text = String(standbyTime) + "分钟".localizable()
        } else {
            standbyTimeCell.detailTextLabel?.text = ""
        }
        
        // 设备版本号
        if let deviceVersion = AppUtil.currentDevice?["version"] as? String {
            deviceVersionCell.detailTextLabel?.text = deviceVersion
        } else {
            deviceVersionCell.detailTextLabel?.text = ""
        }
    }
    
    ///
    /// 男生图片被点击事件方法
    ///
    @IBAction func tapMaleImageViewAction() {
        // 发送指令包
        var deviceContent: [String: Any] = [:]
        deviceContent["voicetype"] = "male"
        
        var deviceMessage: [String: Any] = [:]
        deviceMessage["source"] = AppUtil.username
        deviceMessage["target"] = AppUtil.currentDevice?["deviceNo"]
        deviceMessage["type"] = "setVoiceType"
        deviceMessage["content"] = deviceContent
        
        let message = Message()
        message.type = "appTransmit"
        message.content = deviceMessage
        
        NotificationCenter.default.post(name: AppNotification.SendMessage, object: message)
    }
    
    ///
    /// 女生图片被点击事件方法
    ///
    @IBAction func topFemaleImageViewAction() {
        // 发送指令包
        var deviceContent: [String: Any] = [:]
        deviceContent["voicetype"] = "female"
        
        var deviceMessage: [String: Any] = [:]
        deviceMessage["source"] = AppUtil.username
        deviceMessage["target"] = AppUtil.currentDevice?["deviceNo"]
        deviceMessage["type"] = "setVoiceType"
        deviceMessage["content"] = deviceContent
        
        let message = Message()
        message.type = "appTransmit"
        message.content = deviceMessage
        
        NotificationCenter.default.post(name: AppNotification.SendMessage, object: message)
    }
    
    ///
    /// 刷新性别选中视图
    ///
    func refreshGenderView(isMale: Bool) {
        if isMale {
            maleButton.setImage(UIImage(named: "gender_selected.png"), for: .normal)
            femaleButton.setImage(UIImage(named: "gender_unselected.png"), for: .normal)
        } else {
            maleButton.setImage(UIImage(named: "gender_unselected.png"), for: .normal)
            femaleButton.setImage(UIImage(named: "gender_selected.png"), for: .normal)
        }
    }
    
    ///
    /// 检查设备的版本信息
    ///
    func checkDeviceVersion() {
        
        AppService.getInstance().queryDeviceLatestVersion(deviceNo: AppUtil.currentDevice?["deviceNo"] as? String) { (data, response, error) in
            
            guard data != nil && error == nil else { return }
            
            if let result = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any] {
                
                if result["resultCode"] as? String == "0" && result["isLast"] as? Int == 1 {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "固件更新".localizable(), message: "是否升级到最新版本: ".localizable() + (result["version"] as! String), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "取消".localizable().localizable(), style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "确定".localizable(), style: .default, handler: { (action) in
                            
                            // 通知设备更新到最新版本
                            var deviceContent: [String: Any] = [:]
                            deviceContent["version"] = result["version"] as? String
                            
                            var deviceMessage: [String: Any] = [:]
                            deviceMessage["source"] = AppUtil.username
                            deviceMessage["target"] = AppUtil.currentDevice?["deviceNo"]
                            deviceMessage["type"] = "noticeDeviceUpdate"
                            deviceMessage["content"] = deviceContent
                            
                            let message = Message()
                            message.type = "appTransmit"
                            message.content = deviceMessage
                            
                            NotificationCenter.default.post(name: AppNotification.SendMessage, object: message)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}
