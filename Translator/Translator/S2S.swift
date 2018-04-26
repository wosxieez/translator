//
//  S2S.swift
//  Translator
//
//  Created by coco on 28/11/2017.
//  Copyright © 2017 coco. All rights reserved.
//
import Starscream;
import AVFoundation;

class S2S: WebSocketDelegate
{
    
    var clientToken:String = "";
    var websocket:WebSocket?;
    var recorder:AVAudioRecorder!;
    var thisCallback:((String, String) -> Void)!;
    
    //定义音频的编码参数
    let recordSettings:[String: Any] = [
        AVSampleRateKey : 16000,//声音采样率
        AVFormatIDKey : kAudioFormatLinearPCM,//编码格式
        AVNumberOfChannelsKey : 1,//采集音轨
        AVLinearPCMBitDepthKey: 16,
        AVEncoderAudioQualityKey : AVAudioQuality.medium.rawValue];
    
    var getTokenTimer:DispatchSourceTimer!;
    
    func getToken()
    {
        getTokenTimer = DispatchSource.makeTimerSource(flags: [],
                                                       queue: DispatchQueue.global());
        getTokenTimer.schedule(deadline: DispatchTime.now(), repeating: 300);
        getTokenTimer.setEventHandler {
            self.getTokenNow();
        }
        getTokenTimer.resume();
    }
    
