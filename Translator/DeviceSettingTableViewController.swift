//
//  DeviceSettingTableViewController.swift
//  Translator
//
//  Created by coco on 21/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceSettingTableViewController: UITableViewController {
    
    var contentFlag = 0
    
    let data0 = [["name": "10" + "分钟".localizable(), "icon": "deviceShutdownIcon10"],
                 ["name": "20" + "分钟".localizable(), "icon": "deviceShutdownIcon20"],
                 ["name": "30" + "分钟".localizable(), "icon": "deviceShutdownIcon30"]]
    
    let data1 = [["name": "5" + "分钟".localizable(), "icon": "deviceSleepIcon5"],
                 ["name": "10" + "分钟".localizable(), "icon": "deviceSleepIcon10"],
                 ["name": "15" + "分钟".localizable(), "icon": "deviceSleepIcon15"]]
    
    let data2 = [["name": "10" + "秒".localizable(), "icon": "deviceRecordIcon5"],
                 ["name": "15" + "秒".localizable(), "icon": "deviceRecordIcon10"],
                 ["name": "30" + "秒".localizable(), "icon": "deviceRecordIcon15"]]
    
    var contentData: [[String: String]] {
        get {
            switch contentFlag {
            case 1:
                return data1
            case 2:
                return data2
            default:
                return data0
            }
        }
    }
    
    var contentTitle: String {
        get {
            switch contentFlag {
            case 1:
                return "待机时间".localizable()
            case 2:
                return "录音时长".localizable()
            default:
                return "关机时间".localizable()
            }
        }
    }
    
    init(flat: Int) {
        super.init(nibName: nil, bundle: nil)
        self.contentFlag = flat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = contentTitle
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = AppUtil.themeColor
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "itemCell")
        }
        
        cell?.textLabel?.text = contentData[indexPath.row]["name"]
        cell?.imageView?.image = UIImage(named: contentData[indexPath.row]["icon"]!)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var deviceContent: [String: Any] = [:]
        var deviceMessage: [String: Any] = [:]
        deviceMessage["source"] = AppUtil.username
        deviceMessage["target"] = AppUtil.currentDevice?["deviceNo"]
        
        switch contentFlag {
        case 1: // 待机
            deviceMessage["type"] = "setDeviceTime"
            switch indexPath.row {
            case 0:
                deviceContent["standbytime"] = "5"
            case 1:
                deviceContent["standbytime"] = "10"
            default:
                deviceContent["standbytime"] = "15"
            }
        case 2: // 录音
            deviceMessage["type"] = "setSpeakTime"
            switch indexPath.row {
            case 0:
                deviceContent["time"] = "10"
            case 1:
                deviceContent["time"] = "15"
            default:
                deviceContent["time"] = "30"
            }
        default: // 关机时间
            deviceMessage["type"] = "setDeviceTime"
            switch indexPath.row {
            case 0:
                deviceContent["shutdowntime"] = "10"
            case 1:
                deviceContent["shutdowntime"] = "20"
            default:
                deviceContent["shutdowntime"] = "30"
            }
        }
        
        deviceMessage["content"] = deviceContent
        
        let message = Message()
        message.type = "appTransmit"
        message.content = deviceMessage
        NotificationCenter.default.post(name: AppNotification.SendMessage, object: message)
        navigationController?.popViewController(animated: true)
    }
    
}
