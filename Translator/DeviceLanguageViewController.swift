import UIKit

class DeviceLanguageViewController: UITableViewController {
    
    var indexPathForSelectedRow: IndexPath?
    var isDeviceSourceLanguage = true // 默认是设置设备的源语言
    var deviceSourceLanguage: DeviceLanguage?
    var deviceTargetLanguage: DeviceLanguage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceSourceLanguage = AppUtil.getDeviceLanguage(by: AppUtil.currentDevice?["languageFrom"] as? String)
        deviceTargetLanguage = AppUtil.getDeviceLanguage(by: AppUtil.currentDevice?["languageTo"] as? String)
        
        // 设置默认选中的语言索引路径
        let selectedLanguage = isDeviceSourceLanguage ? deviceSourceLanguage : deviceTargetLanguage
        for i in 0..<AppUtil.deviceLanguages.count {
            if AppUtil.deviceLanguages[i].name == selectedLanguage?.name {
                indexPathForSelectedRow = IndexPath(row: i, section: 0)
                break
            }
        }
        
        title = "选择语言".localizable()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消".localizable(), style: .plain, target: self, action: #selector(doBackAction))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUtil.deviceLanguages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "itemcell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "itemcell")
        }
        
        if let indexPathForSelectedRow = indexPathForSelectedRow {
            if indexPath.row == indexPathForSelectedRow.row &&
                indexPath.section == indexPathForSelectedRow.section {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        } else {
            cell?.accessoryType = .none
        }
        
        cell?.selectionStyle = .none
        cell?.textLabel?.text = AppUtil.deviceLanguages[indexPath.row].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDeviceSourceLanguage {
            deviceSourceLanguage = AppUtil.deviceLanguages[indexPath.row]
        } else {
            deviceTargetLanguage = AppUtil.deviceLanguages[indexPath.row]
        }
        
        if let devNo = AppUtil.currentDevice?["deviceNo"] as? String {
            AppService.getInstance().updateDeviceSetting(devNo: devNo, lanFrom: deviceSourceLanguage?.code, lanTo: deviceTargetLanguage?.code) { (data, response, error) in
                guard data != nil && error == nil else { return }
                
                if let result = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                    if result["resultCode"] as? String == "0" {
                        NotificationCenter.default.post(name: AppNotification.NeedUpdateDeviceInfo, object: nil)
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doBackAction() {
        dismiss(animated: true, completion: nil)
    }
    
}
