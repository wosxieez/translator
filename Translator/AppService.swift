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
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/IDF001.do")!);
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
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA001.do")!);
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
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA007.do")!);
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
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA008.do")!);
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
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA002.do")!);
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
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA010.do")!);
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
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA011.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    ///  获取程序秘钥
    ///
    /// - parameter type : 秘钥类型
    /// - parameter completionHandler : 回调函数
    func getAppKey(type:String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param:[String: String?] = [:]
        param["type"] = type
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/KEY001.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    ///  绑定设备
    ///
    /// - parameter deviceCode : 绑定码
    /// - parameter completionHandler : 回调函数
    func bindDevice(deviceCode:String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param = [String: String?]()
        param["username"] = AppUtil.username
        param["verifyCodes"] = deviceCode
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA003.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    ///  查询绑定的设备列表
    ///
    /// - parameter completionHandler : 回调函数
    func queryDeviceList(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param = [String: String?]()
        param["username"] = AppUtil.username
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA004.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    /// 查询设备的明细
    ///
    /// - Parameters:
    ///   - deviceNo: 设备编号
    ///   - completionHandler: 回调函数
    func queryDeviceDetail(deviceNo: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param = [String: String?]()
        param["username"] = AppUtil.username
        param["deviceNo"] = deviceNo
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA009.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    /// 删除设备
    ///
    /// - Parameters:
    ///   - deviceNo: 设备编号
    ///   - completionHandler: 回调函数
    func deleteDevice(deviceNo: String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void {
        var param = [String: String?]()
        param["username"] = AppUtil.username
        param["deviceId"] = deviceNo
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TA014.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    /// 查询设备最新的版本
    ///
    /// - Parameters:
    ///   - deviceNo: 设备号
    ///   - completionHandler: 回调函数
    func queryDeviceLatestVersion(deviceNo: String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var param = [String: String?]()
        param["deviceId"] = deviceNo
        let paramData = try? JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        let paramString = String(data: paramData!, encoding: String.Encoding.utf8)
        let item = "REQ_MESSAGE=\(paramString!)"
        
        var request:URLRequest = URLRequest(url: URL(string: AppUtil.httpServerURL + "tdTranslator/TR0002.do")!)
        request.httpMethod = "POST"
        request.httpBody = item.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    /// OCR 接口
    //
    /// - parameter imageData : 识别的图像数据
    /// - parameter completionHandler : 回调函数
    func ocr(imageData:Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Void
    {
        let url:URL? = URL(string: "https://api.cognitive.azure.cn/vision/v1.0/ocr?language=unk&detectOrientation=true");
        var request:URLRequest = URLRequest(url: url!);
        request.setValue(AppUtil.appOcrKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key");
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type");
        request.httpBody = imageData;
        request.httpMethod = "POST";
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
        dataTask.resume();
    }
    
    /// 微软翻译接口
    func translate(q: String?, from: String?, to: String?, completionHandler: @escaping (Data?) -> Void) {
        guard q != nil && from != nil && to != nil else { return }
        if let text = q?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: "https://api.microsofttranslator.com/V2/Http.svc/Translate?from=" + from! + "&to=" + to! + "&text=" + text)
            var request:URLRequest = URLRequest(url: url!)
            request.setValue(AppUtil.appTranslateKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.httpMethod = "GET"
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                completionHandler(data)
            }
            dataTask.resume()
        }
    }
    
    /// 更新设备设置
    ///
    /// - Parameters:
    ///   - devNo: 设备号
    ///   - lanFrom: 源语言
    ///   - lanTo: 目标语言
    ///   - completionHandler: 回调函数
    func updateDeviceSetting(devNo: String, lanFrom: String?, lanTo: String?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var httpBody = ["devNo": devNo]
        if let lanFrom = lanFrom { httpBody["lanFrom"] = lanFrom }
        if let lanTo = lanTo { httpBody["lanTo"] = lanTo }
        
        if let httpData = try? JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted) {
            if let url = URL(string: AppUtil.httpServerURL + "tdTranslator/deviceSet/updateSetting.do") {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = httpData
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
            }
        }
    }
    
    ///
    /// 更新App设置
    ///
    /// - Parameters:
    ///     - username: app用户名
    ///     - appLanguage app语言
    ///
    func updateAppSetting(username: String?, appLanguage: String, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        guard username != nil else { return }
        
        let httpBody = ["username": username, "systemLan": appLanguage]
        if let httpData = try? JSONSerialization.data(withJSONObject: httpBody, options: .prettyPrinted) {
            if let url = URL(string: AppUtil.httpServerURL + "tdTranslator/appUser/updateSetting.do") {
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = httpData
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                if completionHandler != nil {
                    URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler!).resume()
                } else {
                    URLSession.shared.dataTask(with: urlRequest).resume()
                }
            }
        }
    }
    
    ///
    /// 获取支持的语言列表
    /// - Parameters:
    ///   - appLanguage: app语言
    ///
    func getLanguageList(appLanguage: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if let url = URL(string: AppUtil.httpServerURL + "tdTranslator/appUser/getLanList.do?lan=" + appLanguage) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
        }
    }
    
    /// 注册设备远程通知token
    ///
    /// - Parameters:
    ///   - token: 设备token
    ///   - completionHandler: 回调函数
    func registerDeviceToken(token: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var urlString = "http://hefeixiaomu.com/baiguotong/addToken.php?token=" + token
        
        #if DEBUG
        urlString = "http://hefeixiaomu.com/baiguotong/addToken2.php?token=" + token
        #endif
        
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            URLSession.shared.dataTask(with: urlRequest, completionHandler: completionHandler).resume()
        }
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
        result.deallocate()
        
        return String(format: hash as String);
    }
    
}