    func getTokenNow() -> Void
    {
        print("刷新token");
        // c4fa2eefa1264c4585e912c985d8299f
        // 1bb023221dba44e9bf9a6c796972269d
        // get token
        let tokenURL:URL! = URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken");
        var urlRequest:URLRequest = URLRequest(url: tokenURL);
        urlRequest.httpMethod = "POST";
        urlRequest.setValue("c4fa2eefa1264c4585e912c985d8299f", forHTTPHeaderField: "Ocp-Apim-Subscription-Key");
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: urlRequest,
                                                                 completionHandler: tokenCompleteHandler);
        task.resume();
    }
    
    func requestPermission()
    {
        AVAudioSession.sharedInstance().requestRecordPermission(requestRecordPermissionResult);
    }
    
    func requestRecordPermissionResult(result:Bool) -> Void
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
    
    func start(callback:@escaping (String, String)->Void) -> Void
    {
        print("start record");
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                         with: AVAudioSessionCategoryOptions.allowBluetooth);
        thisCallback = callback;
        recorder.record();
    }
    
    func stop() -> Void
    {
        print("stop record");
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback);
        recorder.stop();
        sendData();
    }
    
    func tokenCompleteHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        clientToken = String(data: data!, encoding: String.Encoding.utf8)!;
        print("token===\(clientToken)");
    }
    
    func connectToWebSocketServer() -> Void
    {
//        let url = URL(string: "wss://dev.microsofttranslator.com/speech/translate?from=" + from +
//            "&to=" + to + "&features=Partial&api-version=1.0");
//        websocket = WebSocket(url: url!);
//        websocket?.headers["Authorization"] = "Bearer " + (clientToken as String)
//        websocket?.headers["X-ClientAppId"] = "{ea66703d-90a8-436b-9bd6-7a2707a2ad99}"  // ANY IDENTIFIER
//        websocket?.headers["X-CorrelationId"] = "213091F1CF4aaD"    // ANY VALUE
//        websocket?.delegate = self;
//        websocket?.timeout = 5;
//        websocket?.connect();
    }
    
    func websocketDidConnect(socket: WebSocket)
    {
        print("连接成功");
    }
    
    func sendData() -> Void
    {
        //        if (websocket == nil || !websocket!.isConnected)
        //        {
        //            return;
        //        }
        //
        //        var saveURLString = NSTemporaryDirectory();
        //        saveURLString.append("/record.wav");
        //        let saveURL:URL = URL(fileURLWithPath: saveURLString);
        //
        //        var audioFile : AVAudioFile?
        //        var audioFileBuffer : AVAudioPCMBuffer
        //
        //        // *************OPEN RECORDED FILE FOR READING AND CHUNKING TO SEND TO SERVICE
        //        do {
        //            audioFile = try AVAudioFile.init(forReading: saveURL,
        //                                             commonFormat: .pcmFormatInt16, interleaved: false) //open the audio file for reading
        //            print(audioFile!.processingFormat)
        //        }
        //        catch {
        //            print("error reading file")
        //            // Handle error...
        //        }
        //
        //        audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFile!.processingFormat, frameCapacity: UInt32(audioFile!.length))!
        //
        //        do {
        //            try audioFile!.read(into: audioFileBuffer)
        //        }
        //        catch {
        //            print("error loading buffer")
        //            // Handle error
        //        }
        //
        //        let channels = UnsafeBufferPointer(start: audioFileBuffer.int16ChannelData, count: 1)
        //        let length = Int(audioFileBuffer.frameCapacity * audioFileBuffer.format.streamDescription.pointee.mBytesPerFrame)
        //        let audioData = Data(bytes: channels[0], count: length)
        //
        //        let header = getFileHeader(audioData.count, samlpleRate: 16000, byteRate: 32000);
        //        print(Data.init(bytes: header, count: header.count));
        //        websocket?.write(data: Data.init(bytes: header, count: header.count));
        //
        //        if audioData.count > 0
        //        {
        //            websocket?.write(data: audioData);
        //
        //            // 发送空白语音 来让服务器结束识别
        //            var raw_b = 0b0
        //            let data_b = NSMutableData(bytes: &raw_b, length: MemoryLayout<NSInteger>.size)
        //            for _ in 0...11000
        //            {
        //                data_b.append(&raw_b, length: MemoryLayout<NSInteger>.size)
        //            }
        //
        //            print("send blank", data_b.length)
        //            websocket?.write(data: data_b as Data)
        //        }
        
        var saveURLString = NSTemporaryDirectory();
        saveURLString.append("/record.wav");
        let saveURL:URL! = URL(fileURLWithPath: saveURLString);
        let data:Data? = try? Data(contentsOf: saveURL);
        
        // 删除文件
        do
        {
            try FileManager.default.removeItem(at: saveURL);
            print("删除音频文件成功");
        }
        catch
        {
            print("删除音频文件失败");
        }
        
        if (data == nil || data!.count <= 20000)
        {
            print("数据不存在/数据过短 返回");
            return;
        }
        
        print(data!.count);
        
//        var request:URLRequest =
//            URLRequest(url: URL(string: "https://speech.platform.bing.com/speech/recognition/interactive/cognitiveservices/v1?language=" +
//                (AppUtil.isRightButtonTouchDown ? AppUtil.targetLanguage.code : AppUtil.sourceLanguage.code) + "&format=simple")!);
//        request.setValue("audio/wav; codec=audio/pcm; samplerate=16000", forHTTPHeaderField: "Content-Type");
//        request.setValue("chunked", forHTTPHeaderField: "Transfer-Encoding");
//        request.setValue("Bearer " + (clientToken as String), forHTTPHeaderField: "Authorization");
//        request.httpMethod = "POST";
//        
//        request.httpBody = data;
//        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: result);
//        dataTask.resume();
        print("发起音频数据");
    }
    
    func result(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
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
                    thisCallback(result!, "");
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
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?)
    {
        print("连接不成功", error.debugDescription);
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String)
    {
        print("接收到消息", text);
        let dic:[String: Any] = try! JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.mutableLeaves)
            as! [String: Any];
        if (dic["type"] as! String == "final")
        {
            self.thisCallback(dic["recognition"] as! String, dic["translation"] as! String);
            self.websocket?.disconnect();
            self.websocket = nil;
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data)
    {
        print("接收到数据");
    }
    
    //*****CREATE WAV FILE HEADER
    func getFileHeader(_ leng: Int, samlpleRate: Int, byteRate: Int) -> [UInt8]{
        
        var header: [UInt8] = [UInt8](repeating: 0, count: 44)
        let dataSize = leng + 44
        
        for a in "R".utf8 {
            header[0] = a
        }
        for a in "I".utf8 {
            header[1] = a
        }
        for a in "F".utf8 {
            header[2] = a
        }
        for a in "F".utf8 {
            header[3] = a
        }
        header[4] = numericCast((dataSize & 0xff))
        header[5] = numericCast(((dataSize >> 8) & 0xff))
        header[6] = numericCast(((dataSize >> 16) & 0xff))
        header[7] = numericCast(((dataSize >> 24) & 0xff))
        for a in "W".utf8 {
            header[8] = a
        }
        for a in "A".utf8 {
            header[9] = a
        }
        for a in "V".utf8 {
            header[10] = a
        }
        for a in "E".utf8 {
            header[11] = a
        }
        for a in "f".utf8 {
            header[12] = a
        }
        for a in "m".utf8 {
            header[13] = a
        }
        for a in "t".utf8 {
            header[14] = a
        }
        
        for a in " ".utf8 {
            header[15] = a
        }
        header[16] = 16
        header[17] = 0
        header[18] = 0
        header[19] = 0
        header[20] = 1
        header[21] = 0
        header[22] = numericCast(1)
        header[23] = 0
        header[24] = numericCast((samlpleRate & 0xff))
        header[25] = numericCast(((samlpleRate >> 8) & 0xff))
        header[26] = numericCast(((samlpleRate >> 16) & 0xff))
        header[27] = numericCast(((samlpleRate >> 24) & 0xff))
        header[28] = numericCast((byteRate & 0xff))
        header[29] = numericCast(((byteRate >> 8) & 0xff))
        header[30] = numericCast(((byteRate >> 16) & 0xff))
        header[31] = numericCast(((byteRate >> 24) & 0xff))
        header[32] = numericCast(2 * 8 / 8)
        header[33] = 0
        header[34] = 16
        header[35] = 0
        for a in "d".utf8 {
            header[36] = a
        }
        for a in "a".utf8 {
            header[37] = a
        }
        for a in "t".utf8 {
            header[38] = a
        }
        for a in "a".utf8 {
            header[39] = a
        }
        header[40] = numericCast((leng & 0xff))
        header[41] = numericCast(((leng >> 8) & 0xff))
        header[42] = numericCast(((leng >> 16) & 0xff))
        header[43] = numericCast(((leng >> 24) & 0xff))
        
        return header
    }
    
}
