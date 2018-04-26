//
//  SpeechToken.swift
//  Translator
//
//  Created by coco on 11/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class SpeechToken: NSObject {
    private static var instance:SpeechToken?;
    
    public static func getInstance() -> SpeechToken {
        if (instance == nil) {
            instance = SpeechToken()
        }
        return instance!
    }
    
    private var getTokenTimer:DispatchSourceTimer!;
    public var token:String = "";
    
    public func getToken() -> Void
    {
        getTokenTimer = DispatchSource.makeTimerSource(flags: [],
                                                       queue: DispatchQueue.global());
        getTokenTimer.schedule(deadline: DispatchTime.now(), repeating: 300);
        getTokenTimer.setEventHandler {
            self.getTokenNow();
        }
        getTokenTimer.resume();
    }
    
    private func getTokenNow() -> Void
    {
        // c4fa2eefa1264c4585e912c985d8299f
        // 1bb023221dba44e9bf9a6c796972269d
        // get token
        print("开始获取token")
        let tokenURL:URL! = URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken");
        var urlRequest:URLRequest = URLRequest(url: tokenURL);
        urlRequest.httpMethod = "POST";
        urlRequest.setValue(AppUtil.appSpeechKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key");
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest,
                                                                 completionHandler: tokenCompleteHandler);
        task.resume();
    }
    
    func tokenCompleteHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        guard error == nil && data != nil else {
            return
        }
        token = String(data: data!, encoding: String.Encoding.utf8)!;
        print("token获取成功", token)
//        let helloPath:String? = Bundle.main.path(forResource: "HelloWorld", ofType: "wav");
//        let helloURL:URL = URL(fileURLWithPath: helloPath!);
//        let helloData:Data? = try? Data(contentsOf: helloURL);
//        var request:URLRequest =
//            URLRequest(url: URL(string: "https://speech.platform.bing.com/speech/recognition/interactive/cognitiveservices/v1?language=" +
//                AppUtil.sourceLanguage.recognitionCode! + "&format=simple")!);
//        request.setValue("audio/wav; codec=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type");
//        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding");
//        request.setValue("Bearer " + SpeechToken.getInstance().token, forHTTPHeaderField: "Authorization");
//        request.httpMethod = "POST";
//        request.httpBody = helloData;
//        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: initResult);
//        dataTask.resume();
    }
    
//    private func initResult(data:Data?, response:URLResponse?, error:Error?) -> Void
//    {
//    }
    
}
