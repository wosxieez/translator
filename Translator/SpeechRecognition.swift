//
//  SpeechRecognition.swift
//  NewTranslate
//
//  Created by coco on 21/12/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import AVFoundation


protocol SpeechRecognitionDelegate {
    func didConnect()
    func receive(message: String)
    func didDisConnect()
}

class SpeechRecognition {
    
    var audioQueueRef: AudioQueueRef? // 可选值 该值由AudioQueueNewInput来赋值
    var audioQueueBufferRefs = [AudioQueueBufferRef?](repeating: nil, count: 3) // 定义3个音频缓冲区
    var microsoftSpeechService: MicrosoftSpeechService?
    var delegate: SpeechRecognitionDelegate?
    var isRunning: Bool = false
    
    func start() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.allowBluetooth)
        DispatchQueue.global().async {
            self.microsoftSpeechService = MicrosoftSpeechService()
            self.microsoftSpeechService?.delegate = self
            self.microsoftSpeechService?.connect()
        }
    }
    
    func stop() {
        DispatchQueue.global().async {
            self.microsoftSpeechService?.disconnect()
            if self.audioQueueRef != nil { AudioQueueStop(self.audioQueueRef!, false) }
        }
    }
    
    
    /// 获取WAV音频头
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


extension SpeechRecognition: MicrosoftSpeechServiceDelegate {
    
    func didConnect() {
        delegate?.didConnect()
        
        // 发送音频头字节
        let header = getFileHeader(1000000, samlpleRate: 16000, byteRate: 32000)
        microsoftSpeechService?.send(data: Data(bytes: header, count: header.count))
        
        // 启动本地音频服务
        var audioStreamBasicDescription = AudioStreamBasicDescription()
        audioStreamBasicDescription.mSampleRate = 16000 // 采样率16000 一秒钟取样16000次数据
        audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM
        audioStreamBasicDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        audioStreamBasicDescription.mChannelsPerFrame = 1 // 单声道
        audioStreamBasicDescription.mFramesPerPacket = 1 // 每个包一个帧数据
        audioStreamBasicDescription.mBitsPerChannel = 16
        audioStreamBasicDescription.mBytesPerFrame = audioStreamBasicDescription.mChannelsPerFrame * audioStreamBasicDescription.mBitsPerChannel / 8
        audioStreamBasicDescription.mBytesPerPacket = audioStreamBasicDescription.mBytesPerFrame
        
        AudioQueueNewInput(&audioStreamBasicDescription, { (inUserData, inAQ, inBuffer, inStartTime, inNumPacketDescs, inPacketDescs) in
            let byteBufferPointer = UnsafeBufferPointer(start: inBuffer.pointee.mAudioData.assumingMemoryBound(to: UInt8.self), count: Int(inBuffer.pointee.mAudioDataByteSize))
            let audiodata = Data(buffer: byteBufferPointer)
            let mss = inUserData?.assumingMemoryBound(to: MicrosoftSpeechService.self)
            mss?.pointee.send(data: audiodata)
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
        }, &microsoftSpeechService, nil, nil, 0, &audioQueueRef)
        
        // 设置缓冲区
        for index in 0...2 {
            AudioQueueAllocateBuffer(audioQueueRef!, 8000, &audioQueueBufferRefs[index]) // 分配缓冲区
            AudioQueueEnqueueBuffer(audioQueueRef!, audioQueueBufferRefs[index]!, 0, nil)
        }
        
        AudioQueueStart(audioQueueRef!, nil)
    }
    
    func receive(message: String) {
        delegate?.receive(message: message)
    }
    
    func didDisConnect() {
        delegate?.didDisConnect()
    }
    
}
