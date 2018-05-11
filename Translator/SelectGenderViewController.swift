//
//  SelectGenderViewController.swift
//  Translator
//
//  Created by coco on 2018/4/11.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class SelectGenderViewController: UIViewController {
    
    @IBOutlet weak var maleIconButton: UIButton!
    @IBOutlet weak var maleIconLabel: UILabel!
    @IBOutlet weak var femaleIconButton: UIButton!
    @IBOutlet weak var femaleIconLabel: UILabel!
    var isMale: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maleIconTouchAction(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default // 黑色字体状态栏
    }
    
    @IBAction func maleIconTouchAction(_ sender: Any) {
        isMale = true
        maleIconButton.setBackgroundImage(UIImage(named: "maleSelectedIcon"), for: .normal)
        maleIconLabel.textColor = UIColor(red: 75/255, green: 152/255, blue: 252/255, alpha: 1)
        femaleIconButton.setBackgroundImage(UIImage(named: "femaleUnselectedIcon"), for: .normal)
        femaleIconLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    }
    
    @IBAction func femaleIconTouchAction(_ sender: Any) {
        isMale = false
        maleIconButton.setBackgroundImage(UIImage(named: "maleUnselectedIcon"), for: .normal)
        maleIconLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        femaleIconButton.setBackgroundImage(UIImage(named: "femaleSelectedIcon"), for: .normal)
        femaleIconLabel.textColor = UIColor(red: 230/255, green: 101/255, blue: 210/255, alpha: 1)
    }
    
    @IBAction func doBackAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func commitAction(_ sender: Any) {
        if let isMale = isMale {
            AppService.getInstance().registerUser(username: AppUtil.uesrnameForRegister,
                                                  password: AppUtil.passwordForRegister,
                                                  mobile: AppUtil.uesrnameForRegister,
                                                  sex: isMale ? "M" : "F", completionHandler: completeHandler)
        } else {
            Toast.show(message: "请选择性别".localizable())
        }
    }
    
    func completeHandler(data:Data?, response:URLResponse?, error:Error?) {
        let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
        if jsonObject != nil {
            let jsonDic:[String: Any]? = jsonObject as? [String: Any]
            if jsonDic != nil {
                if (jsonDic!["resultCode"] as? String) == "0" {
                    DispatchQueue.main.async {
                        Toast.show(message: "注册成功".localizable())
                        NotificationCenter.default.post(name: Notification.Name("registerSuccess"), object: nil)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        Toast.show(message: jsonDic!["resultMsg"] as? String)
                    }
                }
            }
        }
    }
    
}
