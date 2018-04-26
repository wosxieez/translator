//
//  NavigationController.swift
//  TangdiTranslator
//
//  Created by coco on 29/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
    
    var heartTimer:Timer?   // 心跳计时器
    var tbSocketSession: TBSocketSession!
    var cachedMessage: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 禁用手势滑动
        interactivePopGestureRecognizer?.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLoginAction), name:AppNotification.AppLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appLogoutAction), name: AppNotification.AppLoout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageAction), name: AppNotification.SendMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkSocketStatusAction), name: AppNotification.CheckSocketStatus, object: nil)
        
        tbSocketSession = TBSocketSession()
        tbSocketSession.delegate = self
    }
    
    @objc func appLoginAction(notification: Notification) {
        // 登录成功 开始获取文本翻译Key 识别Key OCR Key. 连接socket服务器
        AppUtil.getAppKey()
        tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
    }
    
    @objc func appLogoutAction(notification: Notification) {
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
        if !tbSocketSession.isConnected {
            tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
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
                case "1":
                    // 登录失败,账号在其他地方登录
                    DispatchQueue.main.async {
                        Toast.show(message: content["resultMsg"] as? String, delayCloseTime: 3)
                        self.navigationController?.popViewController(animated: true)
                    }
                default:
                    break
                }
            }
        case "S005":
            tbSocketSession.connect(host: AppUtil.socketServerHost, port: AppUtil.socketServerPort)
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
