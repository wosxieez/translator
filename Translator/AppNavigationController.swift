//
//  NavigationController.swift
//  TangdiTranslator
//
//  Created by coco on 29/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import Reachability

class AppNavigationController: UINavigationController {
    
    /// 心跳计时器
    var heartTimer:Timer?
    
    /// 是否是已登录状态
    var isLoggedIn = false
    
    /// 服务监控计时器
    var monitorTimer: Timer?
    
    /// 配网网络计时器
    var networkConfigTimer: Timer?
    
    var tbSocketSession: TBSocketSession!
    var cachedMessage: Message?
    var reachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbSocketSession = TBSocketSession()
        tbSocketSession.delegate = self
        interactivePopGestureRecognizer?.isEnabled = false
        
        monitorTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(onMonitorTimerAction), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLoginAction), name:AppNotification.AppLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appLogoutAction), name: AppNotification.AppLoout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageAction), name: AppNotification.SendMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkSocketStatusAction), name: AppNotification.CheckSocketStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkConfigBeganAction), name: AppNotification.NetworkConfigBegan, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkConfigSuccessAction), name: AppNotification.NetworkConfigSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkConfigFailAction), name: AppNotification.NetworkConfigFail, object: nil)
        
        reachability = Reachability()
        reachability.whenReachable = { (reachability) in
            // 网络恢复连接 检查服务连接情况
            print("网络恢复连接")
            if self.isLoggedIn, !self.tbSocketSession.isConnected {
                self.tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
            }
        }
        reachability.whenUnreachable = { (reachability) in
            print("发现网络断开")
        }
        do {
            try reachability.startNotifier()
        } catch {
        }
    }
    
    @objc func appLoginAction(notification: Notification) {
        isLoggedIn = true
        AppUtil.getAppKey()
        tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
        
        if let appLanguage = (UserDefaults.standard.value(forKey: "AppleLanguages") as? [String])?.first {
            var language = "en-US"
            if appLanguage.contains("zh-Hans") {
                language = "zh-CN"
            }
            
            AppService.getInstance().updateAppSetting(username: AppUtil.username, appLanguage: language)
            AppService.getInstance().getLanguageList(appLanguage: language) { (data, response, error) in
                guard data != nil, error == nil else { return }
                
                if let result = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any] {
                    if result["resultCode"] as? String == "0" {
                        if let languages = result["data"] as? [[String: Any]] {
                            AppUtil.deviceLanguages = []
                            
                            for language in languages {
                                AppUtil.deviceLanguages.append(DeviceLanguage(id: language["id"] as! Int,
                                                                              code: language["code"] as! String,
                                                                              name: language["name"] as! String,
                                                                              isORCEnabled: language["ocr"] as! Bool,
                                                                              isASREnabled: language["asr"] as! Bool,
                                                                              isTTSEnabled: language["tts"] as! Bool))
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func appLogoutAction(notification: Notification) {
        isLoggedIn = false
        AppUtil.currentDevice = nil
        
        // 用户注销 断开socket服务器 界面返回到登录界面
        tbSocketSession.disconnect()
        heartTimer?.invalidate()
        
        DispatchQueue.main.async {
            self.popViewController(animated: true)
        }
    }
    
    @objc func sendMessageAction(notification: Notification) {
        if let message = notification.object as? Message {
            if tbSocketSession.isConnected {
                // 服务已经连接直接发送消息
                tbSocketSession.sendMessage(message: message)
            } else {
                // 服务没有连接 将要发送的消息缓存起来 连接上再发送
                cachedMessage = message
                tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
            }
        }
    }
    
    /// 检查Socket连接状态
    @objc func checkSocketStatusAction(notification: Notification) {
        if isLoggedIn, !tbSocketSession.isConnected {
            tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
        }
    }
    
    @objc func onMonitorTimerAction() {
        if isLoggedIn, !tbSocketSession.isConnected {
            tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
        }
    }
    
    @objc func networkConfigBeganAction() {
        if !AppUtil.isNetworkConfigRunning {
            AppUtil.isNetworkConfigRunning = true
            
            DispatchQueue.main.async {
                self.networkConfigTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.networkConfigTimerAction), userInfo: nil, repeats: false)
            }
            
            print("网络配置开始...定时器开启")
        }
    }
    
    @objc func networkConfigTimerAction() {
        if AppUtil.isNetworkConfigRunning {
            AppUtil.isNetworkConfigRunning = false
            
            DispatchQueue.main.async {
                Toast.show(message: "配网失败".localizable())
            }
            
            print("网络配置结束...定时器关闭")
        }
    }
    
    @objc func networkConfigSuccessAction() {
        if AppUtil.isNetworkConfigRunning {
            AppUtil.isNetworkConfigRunning = false
            networkConfigTimer?.invalidate()
            
            DispatchQueue.main.async {
                Toast.show(message: "配网成功".localizable())
            }
            
            print("网络配置结束...定时器关闭")
        }
    }
    
    @objc func networkConfigFailAction() {
        if AppUtil.isNetworkConfigRunning {
            AppUtil.isNetworkConfigRunning = false
            networkConfigTimer?.invalidate()
            
            DispatchQueue.main.async {
                Toast.show(message: "配网失败".localizable())
            }
            
            print("网络配置结束...定时器关闭")
        }
    }
    
}


extension AppNavigationController: TBSocketSessionDelegate {
    
    func onConnect() {
        print("服务已连接")
        let content = ["username": AppUtil.username, "password": AppUtil.password?.md5()]
        let message = Message()
        message.type = "appLogin"
        message.content = content
        tbSocketSession.sendMessage(message: message)
    }
    
    func onDisconnect() {
        print("服务已断开")
        heartTimer?.invalidate()
    }
    
    func onMessage(message: Message) {
        switch message.type {
        case "appLogin":
            if let content = message.content as? [String: Any] {
                switch content["resultCode"] as? String {
                case "0":
                    // 登录成功,去主线程开启心跳计时器(为什么主线程:因为主线程RunLoop是启动的)
                    DispatchQueue.main.async {
                        self.heartTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.onHeartTimer), userInfo: nil, repeats: true)
                        self.heartTimer?.fire()
                    }
                    
                    // 已经登录成功了,如果有缓存的消息,将缓存的消息发送出去
                    if let message = cachedMessage {
                        tbSocketSession.sendMessage(message: message)
                        cachedMessage = nil
                    }
                case "1": // 登录失败,账号在其他地方登录
                    NotificationCenter.default.post(name: AppNotification.AppLoout, object: nil)
                    DispatchQueue.main.async {
                        Toast.show(message: content["resultMsg"] as? String, delayCloseTime: 3)
                    }
                default:
                    break
                }
            }
        case "S005":
            tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
        case "wificonfig":
            if (message.content as? [String: Any])?["state"] as? String == "true" {
                NotificationCenter.default.post(name: AppNotification.NetworkConfigSuccess, object: nil)
            } else {
                NotificationCenter.default.post(name: AppNotification.NetworkConfigFail, object: nil)
            }
        default:
            NotificationCenter.default.post(name: AppNotification.ReceiveMessage, object: message)
            break
        }
    }
    
    @objc func onHeartTimer() {
        let message:Message = Message()
        message.type = "heart"
        message.content = "heart"
        tbSocketSession.sendMessage(message: message)
    }
    
}
