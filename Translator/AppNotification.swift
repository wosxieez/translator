//
//  AppNotification.swift
//  Translator
//
//  Created by coco on 2018/4/20.
//  Copyright © 2018 coco. All rights reserved.
//

import Foundation


class AppNotification {
    
    /// 程序登录成功通知
    static let AppLogin = Notification.Name("appLogin")
    
    /// 程序退出登录通知
    static let AppLoout = Notification.Name("appLoout")
    
    /// 通知检查Socket服务状态，如果Socket没有连接，尝试重新连接
    static let CheckSocketStatus = Notification.Name("checkSocketStatus")
    
    /// 发送Socket消息通知
    static let SendMessage = Notification.Name("sendMessage")
    
    /// 接收Socket消息通知
    static let ReceiveMessage = Notification.Name("receiveMessage")
    
    /// 需要更新设备信息
    static let NeedUpdateDeviceInfo = Notification.Name("needUpdateDeviceInfo")
    
    /// 完成更新设备信息
    static let DidUpdateDeviceInfo = Notification.Name("didUpdateDeviceInfo")
    
    /// 配网开始
    static let NetworkConfigBegan = Notification.Name("networkConfigBegan")
    
    /// 配网成功
    static let NetworkConfigSuccess = Notification.Name("networkConfigSuccess")
    
    /// 配网失败
    static let NetworkConfigFail = Notification.Name("networkConfigFail")
    
}
