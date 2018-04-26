//
//  MicrosoftSpeechService.swift
//  NewTranslate
//
//  Created by coco on 21/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import Starscream


/// 微软识别服务代理
protocol MicrosoftSpeechServiceDelegate {
    func didConnect()
    func receive(message: String)
    func didDisConnect()
}


///  微软识别服务
class MicrosoftSpeechService: WebSocketDelegate {
    
    var serviceToken:String = ""
    var serviceSocket:WebSocket!
    var delegate:MicrosoftSpeechServiceDelegate?
    var isEnabled: Bool = false
    
    func connect() {
        isEnabled = false
        print("获取微软服务token...")
        let tokenURL:URL! = URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken");
        var urlRequest:URLRequest = URLRequest(url: tokenURL);
        urlRequest.httpMethod = "POST";
        urlRequest.setValue(AppUtil.appStreamKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key");
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: tokenCompleteHandler);
        task.resume();
    }
    
    func disconnect() {
        isEnabled = false
        
        // 发送空白语音 来让服务器结束识别
        var raw_b = 0b0
        let data_b = NSMutableData(bytes: &raw_b, length: MemoryLayout<NSInteger>.size)
        for _ in 0...11000
        {
            data_b.append(&raw_b, length: MemoryLayout<NSInteger>.size)
        }
        
        print("send blank", data_b.length)
        serviceSocket?.write(data: data_b as Data)
    }
    
    func tokenCompleteHandler(data:Data?, response:URLResponse?, error:Error?) {
        guard error == nil && data != nil else {
            print("获取微软服务token...失败")
            return
        }
        
        print("获取微软服务token...成功")
        serviceToken = String(data: data!, encoding: String.Encoding.utf8)!;
        connectMicrosoftService()
    }
    
    func connectMicrosoftService() -> Void {
        print("连接微软服务...")
        let url = URL(string: "wss://dev.microsofttranslator.com/speech/translate?from=" + AppUtil.sourceLanguage.streamCode!  + "&to=" + AppUtil.targetLanguage.streamCode! + "&features=partial&api-version=1.0")
        serviceSocket = WebSocket(url: url!)
        serviceSocket?.headers["Authorization"] = "Bearer " + serviceToken
        serviceSocket?.headers["X-ClientAppId"] = "{ea66703d-90a8-436b-9bd6-7a2707a2ad99}"  // ANY IDENTIFIER
        serviceSocket?.headers["X-CorrelationId"] = "213091F1CF4aaD"    // ANY VALUE
        serviceSocket?.delegate = self
        serviceSocket?.connect()
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("连接微软服务...连接")
        isEnabled = true
        delegate?.didConnect()
    }
    
    func send(data: Data) {
        if (isEnabled) {
            print("发送实时数据", data.count)
            serviceSocket?.write(data: data)
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("微软服务...断开")
        delegate?.didDisConnect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("messa", text)
        delegate?.receive(message: text)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("接收音频数据返回")
    }
    
}
