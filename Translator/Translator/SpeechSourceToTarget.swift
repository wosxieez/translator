//
//  SourceToTarget.swift
//  Translator
//
//  Created by coco on 11/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import AVFoundation;

/**
 将源语法转化为目标语言
 */
class SpeechSourceToTarget: NSObject
{
    
    private static var instance:SpeechSourceToTarget?;
    
    public static func getInstance() -> SpeechSourceToTarget
    {
        if (instance == nil)
        {
            instance = SpeechSourceToTarget();
        }
        
        return instance!;
    }
    
    private var recorder:AVAudioRecorder!;
    private var thisResult:String!;
    public var thisCallback:((String, String) -> Void)!;
    /// 定义录音的参数
    private let recordSettings:[String: Any] = [
        AVSampleRateKey : 16000,//声音采样率
        AVFormatIDKey : kAudioFormatLinearPCM,//编码格式
        AVNumberOfChannelsKey : 1,//采集音轨
        AVLinearPCMBitDepthKey: 16,
        AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue];
    
    public func requestPermission()
    {
        AVAudioSession.sharedInstance().requestRecordPermission(requestRecordPermissionResult);
    }
    
    private func requestRecordPermissionResult(result:Bool) -> Void
    {
        print("Permission:", result);
        
        if (result)
        {
            var saveURLString = NSTemporaryDirectory();
            saveURLString.append("/record.wav");
            let saveURL:URL! = URL(string: saveURLString);
            
            print(saveURL.absoluteString);
            
            //初始化实例
            recorder = try? AVAudioRecorder(url: saveURL,settings: recordSettings);
            //准备录音
            recorder.prepareToRecord();
        }
    }
    
    public func start(callback:@escaping (String, String)->Void) -> Void
    {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                         with: AVAudioSessionCategoryOptions.allowBluetooth);
        thisCallback = callback;
        recorder.record();
    }
    
    public func stop() -> Void
    {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback);
        recorder.stop();
        sendData();
    }
    
    func reset() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        recorder.stop()
    }
    
    private func sendData() -> Void
    {
        var saveURLString = NSTemporaryDirectory();
        saveURLString.append("/record.wav");
        let saveURL:URL! = URL(fileURLWithPath: saveURLString);
        let data:Data? = try? Data(contentsOf: saveURL);
        
        var request:URLRequest =
            URLRequest(url: URL(string: "https://speech.platform.bing.com/speech/recognition/interactive/cognitiveservices/v1?language=" +
                AppUtil.sourceLanguage.code + "&format=simple")!);
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
                    AppUtil.translate(q: thisResult, language: AppUtil.targetLanguage.speechCode, completionHandler: translateCompletion);
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
    
    func translateCompletion(result:String?) -> Void
    {
        thisCallback(thisResult, result!);
    }
    
}
