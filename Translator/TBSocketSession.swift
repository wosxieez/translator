//
//  TBSocketSession.swift
//  Translator
//
//  Created by coco on 28/03/2018.
//  Copyright © 2018 coco. All rights reserved.
//

import UIKit

class TBSocketSession: NSObject {
    
    var delegate: TBSocketSessionDelegate?
    var clientSocket:GCDAsyncSocket?
    var bufferBytes:[UInt8] = [UInt8]()   // 缓冲区字节
    var packetBytesLength:Int = 0         // 包字节长度
    var packetBytes:[UInt8]!                // 包字节
    var processing:Bool = false           // 包处理中
    
    /// 是否已经连接
    var isConnected: Bool {
        get {
            return clientSocket == nil ? false : clientSocket!.isConnected
        }
    }
    
    func connect(host: String, port: Int) {
        clientSocket = GCDAsyncSocket()
        clientSocket?.delegate = self
        clientSocket?.delegateQueue = DispatchQueue.global()
        try? clientSocket?.connect(toHost: host, onPort: UInt16(port))
    }
    
    func disconnect() {
        clientSocket?.disconnect()
    }
    
}

extension TBSocketSession: GCDAsyncSocketDelegate {
    
    func getTimeStamp() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        delegate?.onConnect()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        delegate?.onDisconnect()
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let bytes:[UInt8] = [UInt8](data);
        bufferBytes += bytes;
        processSocketPacket();
        clientSocket?.readData(withTimeout: -1, tag: 0);
    }
    
    func processSocketPacket() {
        // 如果正在处理包 则返回
        if (processing) { return }
        processing = true;
        
        // 读包头 当前包头等于0 且 缓存中的可读字节数大于包头的字节数才去读
        if (packetBytesLength == 0 && bufferBytes.count >= 6) {
            readSocketPacketLength();
            packetBytes = [UInt8]();
        }
        
        // 读包内容 只有内容大于包长度的时候才会去读
        if (packetBytesLength > 0 && bufferBytes.count >= packetBytesLength) {
            var index:Int = 0;
            while index < packetBytesLength {
                packetBytes.append(bufferBytes.removeFirst());
                index += 1;
            }
            processPacket(packetData: packetBytes)
            packetBytesLength = 0;
            processing = false;
            
            // 一个包处理完毕 继续处理下一个
            if (bufferBytes.count > 0) { processSocketPacket() }
        } else { processing = false }
    }
    
    func readSocketPacketLength() {
        packetBytesLength = -1;
        var headBytes:[UInt8] = [UInt8]();
        var index = 0;
        while index < 6 {
            headBytes.append(bufferBytes.removeFirst());
            index += 1;
        }
        
        var packetLenght:UInt32;
        packetLenght = (UInt32(headBytes[2]) << 24) | (UInt32(headBytes[3]) << 16);
        packetLenght = packetLenght | (UInt32(headBytes[4]) << 8);
        packetLenght = packetLenght | UInt32(headBytes[5]);
        packetBytesLength = Int(packetLenght);
    }
    
    func processPacket(packetData:[UInt8]) {
        let packetString:String? = String(bytes: packetData, encoding: .utf8)
        if packetString != nil {
            let packetData:Data! = packetString?.data(using: .utf8)
            let json:Any? = try? JSONSerialization.jsonObject(with: packetData, options: .allowFragments)
            if json != nil {
                let jsonDic:[String: Any]? = json as? [String: Any]; // 强制转换
                if (jsonDic != nil) {
                    let message:Message = Message();
                    message.type = jsonDic!["type"] as! String;
                    message.content = jsonDic!["content"];
                    print("接收数据包:\(packetString!)");
                    if message.type != "heart" {
                        receiveMessage(message: message)
                    }
                }
            }
        }
    }
    
    func sendMessage(message:Message) {
        message.id = getTimeStamp()
        // 把Message类 转换成 字典
        var messageDic:[String: Any?] = ["id": message.id, "type": message.type];
        if message.content != nil {
            messageDic["content"] = message.content;
        }
        // 把字典转换成 JSON
        let messageJsonData = try? JSONSerialization.data(withJSONObject: messageDic);
        if messageJsonData != nil {
            let messageBytes = [UInt8](messageJsonData!);
            var sendBytes = [UInt8]();
            let headByte:UInt8 = 0x55;
            sendBytes.append(headByte);
            sendBytes.append(headByte);
            let messageLen:UInt32 = UInt32(messageBytes.count);
            sendBytes.append(UInt8(messageLen>>24));
            sendBytes.append(UInt8(messageLen>>16));
            sendBytes.append(UInt8(messageLen>>8));
            sendBytes.append(UInt8(messageLen));
            sendBytes += messageBytes;
            let sendData:Data = Data(bytes: sendBytes);
            clientSocket?.write(sendData, withTimeout: -1, tag: 0);
            clientSocket?.readData(withTimeout: -1, tag: 0);
            print("发送数据包" + String(data: messageJsonData!, encoding: .utf8)!);
        }
    }
    
    func receiveMessage(message:Message) {
        delegate?.onMessage(message: message)
    }
}


/// TBSocket 会话代理
protocol TBSocketSessionDelegate {
    
    /// socket已经连接
    func onConnect()
    
    /// socket已经断开
    func onDisconnect()
    
    /// 收到消息是调用
    ///
    /// - Parameter message: 消息内容
    func onMessage(message: Message)
    
}
