//
//  SourceLanguageSettingViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class SourceLanguageSettingViewController: UITableViewController
{
    
    let languages = [Language(name:"中文", code:"zh-CN", speechCode: "zh"),
                     Language(name:"中文-台湾", code:"zh-TW", speechCode: "zh"),
                     Language(name:"阿拉伯语", code:"ar-EG", speechCode: "ara"),
                     Language(name:"德语", code:"de-DE", speechCode: "de"),
                     Language(name:"英语", code:"en-US", speechCode: "en"),
                     Language(name:"西班牙语", code:"es-ES", speechCode: "spa"),
                     Language(name:"法语", code:"fr-FR", speechCode: "fra"),
                     Language(name:"意大利语", code:"it-IT", speechCode: "it"),
                     Language(name:"日语", code:"ja-JP", speechCode: "jp"),
                     Language(name:"葡萄牙语", code:"pt-BR", speechCode: "pt"),
                     Language(name:"俄语", code:"ru-RU", speechCode: "ru")];
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "languagecell");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languagecell", for: indexPath)
        cell.textLabel?.text = languages[indexPath.row].name;
        if (languages[indexPath.row].code == AppUtil.sourceLanguage.code)
        {
            cell.accessoryType = .checkmark;
        }
        else
        {
            cell.accessoryType = .none;
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        AppUtil.sourceLanguage = languages[indexPath.row];
        tableView.reloadData();
        
        navigationController?.popViewController(animated: true);
    }
    
}
