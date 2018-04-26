//
//  SettingTableViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    let settingData = ["源语言", "目标语言"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingcell");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settingData.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "settingcell", for: indexPath);
        cell.textLabel?.text = settingData[indexPath.row];
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (indexPath.row == 0)
        {
            navigationController?.pushViewController((storyboard?.instantiateViewController(withIdentifier: "sourceLanguageSettingViewController"))!,
                                                     animated: true);
            
        }
        else
        {
            // 设置目录语言
            navigationController?.pushViewController((storyboard?.instantiateViewController(withIdentifier: "targetLanguageSettingViewController"))!,
                                                     animated: true);
        }
    }
    
    
}
