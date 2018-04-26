//
//  NavigationController.swift
//  TangdiTranslator
//
//  Created by coco on 29/08/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController
{
    
//    var clientSocket:GCDAsyncSocket!
//    var bufferBytes:[UInt8] = [UInt8]();   // 缓冲区字节
//    var packetBytesLength:Int = 0;         // 包字节长度
//    var packetBytes:[UInt8]!;                // 包字节
//    var processing:Bool = false;           // 包处理中
//
//    var heartTimer:DispatchSourceTimer?;   // 心跳计时器
//
//    var cacheMessage:Message?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
//        NotificationCenter.default.addObserver(self, selector: #selector(sendMessageAction),
//                                               name: Notification.Name.init(rawValue: "sendMessage"), object: nil);
//        NotificationCenter.default.addObserver(self, selector: #selector(appLoginAction),
//                                               name: Notification.Name.init("appLogin"), object: nil);
//        NotificationCenter.default.addObserver(self, selector: #selector(appLogoutAction),
//                                               name: Notification.Name.init("appLogout"), object: nil);
//
//        clientSocket = GCDAsyncSocket();
//        clientSocket.delegate = self;
//        clientSocket.delegateQueue = DispatchQueue.global();
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
//    func sendMessage(message:Message) -> Void
//    {
//        message.id = AppUtil.getTimeStamp();
//        DispatchQueue.global().async {
//            self.sendMessageInQueue(message: message);
//        }
//    }
    
//    func sendHeartMessage() -> Void
//    {
//        let message:Message = Message();
//        message.type = "heart";
//        message.content = "heart";
//        sendMessage(message: message);
//    }
    
//    func receiveMessage(message:Message) -> Void
//    {
//        switch message.type
//        {
//        case "appLogin":
//            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "loginMessage"), object: message);
//        case "getReportList":
//            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "getReportListMessage"), object: message);
//        case "getReport":
//            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "getReportMessage"), object: message);
//        default:
//            print("unknow message type");
//        }
//    }
    
//    @objc func sendMessageAction(notification:Notification)
//    {
//        let message:Message = notification.object as! Message;
//
//        if (!clientSocket.isConnected)
//        {
//            // 服务器没有连接 缓存消息 开始连接服务器
//            cacheMessage = message;
//            try? clientSocket.connect(toHost: "42.159.245.82", onPort: UInt16(11880));
//        }
//        else
//        {
//            // 服务器已经连接 不缓存消息 直接发送
//            cacheMessage = nil;
//            sendMessage(message: message);
//        }
//    }
    
//    @objc func appLoginAction(notification:Notification)
//    {
//        print("程序登录");
//        print("心跳启动");
//        heartTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global());
//        heartTimer?.schedule(deadline: .now(), repeating:
//            DispatchTimeInterval.seconds(30),
//                             leeway: DispatchTimeInterval.seconds(0));
//        heartTimer?.setEventHandler(handler: {
//            self.sendHeartMessage();
//        });
//        heartTimer?.activate();
//    }
    
//    @objc func appLogoutAction(notification:Notification)
//    {
//        print("程序退出");
//        heartTimer?.cancel();
//    }
    
}


//------------------------------------------------------------------------------------------------------------
//
//  extendsion GCDAsyncSocketDelegate
//
//------------------------------------------------------------------------------------------------------------

