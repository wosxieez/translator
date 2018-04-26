//
//  AppService.swift
//  TangdiTranslator
//
//  Created by coco on 23/09/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import Foundation

class AppService
{
    private static var instance:AppService?;
    
    public static func getInstance() -> AppService
    {
        if (instance == nil)
        {
            instance = AppService();
        }
        return instance!;
    }
    
    /// 验证用户
    ///
    /// - parameter username :注册的用户名
    /// - parameter password :注册的密码
    /// - parameter completionHandler :回调函数
    func verifyUser(username:String?, password:String?,
                    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> Void
    {
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/IDF001.do")!);
        var param = [String: String]();
        param["username"] = username;
        param["password"] = password?.md5();
        param["clientType"] = "APP_USER";
        
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 注册用户
    ///
    /// - parameter username :注册的用户名
    /// - parameter password :注册的密码
    /// - parameter completionHandler :回调函数
    func registerUser(username:String?, password:String?, mobile:String?, sex:String?,
                      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> Void
    {
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA001.do")!);
        var param = [String: String]();
        param["username"] = username;
        param["password"] = password?.md5();
        param["mobile"] = mobile;
        param["sex"] = sex;
        
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 推送验证码到手机
    ///
    /// - parameter phone :手机号码
    func pushMobileCode(tomobile:String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA007.do")!);
        var param:[String: String?] = [String: String?]();
        param["mobile"] = tomobile;
        
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 校验手机验证码
    ///
    /// - parameter mobilePhone :手机号码
    /// - parameter mobileCode :手机收到的验证码
    func verifyMobileCode(mobilePhone:String?, mobileCode:String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA008.do")!);
        var param:[String: String?] = [String: String?]();
        param["mobile"] = mobilePhone;
        param["verifyCode"] = mobileCode;
        
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 修改密码
    ///
    /// - parameter username : 用户名
    /// - parameter oldPassword : 旧密码
    /// - parameter newPassword : 新密码
    /// - parameter completionHandler : 回调函数
    func changePassword(username:String?, oldPassword:String?, newPassword:String?,
                        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var param:[String: String?] = [String: String?]();
        param["username"] = username;
        param["oldPassword"] = oldPassword?.md5();
        param["newPassword"] = newPassword?.md5();
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA002.do")!);
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 重置密码
    ///
    /// - parameter username : 用户名
    /// - parameter password : 新密码
    /// - parameter completionHandler : 回调函数
    func resetPassword(username:String?, password:String?,
                       completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        var param:[String: String?] = [String: String?]();
        param["username"] = username;
        param["password"] = password?.md5();
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted);
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8);
        let item = "REQ_MESSAGE=\(paramString!)";
        
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA010.do")!);
        request.httpMethod = "POST";
        request.httpBody = item.data(using: .utf8);
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    ///  检查用户是否已经存在
    ///
    /// - parameter username : 用户名(一般为用户手机号码)
    /// - parameter completionHandler : 回调函数
    func checkUser(username:String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param:[String: String?] = [:]
        param["mobile"] = username
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: "http://42.159.245.82:8181/tdTranslator/TA011.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    /// OCR 接口
    ///
    /// - parameter imageData : 识别的图像数据
    /// - parameter completionHandler : 回调函数
    func ocr(imageData:Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let url:URL? = URL(string: "https://api.cognitive.azure.cn/vision/v1.0/ocr?language=unk&detectOrientation=true");
        var request:URLRequest = URLRequest(url: url!);
        request.setValue("01bcfc891d9247469829137c82d68251", forHTTPHeaderField: "Ocp-Apim-Subscription-Key");
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type");
        request.httpBody = imageData;
        request.httpMethod = "POST";
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
}

/// String的md5扩展方法
extension String
{
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result =  UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String);
    }
    
}
