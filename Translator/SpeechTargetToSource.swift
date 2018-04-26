//
//  SpeechTargetToSource.swift
//  Translator
//
//  Created by coco on 11/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import AVFoundation;

class SpeechTargetToSource: NSObject {
    
    private static var instance:SpeechTargetToSource?;
    
    public static func getInstance() -> SpeechTargetToSource {
        if (instance == nil) {
            instance = SpeechTargetToSource();
        }
        return instance!;
    }
    
    var isTranslateResult = false
    private var recorder:AVAudioRecorder?
    private var thisResult:String!
    public var thisCallback:((String, String) -> Void)!
    /// 定义录音的参数
    private let recordSettings:[String: Any] = [
        AVSampleRateKey : 16000,//声音采样率
        AVFormatIDKey : kAudioFormatLinearPCM,//编码格式
        AVNumberOfChannelsKey : 1,//采集音轨
        AVLinearPCMBitDepthKey: 16,
        AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue];
    
    public func start(callback:@escaping (String, String)->Void) -> Void
    {
        thisCallback = callback
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.allowBluetooth)
        var saveURLString = NSTemporaryDirectory()
        saveURLString.append("/record2.wav")
        let saveURL:URL! = URL(string: saveURLString)
        recorder = try? AVAudioRecorder(url: saveURL,settings: recordSettings)
        recorder?.prepareToRecord()
        recorder?.record();
    }
    
    /// 停止@识别
    public func stopAndRecognition() -> Void
    {
        recorder?.stop()
        sendData()
    }
    
    /// 停止@不识别
    func stop() {
        recorder?.stop()
    }
    
    private func sendData() -> Void
    {
        var saveURLString = NSTemporaryDirectory();
        saveURLString.append("/record2.wav");
        let saveURL:URL! = URL(fileURLWithPath: saveURLString);
        let data:Data? = try? Data(contentsOf: saveURL);
        
        var request:URLRequest =
            URLRequest(url: URL(string: "https://speech.platform.bing.com/speech/recognition/interactive/cognitiveservices/v1?language=" +
                AppUtil.targetLanguage.recognitionCode! + "&format=simple")!);
        request.setValue("audio/wav; codec=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type");
        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding");
        request.setValue("Bearer " + SpeechToken.getInstance().token, forHTTPHeaderField: "Authorization");
        request.httpMethod = "POST";
        
        request.httpBody = data;
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: result);
        dataTask.resume();
        print("发送语音请求")
    }
    
    private func result(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        print("收到语音请求结果");
        if (data != nil)
        {
            let resultObject:Any? = try? JSONSerialization.jsonObject(with: data!,
                                                                      options: JSONSerialization.ReadingOptions.mutableLeaves);
            let resultDic:[String: Any]? = resultObject as? [String: Any];
            if (resultDic != nil)
            {
                let result:String? = resultDic!["DisplayText"] as? String;
                if (result != nil)
                {
                    thisResult = result;
                    // 翻译
                    AppService.getInstance().translate(q: thisResult, from: AppUtil.targetLanguage.translateCode, to: AppUtil.sourceLanguage.translateCode, completionHandler: translateCompletion);
                }
                else
                {
                    thisCallback("无法识别", "");
                }
            }
            else
            {
                thisCallback("无法识别", "");
            }
        }
        else
        {
            thisCallback("无法识别", "");
        }
    }
    
    func translateCompletion(data:Data?) {
        if data != nil {
            let xmlParser = XMLParser(data: data!)
            xmlParser.delegate = self
            xmlParser.parse()
        } else {
            thisCallback(thisResult, "翻译失败");
        }
    }
    
}


extension SpeechTargetToSource: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print(elementName)
        if elementName == "string" {
            isTranslateResult = true
        } else {
            isTranslateResult = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isTranslateResult {
            print(string)
            thisCallback(thisResult, string)
        }
        isTranslateResult = false
    }
    
}

