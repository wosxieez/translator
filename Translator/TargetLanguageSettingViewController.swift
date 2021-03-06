//
//  TargetLanguageSettingViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TargetLanguageSettingViewController: UITableViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "languagecell2");
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppUtil.supportLanguages.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languagecell2", for: indexPath)
        cell.textLabel?.text = AppUtil.supportLanguages[indexPath.row].name
        if AppUtil.supportLanguages[indexPath.row].name == AppUtil.targetLanguage.name {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        AppUtil.targetLanguage = AppUtil.supportLanguages[indexPath.row];
        tableView.reloadData();
        
        navigationController?.popViewController(animated: true);
    }

}
