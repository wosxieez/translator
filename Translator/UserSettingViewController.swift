//
//  UserSettingTableViewController.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class UserSettingViewController: UITableViewController {
    
    @IBOutlet weak var sexViewCell: UITableViewCell!
    var tableHeaderImageView: UIImageView!
    var tableHeaderIconImageView: UIImageView!
    var usernameLabel: UILabel!
    var isTimerRunning = false
    var headImageTapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tableHeaderImage = UIImage(named: "userSettingTopBg") {
            let tableHeaderView = UIView()
            tableHeaderView.frame.size.width = view.frame.width
            tableHeaderView.frame.size.height = view.frame.width * tableHeaderImage.size.height / tableHeaderImage.size.width
            tableView.tableHeaderView = tableHeaderView
            
            tableHeaderImageView = UIImageView(image: tableHeaderImage)
            tableHeaderImageView.frame = tableHeaderView.bounds
            tableHeaderImageView.frame.origin = CGPoint(x: 0, y: 0)
            tableHeaderImageView.isUserInteractionEnabled = true
            tableHeaderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headImageTapAction)))
            tableHeaderView.addSubview(tableHeaderImageView)
            
            tableHeaderIconImageView = UIImageView(image: UIImage(named: AppUtil.sex == "F" ? "userSettingFemaleIcon" : "userSettingMaleIcon"))
            tableHeaderIconImageView.center = tableHeaderImageView.center
            tableHeaderView.addSubview(tableHeaderIconImageView)
            
            usernameLabel = UILabel()
            usernameLabel.textColor = UIColor.white
            usernameLabel.font = UIFont.systemFont(ofSize: 20)
            usernameLabel.text = AppUtil.username
            usernameLabel.sizeToFit()
            usernameLabel.center.x = tableHeaderImageView.center.x
            usernameLabel.center.y = tableHeaderImageView.center.y + 70
            tableHeaderView.addSubview(usernameLabel)
        }
        
        if AppUtil.sex == "F" {
            sexViewCell.detailTextLabel?.text = "女"
        } else {
            sexViewCell.detailTextLabel?.text = "男"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            NotificationCenter.default.post(name: AppNotification.AppLoout, object: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            var newFrame = tableHeaderImageView.frame
            newFrame.origin.y = scrollView.contentOffset.y
            newFrame.size.height = tableView.tableHeaderView!.frame.size.height - scrollView.contentOffset.y
            tableHeaderImageView.frame = newFrame
        }
    }
    
    func openPickerView() {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func headImageTapAction() {
        if isTimerRunning {
            headImageTapCount += 1
            
            if headImageTapCount >= 6 {
                NotificationCenter.default.post(name: Notification.Name("showTranslateViewController"), object: nil)
            }
        } else {
            isTimerRunning = true
            headImageTapCount = 1
            perform(#selector(onTimerAction), with: nil, afterDelay: 2)
        }
    }
    
    @objc func onTimerAction() {
        isTimerRunning = false
    }
    
}
