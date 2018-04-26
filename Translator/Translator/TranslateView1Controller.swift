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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        sourceTextView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal)
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    func translateCompletion(result:String?) -> Void {
        DispatchQueue.main.async {
            if (result != nil)
            {
                self.targetTextView.text = result!;
            }
            else
            {
                self.targetTextView.text = "翻译失败";
            }
        }
    }
    
    @IBAction func switchButton() -> Void
    {
        let language = AppUtil.sourceLanguage;
        AppUtil.sourceLanguage = AppUtil.targetLanguage;
        AppUtil.targetLanguage = language;
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
    var translate2ViewController:TranslateView2Controller?;
    var translate3ViewController:TranslateView3Controller?;
    
    @IBAction func goToTranslate2() -> Void
    {
        if (translate2ViewController == nil)
        {
            translate2ViewController = storyboard?.instantiateViewController(withIdentifier: "translate2ViewController")
                as? TranslateView2Controller;
        }
        
        show(translate2ViewController!, sender: nil);
    }
    
    @IBAction func goToTranslate3() -> Void
    {
        if (translate3ViewController == nil)
        {
            translate3ViewController = storyboard?.instantiateViewController(withIdentifier: "translate3ViewController")
                as? TranslateView3Controller;
        }
        
        show(translate3ViewController!, sender: nil);
    }
    
    @IBAction func speakSource() {
        if sourceTextView.text.count > 0 {
            AppUtil.speech(q: sourceTextView.text, language: AppUtil.sourceLanguage.code)
        }
    }
    
    @IBAction func speakTarget() {
        if targetTextView.text.count > 0 {
            AppUtil.speech(q: targetTextView.text, language: AppUtil.targetLanguage.code)
        }
    }
    
    @IBAction func clearTextView() {
        view.viewWithTag(188)?.isHidden = true
        view.viewWithTag(189)?.isHidden = true
        view.viewWithTag(190)?.isHidden = true // hide clear button
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
            AppUtil.translate2(q: sourceTextView.text, completionHandler: translateCompletion)
        } else {
            
            view.viewWithTag(188)?.isHidden = true
            view.viewWithTag(189)?.isHidden = true
            view.viewWithTag(190)?.isHidden = true // hide clear button
            targetTextView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            sourceTextView.resignFirstResponder()
            return false
        } else { return true }
    }
    
}
