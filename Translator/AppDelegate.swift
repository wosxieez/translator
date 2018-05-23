//
//  AppDelegate.swift
//  TangdiTranslator
//
//  Created by coco on 24/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 线程睡眠一秒 为了延长启动界面显示
        Thread.sleep(forTimeInterval: 1)
        
        // 软键盘管理器启动
        IQKeyboardManager.shared.enable = true
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { (permission, error) in
                if permission {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let nsdataStr = NSData.init(data: deviceToken)
        let deviceToken = nsdataStr.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        print("注册远程通知成功: \(deviceToken)")
        
        AppService.getInstance().registerDeviceToken(token: deviceToken, completionHandler: registerDeviceTokenCompletionHandler)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("注册远程通知失败")
    }
    
    func registerDeviceTokenCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard data != nil, error == nil else { return }
        
        if let result = (try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)) as? [String: Any] {
            print(result)
        }
    }
    
}

