//
//  UserSettingTableViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork;

class UserSettingTableViewController: UITableViewController
{
    
    let userData = [["name":"密码修改", "icon":"changePasswordIcon"],
                    ["name":"开始配网", "icon":"deveiceIcon"],
                    ["name":"绑定设备", "icon":"connectIcon"]];
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // TableView 注册细胞类
        let cellNib = UINib(nibName: "DeviceTableViewCell", bundle: nil);
        tableView.register(cellNib, forCellReuseIdentifier: "cusCell");
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier");
        tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0);
        
        // 创建一个UIView放到顶部
        let topView = UIView(frame: CGRect(x: 0, y: -270, width: tableView.bounds.width, height: 270));
        topView.backgroundColor = UIColor(red: 58/255, green: 187/255, blue: 255/255, alpha: 1);
        topView.tag = 100;
        tableView.addSubview(topView);
        
        let userIconView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        userIconView.image = UIImage(named:"userImage");
        userIconView.center = CGPoint(x: topView.bounds.width/2, y: topView.bounds.height/2);
        userIconView.tag = 101;
        topView.addSubview(userIconView);
        
        let info:[String: Any]? = Bundle.main.infoDictionary;
        let appVersion:Any? = info?["CFBundleShortVersionString"];
        let versionLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30));
        versionLabel.textAlignment = NSTextAlignment.center;
        versionLabel.textColor = UIColor.white;
        versionLabel.center = CGPoint(x: topView.bounds.width/2, y: topView.bounds.height/2 + 65);
        versionLabel.text = appVersion as? String;
        topView.addSubview(versionLabel);
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        
        navigationController?.setNavigationBarHidden(true, animated: animated);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return userData.count + 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 3)
        {
            let cusCell = tableView.dequeueReusableCell(withIdentifier: "cusCell", for: indexPath);
            return cusCell;
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath);
            cell.textLabel?.text = userData[indexPath.section]["name"];
            cell.imageView?.image = UIImage(named: userData[indexPath.section]["icon"]!);
            
            if (indexPath.section == 1 || indexPath.section == 2)
            {
                cell.accessoryType = .none;
            }
            else
            {
                cell.accessoryType = .disclosureIndicator;
            }
            
            cell.selectionStyle = .none;
            return cell;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 3)
        {
            return 30;
        }
        else
        {
            return 10;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1;
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView.contentOffset.y < -270)
        {
            var rect = tableView.viewWithTag(100)!.frame;
            rect.origin.y = scrollView.contentOffset.y;
            rect.size.height = -scrollView.contentOffset.y;
            tableView.viewWithTag(100)!.frame = rect;
        }
    }
    
    var changePasswordController:UIViewController!;
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section {
        case 0:
            changePasswordController = storyboard?.instantiateViewController(withIdentifier: "changePasswordController");
            show(changePasswordController!, sender: nil);
        case 1:
            break;
//            getWifiSSID();
//            let configWifiController:ConfigWIFIViewController = ConfigWIFIViewController();
//            show(configWifiController, sender: nil);
        case 2:
            break;
//            let deviceController:DeviceViewController = DeviceViewController();
//            show(deviceController, sender: nil);
        case 3:
//            let message:Message = Message();
//            message.type = "appLogout";
//            message.content = "appLogout";
            NotificationCenter.default.post(name: Notification.Name.init("appLogout"), object: nil);
        default:
            DispatchQueue.main.async {
                 Toast.show(message: "功能开发中");
            }
        }
    }
    
    func getWifiSSID() -> Void
    {
        let interfaces:CFArray! = CNCopySupportedInterfaces();
        let interfacesArray:[AnyObject] = CFBridgingRetain(interfaces) as! [AnyObject];
        let interfaceName:CFString = interfacesArray[0] as! CFString;
        let interfaceData:CFDictionary! = CNCopyCurrentNetworkInfo(interfaceName);
        let interfaceDic:[String: Any] = interfaceData as! [String: Any];
        
        let espTouchTask:ESPTouchTask = ESPTouchTask(apSsid: interfaceDic["SSID"] as! String,
                                                     andApBssid: interfaceDic["BSSID"] as! String,
                                                     andApPwd: "tangdi901@");
        let result:[Any]! = espTouchTask.execute(forResults: 1);
        print("接受到结果", result);
    }
    
}
