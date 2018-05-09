//
//  DeviceListViewController.swift
//  Translator
//
//  Created by coco on 30/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class DeviceListViewController: UITableViewController {
    
    var deviceList: [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBindingDeviceList()
        
        navigationItem.title = "设备列表".localizable()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消".localizable(), style: .plain, target: self, action: #selector(cancelAction))
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
        return deviceList != nil ? deviceList!.count : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "itemCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "itemCell")
        }
        
        if let deviceNo = deviceList?[indexPath.row]["deviceNo"] as? String {
            cell!.textLabel?.text = "设备".localizable() + deviceNo.suffix(5)
        }
        if let deviceStatus = deviceList?[indexPath.row]["onStatus"] as? String {
            cell!.detailTextLabel?.text = deviceStatus == "00" ? "在线".localizable() : "离线".localizable()
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let device = deviceList?[indexPath.row] {
            if let currentDeviceNo = AppUtil.currentDevice?["deviceNo"] as? String {
                if let deviceNo = device["deviceNo"] as? String {
                    if currentDeviceNo != deviceNo {
                        AppUtil.currentDevice = device
                    }
                }
            } else {
                AppUtil.currentDevice = device
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    /// 获取绑定设备的列表
    func getBindingDeviceList() {
        AppService.getInstance().queryDeviceList { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) {
                if let object = jsonObject as? [String: Any] {
                    if object["resultCode"] as? String == "00" {
                        self.deviceList = object["devList"] as? [[String: Any]]
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
