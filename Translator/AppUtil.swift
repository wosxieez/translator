//
//  AppUtil.swift
//  TangdiTranslator
//
//  Created by coco on 22/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import Foundation
import AVFoundation
import SystemConfiguration.CaptiveNetwork

class AppUtil {
    
    static var currentDevice: [String: Any]? {
        
        didSet {
            
            NotificationCenter.default.post(name: AppNotification.DidUpdateDeviceInfo, object: nil)
        }
    }
    
    /// http服务地址
    static var httpServerURL: String {
        
        get {
            
            if Bundle.main.infoDictionary?["UseDebugServer"] as? Int == 1 {
                return "http://testbgt.tombot.com.cn:3989/"
            } else {
                
                return "http://42.159.245.82:8181/"
            }
        }
    }
    
    /// Socket服务主机
    static var socketServerHost: String {
        get {
            if Bundle.main.infoDictionary?["UseDebugServer"] as? Int == 1 {
                return "testbgt.tombot.com.cn"
            } else {
                return "42.159.245.82"
            }
        }
    }
    
    /// Socket服务端口
    static var socketServerPort: Int {
        get {
            if Bundle.main.infoDictionary?["UseDebugServer"] as? Int == 1 {
                return 3992
            } else {
                return 11880
            }
        }
    }
    
    /// 当前登录的用户信息用户名&密码&性别
    static var username:String?
    static var password:String?
    static var sex: String?
    
    /// 将要注册的用户名&密码
    static var uesrnameForRegister: String?
    static var passwordForRegister: String?
    
    static var themeColor = UIColor(red: 78/255, green: 149/255, blue: 231/255, alpha: 1)
    static let supportLanguages = [Language(name: "中文", streamCode: "zh-CN", recognitionCode: "zh-CN", translateCode: "zh-Hans", ttsCode: "zh-CN", ocrCode: "zh-Hans"),
                                   Language(name: "阿拉伯语",  streamCode: "ar-EG", recognitionCode: "ar-EG", translateCode: "ar", ttsCode: "ar-EG", ocrCode: "ar"),
                                   Language(name: "丹麦语", streamCode: nil, recognitionCode: "da-DK", translateCode: "da", ttsCode: "da-DK", ocrCode: "da"),
                                   Language(name: "德语", streamCode: "de-DE", recognitionCode: "de-DE", translateCode: "de", ttsCode: "de-DE", ocrCode: "de"),
                                   Language(name: "英语", streamCode: "en-US", recognitionCode: "en-US", translateCode: "en", ttsCode: "en-US", ocrCode: "en"),
                                   Language(name: "英语(澳大利亚)", streamCode: nil, recognitionCode: "en-AU", translateCode: "en", ttsCode: "en-AU", ocrCode: "en"),
                                   Language(name: "英语(加拿大)", streamCode: nil, recognitionCode: "en-CA", translateCode: "en", ttsCode: "en-CA", ocrCode: "en"),
                                   Language(name: "英语(英国)", streamCode: nil, recognitionCode: "en-GB", translateCode: "en", ttsCode: "en-GB", ocrCode: "en"),
                                   Language(name: "英语(印度)", streamCode: nil, recognitionCode: "en-IN", translateCode: "en", ttsCode: "en-IN", ocrCode: "en"),
                                   Language(name: "英语(新西兰)", streamCode: nil, recognitionCode: "en-NZ", translateCode: "en", ttsCode: "en-NZ", ocrCode: "en"),
                                   Language(name: "西班牙语", streamCode: "es-ES", recognitionCode: "es-ES", translateCode: "es", ttsCode: "es-ES", ocrCode: "es"),
                                   Language(name: "西班牙语(墨西哥)", streamCode: nil, recognitionCode: "es-MX", translateCode: "es", ttsCode: "es-MX", ocrCode: "es"),
                                   Language(name: "芬兰语", streamCode: nil, recognitionCode: "fi-FI", translateCode: "fi", ttsCode: "fi-FI", ocrCode: "fi"),
                                   Language(name: "法语(加拿大)", streamCode: nil, recognitionCode: "fr-CA", translateCode: "fr", ttsCode: "fr-CA", ocrCode: "fr"),
                                   Language(name: "法语", streamCode: "fr-FR", recognitionCode: "fr-FR", translateCode: "fr", ttsCode: "fr-FR", ocrCode: "fr"),
                                   Language(name: "印度语", streamCode: nil, recognitionCode: "hi-IN", translateCode: "hi", ttsCode: "hi-IN", ocrCode: nil),
                                   Language(name: "意大利语", streamCode: "it-IT", recognitionCode: "it-IT", translateCode: "it", ttsCode: "it-IT", ocrCode: "it"),
                                   Language(name: "日语", streamCode: "ja-JP", recognitionCode: "ja-JP", translateCode: "ja", ttsCode: "ja-JP", ocrCode: "ja"),
                                   Language(name: "韩语", streamCode: nil, recognitionCode: "ko-KR", translateCode: "ko", ttsCode: "ko-KR", ocrCode: "ko"),
                                   Language(name: "挪威语", streamCode: nil, recognitionCode: "nb-NO", translateCode: "nb", ttsCode: "nb-NO", ocrCode: "nb"),
                                   Language(name: "荷兰语", streamCode: nil, recognitionCode: "nl-NL", translateCode: "nl", ttsCode: "nl-NL", ocrCode: "nl"),
                                   Language(name: "波兰语", streamCode: nil, recognitionCode: "pl-PL", translateCode: "pl", ttsCode: "pl-PL", ocrCode: "pl"),
                                   Language(name: "葡萄牙语(巴西)", streamCode: "pt-BR", recognitionCode: "pt-BR", translateCode: "pt", ttsCode: "pt-BR", ocrCode: "pt"),
                                   Language(name: "葡萄牙语", streamCode: nil, recognitionCode: "pt-PT", translateCode: "pt", ttsCode: "pt-PT", ocrCode: "pt"),
                                   Language(name: "俄语", streamCode: "ru-RU", recognitionCode: "ru-RU", translateCode: "ru", ttsCode: "ru-RU", ocrCode: "ru"),
                                   Language(name: "瑞典语", streamCode: nil, recognitionCode: "sv-SE", translateCode: "sv", ttsCode: "sv-SE", ocrCode: "sv"),
                                   Language(name: "中文(香港)", streamCode: nil, recognitionCode: "zh-HK", translateCode: "yue", ttsCode: "zh-HK", ocrCode: "zh-Hans"),
                                   Language(name: "中文(台湾)", streamCode: "zh-TW", recognitionCode: "zh-TW", translateCode: "zh-Hant", ttsCode: "zh-TW", ocrCode: "zh-Hans")]
    