//extension NavigationController: GCDAsyncSocketDelegate
//{
//    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16)
//    {
//        print("socket connected");
//
//        // 与服务器连接成功 如果有缓存消息则发送缓存消息
//        if (cacheMessage != nil)
//        {
//            sendMessage(message: cacheMessage!);
//        }
//
//        clientSocket.readData(withTimeout: -1, tag: 0); // 开始socket读数据
//    }
//
//    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?)
//    {
//        print("socket disconnected");
//
//        // 服务器断开 退出登录 主线程
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: Notification.Name.init("appLogout"), object: nil);
//        }
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int)
//    {
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int)
//    {
//        let bytes:[UInt8] = [UInt8](data);
//        print("收到数据返回");
//        bufferBytes += bytes;
//        processSocketPacket();
//        clientSocket.readData(withTimeout: -1, tag: 0);
//    }
//
//    func processSocketPacket() -> Void
//    {
//        // 如果正在处理包 则返回
//        if (processing)
//        {
//            return;
//        }
//
//        processing = true;
//
//        // 读包头 当前包头等于0 且 缓存中的可读字节数大于包头的字节数才去读
//        if (packetBytesLength == 0 && bufferBytes.count >= 6)
//        {
//            readSocketPacketLength();
//            packetBytes = [UInt8]();
//        }
//
//        // 读包内容 只有内容大于包长度的时候才会去读
//        if (packetBytesLength > 0 && bufferBytes.count >= packetBytesLength)
//        {
//            var index:Int = 0;
//            while (index < packetBytesLength)
//            {
//                packetBytes.append(bufferBytes.removeFirst());
//                index += 1;
//            }
//
//            processPacket(packetData: packetBytes)
//
//            packetBytesLength = 0;
//            processing = false;
//
//            // 一个包处理完毕 继续处理下一个
//            if (bufferBytes.count > 0)
//            {
//                processSocketPacket();
//            }
//        }
//        else
//        {
//            processing = false;
//        }
//    }
//
//    func readSocketPacketLength() -> Void
//    {
//        packetBytesLength = -1;
//        var headBytes:[UInt8] = [UInt8]();
//        var index = 0;
//        while (index < 6)
//        {
//            headBytes.append(bufferBytes.removeFirst());
//            index += 1;
//        }
//
//        var packetLenght:UInt32;
//        packetLenght = (UInt32(headBytes[2]) << 24) | (UInt32(headBytes[3]) << 16);
//        packetLenght = packetLenght | (UInt32(headBytes[4]) << 8);
//        packetLenght = packetLenght | UInt32(headBytes[5]);
//        packetBytesLength = Int(packetLenght);
//        print(packetBytesLength);
//    }
//
//    func processPacket(packetData:[UInt8]) -> Void
//    {
//        let packetString:String? = String(bytes: packetData, encoding: .utf8);
//        if (packetString != nil)
//        {
//            let packetData:Data! = packetString?.data(using: .utf8);
//            let json:Any? = try? JSONSerialization.jsonObject(with: packetData, options: .allowFragments);
//            if (json != nil)
//            {
//                let jsonDic:[String: Any]? = json as? [String: Any]; // 强制转换
//                if (jsonDic != nil)
//                {
//                    let receiveMessage:Message = Message();
//                    receiveMessage.type = jsonDic!["type"] as! String;
//                    receiveMessage.content = jsonDic!["content"];
//
//                    print("线程\(Thread.current)", "receiveMessage:\(packetString!)");
//
//                    if (receiveMessage.type == "heart")
//                    {
//                        let message:Message = Message();
//                        message.type = "heart";
//                    }
//                    else
//                    {
//                        receiveMessageInQueue(message: receiveMessage);
//                    }
//                }
//            }
//        }
//    }
//
//    func sendMessageInQueue(message:Message) -> Void
//    {
//        // 把Message类 转换成 字典
//        var messageDic:[String: Any?] = ["id": message.id, "type": message.type];
//        if (message.content != nil)
//        {
//            messageDic["content"] = message.content;
//        }
//        // 把字典转换成 JSON
//        let messageJsonData = try? JSONSerialization.data(withJSONObject: messageDic);
//        if (messageJsonData != nil)
//        {
//            let messageBytes = [UInt8](messageJsonData!);
//            var sendBytes = [UInt8]();
//            let headByte:UInt8 = 0x55;
//            sendBytes.append(headByte);
//            sendBytes.append(headByte);
//            let messageLen:UInt32 = UInt32(messageBytes.count);
//            sendBytes.append(UInt8(messageLen>>24));
//            sendBytes.append(UInt8(messageLen>>16));
//            sendBytes.append(UInt8(messageLen>>8));
//            sendBytes.append(UInt8(messageLen));
//            sendBytes += messageBytes;
//            let sendData:Data = Data(bytes: sendBytes);
//            clientSocket.write(sendData, withTimeout: -1, tag: 0);
//            clientSocket.readData(withTimeout: -1, tag: 0);
//            print("发送数据包" + String(data: messageJsonData!, encoding: .utf8)!);
//        }
//    }
//
//    func receiveMessageInQueue(message:Message) -> Void
//    {
//        DispatchQueue.main.async {
//            self.receiveMessage(message: message);
//        }
//    }
//
//}
