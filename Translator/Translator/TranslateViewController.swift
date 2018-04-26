//
//  TranslateViewController.swift
//  Translator
//
//  Created by coco on 08/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslateViewController: UINavigationController
{

    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        DispatchQueue.global().async {
            SpeechToken.getInstance().getToken(); // 准备token
            SpeechSourceToTarget.getInstance().requestPermission(); // 请求权限
            SpeechTargetToSource.getInstance().requestPermission(); // 请求权限
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        popToRootViewController(animated: false);
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated);
    }

}