    private static var _sourceLanguage = Language(name: "中文", streamCode: "zh-CN", recognitionCode: "zh-CN", translateCode: "zh-Hans", ttsCode: "zh-CN", ocrCode: "zh-Hans")
    private static var _targetLanguage = Language(name: "英语", streamCode: "en-US", recognitionCode: "en-US", translateCode: "en", ttsCode: "en-US", ocrCode: "en")
    
    static let player: AVSpeechSynthesizer! = AVSpeechSynthesizer()
    
    public static var targetLanguage:Language {
        get {
            return _targetLanguage
        }
        set {
            _targetLanguage = newValue
            NotificationCenter.default.post(Notification(name: Notification.Name("languageChanged")))
        }
    }
    
    public static var sourceLanguage:Language {
        get {
            return _sourceLanguage;
        }
        set {
            _sourceLanguage = newValue
            NotificationCenter.default.post(Notification(name: Notification.Name("languageChanged")))
        }
    }
    
    static func getLanguage(by code: String?) -> Language? {
        for language in supportLanguages {
            if language.recognitionCode == code {
                return language
            }
        }
        return nil
    }
    
    public static func speech(q: String?, language: String?) -> Void {
        guard q != nil && language != nil else { return }
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        if player.isSpeaking { player.stopSpeaking(at: .immediate)}
        let u = AVSpeechUtterance(string: q!)
        u.voice = AVSpeechSynthesisVoice(language: language)
        u.volume = 1.0;
        player.speak(u)
    }
    
    /// 判断目前字符串是不是正确的密码格式
    public static func isPassword(value: String?) -> Bool {
        guard value != nil && value!.count >= 6 && value!.count <= 18 else {
            return false
        }
        return true
        
        //        let predicate = NSPredicate(format: " SELF MATCHES %@" , "^[A-Z0-9a-z]{6,18}")
        //        return predicate.evaluate(with: value);
    }
    
    /// 判断目前字符串是不是手机号码格式
    public static func isPhoneNumber(phoneNumber:String) -> Bool {
        let mobile = "^(13[0-9]|15[0-9]|18[0-9]|17[0-9]|147)\\d{8}$"
        let regexMobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        if regexMobile.evaluate(with: phoneNumber) == true {
            return true
        } else {
            return false
        }
    }
    
    
    /// 获取当前连接WIFI的SSID
    ///
    /// - Returns: SSID
    static func getSSID() -> String? {
        let interfaces = CNCopySupportedInterfaces()
        var ssid: String?
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<AnyObject>
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as! CFString
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                if (ussafeInterfaceData != nil) {
                    let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                    ssid = interfaceData["SSID"]! as? String
                }
            }
        }
        return ssid
    }
    
    static var appStreamKey: String?
    static var appSpeechKey: String?
    static var appTranslateKey: String?
    static var appOcrKey: String?
    
    /// 获取程序的秘钥
    static func getAppKey() {
        AppService.getInstance().getAppKey(type: "0") { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let dataDic = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                if dataDic["resultCode"] as? String == "0" {
                    appSpeechKey = dataDic["value"] as? String
                    print("Speech Key:", appSpeechKey!)
                    SpeechToken.getInstance().getToken()
                }
            }
        }
        AppService.getInstance().getAppKey(type: "1") { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let dataDic = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                if dataDic["resultCode"] as? String == "0" {
                    appTranslateKey = dataDic["value"] as? String
                    print("Translate Key:", appTranslateKey!)
                }
            }
        }
        AppService.getInstance().getAppKey(type: "2") { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let dataDic = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                if dataDic["resultCode"] as? String == "0" {
                    appStreamKey = dataDic["value"] as? String
                    print("Stream Key:", appStreamKey!)
                }
            }
        }
        AppService.getInstance().getAppKey(type: "3") { (data, response, error) in
            guard data != nil && error == nil else { return }
            if let dataDic = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)) as? [String: Any] {
                if dataDic["resultCode"] as? String == "0" {
                    appOcrKey = dataDic["value"] as? String
                    print("OCR Key:", appOcrKey!)
                }
            }
        }
    }
    
}
