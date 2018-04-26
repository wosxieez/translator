//
//  DeviceWifiListViewController.swift
//  Translator
//
//  Created by coco on 2018/4/9.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceWifiListViewController: UITableViewController {
    
    var wifiGroupData: [WifiGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "选取网络"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(doCancelAction))
        
        // 历史网络
        if var wifiHistory = UserDefaults.standard.value(forKey: "wifiHistory2") as? [[String: String]] {
            wifiHistory.reverse()
            wifiGroupData.append(WifiGroup(name: "历史网络", list: wifiHistory))
        }
        
        // 热点/连接的网络
        var hotspotWifiGroup = WifiGroup(name: "选择网络", list: [])
        if let ssid = AppUtil.getSSID() {
            hotspotWifiGroup.list.append(["ssid": ssid, "password": ""])
        }
        hotspotWifiGroup.list.append(["ssid": UIDevice.current.name, "password": ""])
        wifiGroupData.append(hotspotWifiGroup)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return wifiGroupData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiGroupData[section].list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "itemCell")
        }
        cell?.textLabel?.text = wifiGroupData[indexPath.section].list[indexPath.row]["ssid"] as? String
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return wifiGroupData[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name("wifiSelected"),
                                        object: ["ssid": wifiGroupData[indexPath.section].list[indexPath.row]["ssid"],
                                                 "password": wifiGroupData[indexPath.section].list[indexPath.row]["password"]])
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doCancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
}

struct WifiGroup {
    var name: String
    var list: [[String: String?]]
}


