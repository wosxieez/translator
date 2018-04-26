//
//  TranslateViewController.swift
//  流翻译视图管理器
//
//  Created by coco on 21/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslateView4Controller: UIViewController {
    
    var sourceButton: UIButton!
    var targetButton: UIButton!
    var switchButton: UIButton!
    var sourceTextView: UITextView!
    var startButton: UIButton!
    var targetTextView: UITextView!
    var clearButton: UIButton!
    var sourceSpeakButton: UIButton!
    var targetSpeakButton: UIButton!
    var lineView: UIView!
    
    let speechRecognition = SpeechRecognition()
    var finalText = ""
    var finalTargetText = ""
    var partialText = ""
    var partialTargetText = ""
    var toast = Toast()
    var isListening: Bool = false
    var animationLayer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "实时翻译"
        view.backgroundColor = UIColor.white
        speechRecognition.delegate = self
        
        // 中文 -> English
        sourceButton = UIButton()
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        sourceButton.backgroundColor = AppUtil.themeColor
        sourceButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        sourceButton.addTarget(self, action: #selector(selectSourceLanguage), for: .touchUpInside)
        view.addSubview(sourceButton)
        
        targetButton = UIButton()
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
        targetButton.backgroundColor = AppUtil.themeColor
        targetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        targetButton.addTarget(self, action: #selector(selectTargetLanguage), for: .touchUpInside)
        view.addSubview(targetButton)
        
        switchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        switchButton.setImage(UIImage.init(named: "changeIcon"), for: .normal)
        switchButton.backgroundColor = AppUtil.themeColor
        switchButton.addTarget(self, action: #selector(switchLanguageAction), for: .touchUpInside)
        view.addSubview(switchButton)
        
        // add source textview
        sourceTextView = UITextView()
        sourceTextView.isEditable = false
        sourceTextView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(sourceTextView)
        
        // add target textview
        targetTextView = UITextView()
        targetTextView.isEditable = false
        targetTextView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(targetTextView)
        
        // startButton
        startButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        startButton.setTitle("开始", for: UIControlState.normal)
        startButton.backgroundColor = AppUtil.themeColor
        startButton.layer.cornerRadius = 35
        startButton.addTarget(self, action: #selector(start), for: UIControlEvents.touchDown)
        view.addSubview(startButton)
        
        clearButton = UIButton()
        clearButton.isHidden = true
        clearButton.setImage(UIImage(named: "clearIcon"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        view.addSubview(clearButton)
        
        sourceSpeakButton = UIButton()
        sourceSpeakButton.isHidden = true
        sourceSpeakButton.setImage(UIImage(named: "micIcon"), for: .normal)
        sourceSpeakButton.addTarget(self, action: #selector(speakSourceText), for: .touchUpInside)
        view.addSubview(sourceSpeakButton)
        
        targetSpeakButton = UIButton()
        targetSpeakButton.isHidden = true
        targetSpeakButton.setImage(UIImage(named: "micIcon"), for: .normal)
        targetSpeakButton.addTarget(self, action: #selector(speakTargetText), for: .touchUpInside)
        view.addSubview(targetSpeakButton)
        
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0.5))
        lineView.backgroundColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1)
        lineView.isHidden = true
        view.addSubview(lineView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        sourceButton.frame.size.width = view.frame.width / 2
        sourceButton.frame.size.height = 60
        
        targetButton.frame.origin.x = sourceButton.frame.maxX
        targetButton.frame.size.width = sourceButton.frame.width
        targetButton.frame.size.height = sourceButton.frame.height
        
        switchButton.center.x = view.frame.width / 2
        switchButton.center.y = 30
        
        sourceTextView.frame.origin.y = 60
        sourceTextView.frame.size.width = view.frame.width - 40
        sourceTextView.frame.size.height = (view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length - 130) / 2
        
        clearButton.frame.size.width = 30
        clearButton.frame.size.height = 30
        clearButton.frame.origin.y = sourceTextView.frame.origin.y + 5
        clearButton.frame.origin.x = sourceTextView.frame.maxX + 5
        
        sourceSpeakButton.frame.size.width = 30
        sourceSpeakButton.frame.size.height = 30
        sourceSpeakButton.frame.origin.x = clearButton.frame.origin.x
        sourceSpeakButton.frame.origin.y = clearButton.frame.maxY + 5
        
        targetTextView.frame.origin.y = sourceTextView.frame.maxY
        targetTextView.frame.size.width = sourceTextView.frame.width
        targetTextView.frame.size.height = sourceTextView.frame.height
        
        targetSpeakButton.frame.size.width = 30
        targetSpeakButton.frame.size.height = 30
        targetSpeakButton.frame.origin.y = targetTextView.frame.origin.y + 5
        targetSpeakButton.frame.origin.x = targetTextView.frame.maxX + 5
        
        startButton.center = CGPoint(x: view.frame.width / 2, y: view.frame.height - 45 - bottomLayoutGuide.length)
        
        lineView.frame.size.width = view.frame.width
        lineView.frame.origin.y = sourceTextView.frame.maxY
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isListening {
            speechRecognition.stop()
            startButton.setTitle("开始", for: .normal)
            removeAnimationFromStartButton()
            isListening = false
        }
    }
    
    @objc func start() {
        if isListening {
            speechRecognition.stop()
            startButton.setTitle("开始", for: .normal)
            removeAnimationFromStartButton()
            isListening = false
        } else {
            guard AppUtil.sourceLanguage.streamCode != nil && AppUtil.targetLanguage.streamCode != nil else {
                let ac = UIAlertController(title: "提示", message: "暂不支持该语言识别", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                present(ac, animated: false, completion: nil)
                return
            }
            
            startButton.setTitle("停止", for: .normal)
            addAnimationToStartButton()
            speechRecognition.start()
            isListening = true
            finalText = ""
            finalTargetText = ""
            partialText = ""
            partialTargetText = ""
            sourceTextView.text = ""
            targetTextView.text = ""
            clearButton.isHidden = true
            sourceSpeakButton.isHidden = true
            targetSpeakButton.isHidden = true
            lineView.isHidden = true
        }
    }
    
    /// 给开始按钮添加动画效果
    func addAnimationToStartButton() {
        animationLayer = CALayer()
        animationLayer!.frame = startButton.layer.frame
        animationLayer!.cornerRadius = startButton.layer.cornerRadius
        animationLayer!.backgroundColor = AppUtil.themeColor.cgColor
        view.layer.insertSublayer(animationLayer!, below: startButton.layer)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 2
        scaleAnimation.duration = 1.5
        scaleAnimation.repeatCount = Float.greatestFiniteMagnitude
        animationLayer!.add(scaleAnimation, forKey: scaleAnimation.keyPath)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.8, 0.4, 0]
        opacityAnimation.keyTimes = [0, 0.5, 1]
        opacityAnimation.duration = 1.5
        opacityAnimation.repeatCount = Float.greatestFiniteMagnitude
        animationLayer!.add(opacityAnimation, forKey: opacityAnimation.keyPath)
    }
    
    /// 从开始按钮移除动画效果
    func removeAnimationFromStartButton() {
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }
    
    @objc func selectSourceLanguage() {
        show(SourceLanguageSettingViewController(), sender: nil)
    }
    
    @objc func selectTargetLanguage() {
        show(TargetLanguageSettingViewController(), sender: nil)
    }
    
    @objc func clearText() {
        finalText = ""
        finalTargetText = ""
        partialText = ""
        partialTargetText = ""
        sourceTextView.text = ""
        targetTextView.text = ""
        clearButton.isHidden = true
        sourceSpeakButton.isHidden = true
        targetSpeakButton.isHidden = true
        lineView.isHidden = true
    }
    
    @objc func speakSourceText() {
        AppUtil.speech(q: sourceTextView.text, language: AppUtil.sourceLanguage.ttsCode)
    }
    
    @objc func speakTargetText() {
         AppUtil.speech(q: targetTextView.text, language: AppUtil.targetLanguage.ttsCode)
    }
    
    @objc func switchLanguageAction() {
        let language = AppUtil.sourceLanguage;
        AppUtil.sourceLanguage = AppUtil.targetLanguage;
        AppUtil.targetLanguage = language;
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
}


extension TranslateView4Controller: SpeechRecognitionDelegate {
    
    func didConnect() {
    }
    
    func receive(message: String) {
        let messageDic = (try? JSONSerialization.jsonObject(with: message.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any]
        if let type = messageDic?["type"] {
            if (type as? String) == "final" {
                partialText = ""
                partialTargetText = ""
                finalText = finalText + (messageDic!["recognition"] as! String)
                finalTargetText = finalTargetText + (messageDic!["translation"] as! String)
            } else {
                partialText = messageDic!["recognition"] as! String
                partialTargetText = messageDic!["translation"] as! String
            }
            sourceTextView.text = finalText + partialText
            targetTextView.text = finalTargetText + partialTargetText
            clearButton.isHidden = false
            sourceSpeakButton.isHidden = false
            targetSpeakButton.isHidden = false
            lineView.isHidden = false
        }
    }
    
    func didDisConnect() {
    }
    
}

