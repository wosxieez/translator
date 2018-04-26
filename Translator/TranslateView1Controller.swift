//
//  TranslateView1Controller.swift
//  Translator
//
//  Created by coco on 26/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class TranslateView1Controller: UIViewController {
    
    @IBOutlet weak var sourceButton:UIButton!
    @IBOutlet weak var targetButton:UIButton!
    @IBOutlet weak var sourceTextView:UITextView!
    @IBOutlet weak var targetTextView:UITextView!
    
    var lineView: UIView!
    var isTranslateResult = false
    var translateResult = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sourceTextView.delegate = self
        lineView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 0.5))
        lineView.backgroundColor = UIColor(red: 179/255, green: 179/255, blue: 179/255, alpha: 1)
        lineView.isHidden = true
        view.addSubview(lineView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        lineView.frame.size.width = view.frame.width
        lineView.frame.origin.y = 160
    }
    
    func translateCompletion(data:Data?) {
        if data != nil {
            translateResult = ""
            let xmlParser = XMLParser(data: data!)
            xmlParser.delegate = self
            xmlParser.parse()
        } else {
            DispatchQueue.main.async {
                 self.targetTextView.text = "翻译失败"
            }
        }
    }
    
    @IBAction func switchButton() {
        let language = AppUtil.sourceLanguage;
        AppUtil.sourceLanguage = AppUtil.targetLanguage;
        AppUtil.targetLanguage = language;
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
    @IBAction func speakSource() {
        if sourceTextView.text.count > 0 {
            AppUtil.speech(q: sourceTextView.text, language: AppUtil.sourceLanguage.ttsCode)
        }
    }
    
    @IBAction func speakTarget() {
        if targetTextView.text.count > 0 {
            AppUtil.speech(q: targetTextView.text, language: AppUtil.targetLanguage.ttsCode)
        }
    }
    
    @IBAction func clearTextView() {
        view.viewWithTag(188)?.isHidden = true
        view.viewWithTag(189)?.isHidden = true
        view.viewWithTag(190)?.isHidden = true // hide clear button
        lineView.isHidden = true
        targetTextView.text = ""
        sourceTextView.text = ""
    }
    
}

extension TranslateView1Controller: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.count > 0) {
            view.viewWithTag(188)?.isHidden = false
            view.viewWithTag(189)?.isHidden = false
            view.viewWithTag(190)?.isHidden = false // show clear button
            lineView.isHidden = false
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(doTranslate), object: nil)
            perform(#selector(doTranslate), with: nil, afterDelay: 0.5)
        } else {
            view.viewWithTag(188)?.isHidden = true
            view.viewWithTag(189)?.isHidden = true
            view.viewWithTag(190)?.isHidden = true // hide clear button
            lineView.isHidden = true
            targetTextView.text = ""
        }
    }
    
    @objc func doTranslate() {
        AppService.getInstance().translate(q: sourceTextView.text, from: AppUtil.sourceLanguage.translateCode, to: AppUtil.targetLanguage.translateCode, completionHandler: translateCompletion)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            sourceTextView.resignFirstResponder()
            return false
        } else { return true }
    }
    
}

extension TranslateView1Controller: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "string" {
            isTranslateResult = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isTranslateResult {
            translateResult = translateResult + string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "string" {
            DispatchQueue.main.async {
                self.targetTextView.text = self.translateResult
            }
            isTranslateResult = false
        }
    }
    
}
