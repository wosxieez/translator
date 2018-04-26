//
//  AppUtil.swift
//  TangdiTranslator
//
//  Created by coco on 22/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//
import Foundation
import AVFoundation;

class AppUtil {
    
    static var username:String?
    static var password:String?
    static var themeColor:UIColor = UIColor(red: 58/255, green: 187/255, blue: 255/255, alpha: 1)
    static var _sourceLanguage:Language = Language(name:"中文", code:"zh-CN", speechCode: "zh")
    static var _targetLanguage:Language = Language(name:"英语", code:"en-US", speechCode: "en")
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
    
    public static func getTimeStamp() -> String {
        return String(Int(Date().timeIntervalSince1970))
    }
    
    public static func translate(q:String, language:String, completionHandler: @escaping (String?) -> Void) -> Void {
        let appid = "2015063000000001"
        let salt = String(Int(Date().timeIntervalSince1970))
        var signString = appid + q + salt + "12345678"
        signString = signString.md5()
        let postString = "q=" + q + "&from=auto&to=" + language +
            "&appid=" + appid + "&salt=" + salt + "&sign=" + signString
        let url = URL(string: "http://api.fanyi.baidu.com/api/trans/vip/translate")
        var urlRequest:URLRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = postString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                //print(error.debugDescription);
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: AnyObject];
                    let trans_result = json?["trans_result"] as? [[String: AnyObject]];
                    if (trans_result != nil) {
                        if (trans_result!.count > 0) {
                            completionHandler(trans_result![0]["dst"] as? String);
                        }
                    }
                } catch {
                    //print("翻译错误", error.description);
                }
            }
        })
        dataTask.resume();
    }
    
    public static func translate2(q:String, completionHandler: @escaping (String?) -> Void) -> Void {
        let appid = "2015063000000001";
        let salt = String(Int(Date().timeIntervalSince1970));
        var signString = appid + q + salt + "12345678";
        signString = signString.md5();
        let postString = "q=" + q + "&from=auto&to=" + targetLanguage.speechCode +
            "&appid=" + appid + "&salt=" + salt + "&sign=" + signString;
        let url = URL(string: "http://api.fanyi.baidu.com/api/trans/vip/translate");
        var urlRequest:URLRequest = URLRequest(url: url!);
        urlRequest.httpMethod = "POST";
        urlRequest.httpBody = postString.data(using: String.Encoding.utf8);
        
        let session = URLSession.shared;
        let dataTask = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                //print(error.debugDescription);
            }
            else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: AnyObject];
                    let trans_result = json?["trans_result"] as? [[String: AnyObject]];
                    if (trans_result != nil) {
                        if (trans_result!.count > 0) {
                            completionHandler(trans_result![0]["dst"] as? String);
                        }
                    }
                } catch {
                    //print("翻译错误", error.description);
                }
            }
        })
        dataTask.resume();
    }
    
    public static func speech(q:String, language:String) -> Void {
        if player.isSpeaking { player.stopSpeaking(at: .immediate)}
        let u = AVSpeechUtterance(string: q)
        u.voice = AVSpeechSynthesisVoice(language: language)
        u.volume = 1.0;
        player.speak(u)
    }
    
    /// 判断目前字符串是不是正确的密码格式
    public static func isPassword(value: String?) -> Bool {
        if (value == nil) {
            return false;
        }
        
        if (value!.count < 6 || value!.count > 18) {
            return false;
        }
        
        let predicate = NSPredicate(format: " SELF MATCHES %@" , "^[A-Z0-9a-z]{6,18}")
        return predicate.evaluate(with: value);
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
    
}
