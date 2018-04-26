//
//  ConfigWIFIViewController.swift
//  配置设备网络界面
//
//  Created by coco on 15/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork;

class ConfigWIFIViewController: UIViewController
{
    
    var wifiUserName:UITextField!;
    var wifiPasswrod:UITextField!;
    var bssid:String!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // 白色背景
        view.backgroundColor = UIColor.white;
        
        title = "设备配网";
        
        // 添加一个UILabel 用于显示当前正在连接的WIFI名称
        wifiUserName = UITextField();
        wifiUserName.borderStyle = UITextBorderStyle.roundedRect;
        wifiUserName.translatesAutoresizingMaskIntoConstraints = false;
        wifiUserName.isEnabled = false;
        view.addSubview(wifiUserName);
        
        let leadingConstraint1:NSLayoutConstraint = NSLayoutConstraint(item: wifiUserName,
                                                                       attribute: .leading,
                                                                       relatedBy: .equal,
                                                                       toItem: view,
                                                                       attribute: .leading,
                                                                       multiplier: 1, constant: 10);
        let trailingConstraint1:NSLayoutConstraint = NSLayoutConstraint(item: view,
                                                                        attribute: NSLayoutAttribute.trailing,
                                                                        relatedBy: .equal,
                                                                        toItem: wifiUserName,
                                                                        attribute: NSLayoutAttribute.trailing,
                                                                        multiplier: 1, constant: 10);
        let topConstraint1:NSLayoutConstraint = NSLayoutConstraint(item: wifiUserName,
                                                                   attribute: .top,
                                                                   relatedBy: .equal, toItem: topLayoutGuide,
                                                                   attribute: .bottom,
                                                                   multiplier: 1, constant: 20);
        let heightConstraint1:NSLayoutConstraint = NSLayoutConstraint(item: wifiUserName,
                                                                      attribute: .height,
                                                                      relatedBy: .equal,
                                                                      toItem: nil,
                                                                      attribute: NSLayoutAttribute.notAnAttribute,
                                                                      multiplier: 1, constant: 44);
        
        view.addConstraint(leadingConstraint1);
        view.addConstraint(trailingConstraint1);
        view.addConstraint(topConstraint1);
        wifiUserName.addConstraint(heightConstraint1);
        
        wifiPasswrod = UITextField();
        wifiPasswrod.borderStyle = UITextBorderStyle.roundedRect;
        wifiPasswrod.keyboardType = .numberPad;
        wifiPasswrod.text = "tangdi901@";
        wifiPasswrod.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(wifiPasswrod);
        
        // 创建wifiPasswrod的约束
        let topConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: wifiPasswrod,
                                                                   attribute: .top,
                                                                   relatedBy: .equal,
                                                                   toItem: wifiUserName,
                                                                   attribute: .bottom,
                                                                   multiplier: 1, constant: 20);
        let leadingConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: wifiPasswrod,
                                                                       attribute: .leading, 
                                                                       relatedBy: .equal,
                                                                       toItem: view,
                                                                       attribute: .leading,
                                                                       multiplier: 1, constant: 10);
        let trailingConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: view,
                                                                        attribute: .trailing,
                                                                        relatedBy: .equal,
                                                                        toItem: wifiPasswrod,
                                                                        attribute: .trailing,
                                                                        multiplier: 1, constant: 10);
        let heightConstraint2:NSLayoutConstraint = NSLayoutConstraint(item: wifiPasswrod,
                                                                      attribute: .height,
                                                                      relatedBy: .equal,
                                                                      toItem: nil,
                                                                      attribute: .notAnAttribute,
                                                                      multiplier: 1, constant: 44);
        view.addConstraint(topConstraint2);
        view.addConstraint(leadingConstraint2);
        view.addConstraint(trailingConstraint2);
        wifiPasswrod.addConstraint(heightConstraint2);
        
        let confirmButton:UIButton = UIButton(type: .system);
        confirmButton.frame = CGRect(x: 0, y: 100, width: 200, height: 44);
        confirmButton.setTitle("确定", for: .normal);
        confirmButton.translatesAutoresizingMaskIntoConstraints = false;
        confirmButton.addTarget(self, action: #selector(doConfigWifi), for: .touchUpInside);
        confirmButton.backgroundColor = UIColor.red;
        confirmButton.setTitleColor(UIColor.white, for: .normal);
        view.addSubview(confirmButton);
        
        // 添加ConfirmButton约束
        let leadingConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: confirmButton,
                                                                       attribute: .leading,
                                                                       relatedBy: .equal,
                                                                       toItem: view,
                                                                       attribute: .leading,
                                                                       multiplier: 1, constant: 10);
        let trailingConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: view,
                                                                        attribute: .trailing,
                                                                        relatedBy: .equal,
                                                                        toItem: confirmButton,
                                                                        attribute: .trailing,
                                                                        multiplier: 1,
                                                                        constant: 10);
        let topConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: confirmButton,
                                                                   attribute: .top,
                                                                   relatedBy: .equal,
                                                                   toItem: wifiPasswrod ,
                                                                   attribute: .bottom,
                                                                   multiplier: 1, constant: 20);
        let heightConstraint3:NSLayoutConstraint = NSLayoutConstraint(item: confirmButton, attribute: .height,
                                                                      relatedBy: .equal,
                                                                      toItem: nil,
                                                                      attribute: .notAnAttribute,
                                                                      multiplier: 1, constant: 44);
        view.addConstraint(leadingConstraint3);
        view.addConstraint(trailingConstraint3);
        view.addConstraint(topConstraint3);
        confirmButton.addConstraint(heightConstraint3);
        
        // get wifi info
        let interfaces:CFArray? = CNCopySupportedInterfaces();
        let interfacesArray:[AnyObject] = CFBridgingRetain(interfaces) as! [AnyObject];
        let interfaceName:CFString = interfacesArray[0] as! CFString;
        let interfaceData:CFDictionary! = CNCopyCurrentNetworkInfo(interfaceName);
        let interfaceDic:[String: Any]? = interfaceData as? [String: Any];
        if (interfaceDic != nil)
        {
            wifiUserName.text = interfaceDic!["SSID"] as? String;
            bssid = interfaceDic!["BSSID"] as? String;
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        
        navigationController?.setNavigationBarHidden(false, animated: animated);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @objc func doConfigWifi() -> Void
    {
        let ssid:String = wifiUserName.text!;
        let password:String = wifiPasswrod.text!;
        
        print(ssid, bssid, password);
        
        DispatchQueue.global().async {
            let task:ESPTouchTask = ESPTouchTask(apSsid: ssid,
                                                 andApBssid: self.bssid,
                                                 andApPwd: password);
            
            let result:ESPTouchResult = task.executeForResult();
            
            DispatchQueue.main.async {
                Toast.show(message: result.isSuc ? "配网成功" :"配网失败");
            }
        }
    }
    
}
