import UIKit

class DeviceLanguageViewController: UITableViewController {
    
    var indexPathForSelectedRow: IndexPath?
    var isDeviceSourceLanguage = true // 默认是设置设备的源语言
    var deviceSourceLanguage: Language?
    var deviceTargetLanguage: Language?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceSourceLanguage = AppUtil.getLanguage(by: AppUtil.currentDevice?["languageFrom"] as? String)
        deviceTargetLanguage = AppUtil.getLanguage(by: AppUtil.currentDevice?["languageTo"] as? String)
        
        // 设置默认选中的语言索引路径
        for i in 0..<AppUtil.supportLanguages.count {
            let selectedLanguage = isDeviceSourceLanguage ? deviceSourceLanguage : deviceTargetLanguage
            if AppUtil.supportLanguages[i].name == selectedLanguage?.name {
                indexPathForSelectedRow = IndexPath(row: i, section: 0)
                break
            }
        }
        
        title = "选择语言"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(doBackAction))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUtil.supportLanguages.count
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
        cell?.textLabel?.text = AppUtil.supportLanguages[indexPath.row].name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isDeviceSourceLanguage {
            deviceSourceLanguage = AppUtil.supportLanguages[indexPath.row]
        } else {
            deviceTargetLanguage = AppUtil.supportLanguages[indexPath.row]
        }
        
        if let devNo = AppUtil.currentDevice?["deviceNo"] as? String {
            AppService.getInstance().updateDeviceSetting(devNo: devNo, lanFrom: deviceSourceLanguage?.recognitionCode, lanTo: deviceTargetLanguage?.recognitionCode) { (data, response, error) in
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
