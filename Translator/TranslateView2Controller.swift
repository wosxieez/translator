//
//  TranslateView2Controller.swift
//  Translator
//
//  Created by coco on 16/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import AVFoundation

class TranslateView2Controller: UIViewController {
    
    var allResults:[[String: Any]] = []
    var toast:Toast?
    var isBleDown:Bool = false
    var isRecording:Bool = false
    var isHasMicrophonePermission: Bool = false
    var translate1ViewController: TranslateView1Controller?
    var translate3ViewController: TranslateView3Controller?
    var translate4ViewController: TranslateView4Controller?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(startTranslate),
                                               name: Notification.Name("startTranslate"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(endTranslate),
                                               name: Notification.Name("endTranslate"), object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged),
                                               name: Notification.Name("languageChanged"), object: nil);
        
        startButton.layer.cornerRadius = 5
        startButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        startButton2.layer.cornerRadius = 5
        startButton2.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    @objc func startTranslate() -> Void {
        DispatchQueue.main.async {
            self.startRecognition()
        }
    }
    
    @objc func endTranslate() -> Void {
        DispatchQueue.main.async {
            self.stopRecognition()
        }
    }

    @objc func languageChanged() -> Void {
        startButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        startButton2.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    @IBAction func startRecognition() -> Void {
        isRecording = false
        AVAudioSession.sharedInstance().requestRecordPermission { (permission: Bool) in
            // 如果不是主线程，说明有弹框请求权限，这时候不做任何处理
            guard Thread.isMainThread else { return }
            
            if permission {
                self.toast?.open(message: "正在识别...上滑取消", delayCloseTime: -1)
                self.isRecording = true // 正在录音
                DispatchQueue.global().async {
                    SpeechSourceToTarget.getInstance().start(callback: self.recognitionResult)
                }
            } else {
                let noPremissionAlert = UIAlertController(title: "无法识别",
                                                          message: "请在iPhone的\"设置-隐私-麦克风\"选项中，允许百国译访问到您的麦克风",
                                                          preferredStyle: UIAlertControllerStyle.alert)
                noPremissionAlert.addAction(UIAlertAction(title: "确定",
                                                          style: UIAlertActionStyle.default,
                                                          handler: nil))
                self.present(noPremissionAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func stopRecognition() {
        DispatchQueue.global().async {
            if self.isRecording {
                // 松开按钮的时候，如果是录音状态，则进行识别
                SpeechSourceToTarget.getInstance().stopAndRecognition()
            }
            else {
                SpeechSourceToTarget.getInstance().stop()
            }
            self.isRecording = false
        }
        toast?.close()
    }
    
    @IBAction func startRecognition2() -> Void {
        isRecording = false
        AVAudioSession.sharedInstance().requestRecordPermission { (permission: Bool) in
            // 如果不是主线程，说明有弹框请求权限，这时候不做任何处理
            guard Thread.isMainThread else { return }
            
            if permission {
                self.toast?.open(message: "正在识别...上滑取消", delayCloseTime: -1)
                self.isRecording = true // 正在录音
                DispatchQueue.global().async {
                    SpeechTargetToSource.getInstance().start(callback: self.recognitionResult2)
                }
            } else {
                let noPremissionAlert = UIAlertController(title: "无法识别", message: "请在iPhone的\"设置-隐私-麦克风\"选项中，允许百国译访问到您的麦克风", preferredStyle: UIAlertControllerStyle.alert)
                noPremissionAlert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
                self.present(noPremissionAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func stopRecognition2() -> Void {
        DispatchQueue.global().async {
            if self.isRecording {
                // 松开按钮的时候，如果是录音状态，则进行识别
                SpeechTargetToSource.getInstance().stopAndRecognition()
            }
            else {
                SpeechTargetToSource.getInstance().stop()
            }
            self.isRecording = false
        }
        
        toast?.close()
    }
    
    @IBAction func touchDragExit() {
        isRecording = false
    }
    
    @IBAction func touchDragEnter() {
        isRecording = true
    }
    
    func recognitionResult(recognition:String, translation:String) -> Void {
        if (recognition != "无法识别") {
            AppUtil.speech(q: translation, language: AppUtil.targetLanguage.ttsCode);
            allResults.append(["source": recognition, "target": translation, "isRight": false, "language": AppUtil.targetLanguage.ttsCode!, "title" : String(AppUtil.sourceLanguage.name.prefix(1))]);
            
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
            AppUtil.speech(q: translation, language: AppUtil.sourceLanguage.ttsCode);
            allResults.append(["source": recognition, "target": translation, "isRight": true, "language": AppUtil.sourceLanguage.ttsCode!, "title" : String(AppUtil.targetLanguage.name.prefix(1))]);
            
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
    
    @IBAction func goToTranslate2() {
        if (translate1ViewController == nil) {
            translate1ViewController = storyboard?.instantiateViewController(withIdentifier: "translate1ViewController")
                as? TranslateView1Controller;
        }
        show(translate1ViewController!, sender: nil);
    }
    
    @IBAction func goToTranslate3() {
        if (translate3ViewController == nil) {
            translate3ViewController = storyboard?.instantiateViewController(withIdentifier: "translate3ViewController")
                as? TranslateView3Controller;
        }
        show(translate3ViewController!, sender: nil);
    }
    
    @IBAction func goToTranslate4() {
        if translate4ViewController == nil {
            translate4ViewController = TranslateView4Controller()
        }
        show(translate4ViewController!, sender: nil)
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

