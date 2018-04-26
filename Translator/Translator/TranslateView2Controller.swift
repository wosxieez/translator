//
//  TranslateView2Controller.swift
//  Translator
//
//  Created by coco on 16/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import AVFoundation;
import CoreBluetooth;

class TranslateView2Controller: UIViewController {
    
    var allResults:[[String: Any]] = []
    var manager:CBCentralManager!
    var device:CBPeripheral!
    var toast:Toast?
    var isBleDown:Bool = false
    var isCanceled:Bool = false
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButton2: UIButton!
    @IBOutlet weak var sourceButton:UIButton!
    @IBOutlet weak var targetButton:UIButton!
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toast = Toast(frame: CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.width * 3 / 4, height: 70))
        
        let nib:UINib = UINib(nibName: "TranslateTableViewCell", bundle: nil)
        let nib2:UINib = UINib(nibName: "TranslteTableViewCell2", bundle: nil)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.register(nib2, forCellReuseIdentifier: "cell2")
        
        NotificationCenter.default.addObserver(self, selector: #selector(startTranslate), name: Notification.Name("startTranslate"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(endTranslate), name: Notification.Name("endTranslate"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: Notification.Name("languageChanged"), object: nil);
        
        startButton.layer.cornerRadius = 5
        startButton2.layer.cornerRadius = 5
        startButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        startButton2.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
        navigationController?.navigationBar.shadowImage = UIImage();
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
    @objc func openBle() -> Void {
        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global());
    }
    
    @objc func startTranslate() -> Void {
        DispatchQueue.main.async {
            self.startRecognition();
        }
    }
    
    @objc func endTranslate() -> Void {
        DispatchQueue.main.async {
            self.stopRecognition();
        }
    }
    
    @objc func languageChanged() -> Void {
        startButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        startButton2.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
    @IBAction func startRecognition() -> Void {
        isCanceled = false
        toast?.open(message: "正在识别...上滑取消", delayCloseTime: -1);
        DispatchQueue.global().async {
            SpeechSourceToTarget.getInstance().start(callback: self.recognitionResult);
        }
    }
    
    @IBAction func stopRecognition() -> Void {
        toast?.close()
        DispatchQueue.global().async {
            if self.isCanceled { SpeechSourceToTarget.getInstance().reset() }
            else { SpeechSourceToTarget.getInstance().stop() }
        }
    }
    
    @IBAction func startRecognition2() -> Void {
        isCanceled = false
        toast?.open(message: "正在识别...上滑取消", delayCloseTime: -1);
        DispatchQueue.global().async {
            SpeechTargetToSource.getInstance().start(callback: self.recognitionResult2);
        }
    }
    
    @IBAction func stopRecognition2() -> Void {
        toast?.close()
        DispatchQueue.global().async {
            if self.isCanceled { SpeechTargetToSource.getInstance().reset() }
            else { SpeechTargetToSource.getInstance().stop() }
        }
    }
    
    @IBAction func touchDragExit() {
        print("exit")
        isCanceled = true
    }
    
    @IBAction func touchDragEnter() {
        print("enter")
        isCanceled = false
    }
    
    func recognitionResult(recognition:String, translation:String) -> Void {
        if (recognition != "无法识别") {
            AppUtil.speech(q: translation, language: AppUtil.targetLanguage.code);
            allResults.append(["source": recognition, "target": translation, "isRight": false, "language": AppUtil.targetLanguage.code, "title" : String(AppUtil.sourceLanguage.name.prefix(1))]);
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
                self.tableView.scrollToRow(at: IndexPath.init(row: self.allResults.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true);
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(message: "无法识别");
            }
        }
    }
    
    func recognitionResult2(recognition:String, translation:String) -> Void {
        if (recognition != "无法识别")
        {
            AppUtil.speech(q: translation, language: AppUtil.sourceLanguage.code);
            allResults.append(["source": recognition, "target": translation, "isRight": true, "language": AppUtil.sourceLanguage.code, "title" : String(AppUtil.targetLanguage.name.prefix(1))]);
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath.init(row: self.allResults.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true);
            }
        } else {
            DispatchQueue.main.async {
                Toast.show(message: "无法识别")
            }
        }
    }
    
    @IBAction func switchButton() -> Void {
        let language = AppUtil.sourceLanguage
        AppUtil.sourceLanguage = AppUtil.targetLanguage
        AppUtil.targetLanguage = language
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
}


// MARK: - 实现UITableView数据源协议
extension TranslateView2Controller: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allResults.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!;
        let sourceString = allResults[indexPath.row]["source"]! as? String;
        let targetString = allResults[indexPath.row]["target"]! as? String;
        let titleString = allResults[indexPath.row]["title"]! as? String;
        let languageString = allResults[indexPath.row]["language"] as! String
        if (allResults[indexPath.row]["isRight"]! as! Bool) {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath);
            (cell as! TranslteTableViewCell2).sourceDisplay.text = sourceString;
            (cell as! TranslteTableViewCell2).targetDisplay.text = targetString;
            (cell as! TranslteTableViewCell2).iconLabel.text = titleString;
            (cell as! TranslteTableViewCell2).language = languageString
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath);
            (cell as! TranslateTableViewCell).sourceDisplay.text = sourceString;
            (cell as! TranslateTableViewCell).targetDisplay.text = targetString;
            (cell as! TranslateTableViewCell).iconLabel.text = titleString;
            (cell as! TranslateTableViewCell).language = languageString
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        return cell;
    }
    
}


// MARK: - 实现蓝牙管理器代理协议
extension TranslateView2Controller: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (peripheral.name == "EQ_Test") {
            device = peripheral;
            peripheral.delegate = self;
            manager.stopScan(); // 停止扫描
            manager.connect(device, options: nil);
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            Toast.show(message: "蓝牙连接成功");
        }
        peripheral.delegate = self;
        peripheral.discoverServices(nil);
    }
    
}


// MARK: - 实现蓝牙设备代理协议
extension TranslateView2Controller: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 发现了服务的特征
        for characteristic in service.characteristics! {
            if characteristic.properties.contains(CBCharacteristicProperties.read) { print("可读取") }
            if characteristic.properties.contains(CBCharacteristicProperties.notify) {
                print("可通知");
                peripheral.setNotifyValue(true, for: characteristic);
            }
            if characteristic.properties.contains(CBCharacteristicProperties.write) { print("可写入") }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let bytes:[UInt8] = [UInt8](characteristic.value!);
        if (bytes.count == 4) {
            if (bytes[1] == 1) {
                if (isBleDown) { return }
                isBleDown = true;
                NotificationCenter.default.post(name: Notification.Name.init("startTranslate"), object: nil);
            }  else if (bytes[1] == 3) {
                if (!isBleDown)  { return }
                isBleDown = false;
                NotificationCenter.default.post(name: Notification.Name.init("endTranslate"), object: nil);
            }
        }
    }
}

