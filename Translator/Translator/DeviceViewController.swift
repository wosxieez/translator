//
//  DeviceViewController.swift
//  TangdiTranslator
//
//  Created by coco on 27/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import CoreBluetooth;

class DeviceViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    let data:Array = [["name":"打开蓝牙", "icon":"wifiIcon"],
                      ["name":"打开定位", "icon":"wifiIcon"]];
    
    var manager:CBCentralManager!;
    var device:CBPeripheral!;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // 注册细胞类，得告诉他用哪个细胞类来展示
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "deviceCell");
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
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return data.count;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath);
        cell.textLabel?.text = data[indexPath.section]["name"];
        cell.imageView?.image = UIImage(named: data[indexPath.section]["icon"]!);
        cell.accessoryType = .disclosureIndicator;
        cell.selectionStyle = .none;
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10.0;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section
        {
        case 0:
            manager = CBCentralManager(delegate: self, queue: DispatchQueue.global());
        case 1:
            let backButtonItem:UIBarButtonItem = UIBarButtonItem();
            backButtonItem.title = "返回";
            navigationItem.backBarButtonItem = backButtonItem;
            
            let locationViewController:LocationViewController = LocationViewController();
            show(locationViewController, sender: nil);
        default:
            print("no");
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch central.state
        {
        case CBManagerState.poweredOff:
            // 发现蓝牙关闭状态 跳转到系统蓝牙界面
            DispatchQueue.main.async {
                UIApplication.shared.open(URL(string: "App-Prefs:root=Bluetooth")!);
            }
        case  CBManagerState.poweredOn:
            print("蓝牙打开, 开始扫描熊美丽");
            manager.scanForPeripherals(withServices: nil, options: nil);
        case CBManagerState.unsupported:
            print("不支持的");
        default:
            print("未知状态");
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        print(peripheral.name as Any);
        if (peripheral.name == "EQ_Test")
        {
            print("发现EQ-TEST...");
            device = peripheral;
            peripheral.delegate = self;
            manager.stopScan(); // 停止扫描
            print("开始连接EQ-TEST...");
            manager.connect(device, options: nil);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        print("连接上EQ-TEST...查找服务");
        
        peripheral.delegate = self;
        peripheral.discoverServices(nil);
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        print("发现服务...查找特征");
        for service in peripheral.services!
        {
            // 寻找服务的特征
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        // 发现了服务的特征
        for characteristic in service.characteristics!
        {
            print("服务UUID:\(service.uuid)         特征UUID:\(characteristic.uuid)");
            if characteristic.properties.contains(CBCharacteristicProperties.read)
            {
                print("可读取");
            }
            if characteristic.properties.contains(CBCharacteristicProperties.notify)
            {
                print("可通知");
                
                peripheral.setNotifyValue(true, for: characteristic);
            }
            if characteristic.properties.contains(CBCharacteristicProperties.write)
            {
                print("可写入");
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        let bytes:[UInt8] = [UInt8](characteristic.value!);
        
        if (bytes[1] == 1)
        {
            print("开始翻译");
            NotificationCenter.default.post(name: Notification.Name.init("startTranslate"), object: nil);
        }
        else
        {
            print("停止翻译");
            NotificationCenter.default.post(name: Notification.Name.init("endTranslate"), object: nil);
        }
        
    }
    
}
