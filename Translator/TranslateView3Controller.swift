//
//  TranslateView3Controller.swift
//  Translator
//
//  Created by coco on 31/10/2017.
//  Copyright © 2017 coco. All rights reserved.
//

import UIKit
import AVFoundation;

class TranslateView3Controller: UIViewController, AVCapturePhotoCaptureDelegate
{
    
    // 语言切换的按钮
    @IBOutlet weak var sourceButton:UIButton!;
    @IBOutlet weak var targetButton:UIButton!;
    
    var isTranslateResult = false
    var videoDevice:AVCaptureDevice?
    var thisToast:Toast!
    var videoPreviewView:UIView! // 视频预览视图
    var videoPreviewImageView:UIImageView?
    var indicateView: CaptureOverView! // 指示层
    var controlView:UIView!
    var leftButton:UIButton!
    var centerButton:UIButton!
    var rightButton:UIButton!
    var captureSessionInitialized:Bool = false
    
    var captureSession:AVCaptureSession!
    let deviceOutput = AVCaptureStillImageOutput()
    let layer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var _isTorchOn:Bool = false;
    
    var isTorchOn:Bool
    {
        get
        {
            return _isTorchOn;
        }
        set
        {
            _isTorchOn = newValue;
            
            do
            {
                try videoDevice?.lockForConfiguration();
                if (_isTorchOn)
                {
                    if videoDevice != nil &&  videoDevice!.isTorchModeSupported(.on) {
                        videoDevice!.torchMode = .on;
                    }
                }
                else
                {
                    if videoDevice != nil &&  videoDevice!.isTorchModeSupported(.off) {
                        videoDevice!.torchMode = .off
                    }
                }
                videoDevice?.unlockForConfiguration();
            }
            catch
            {
                
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        thisToast = Toast(frame: CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.width * 3 / 4, height: 70));
        
        // 视频预览
        videoPreviewView = UIView();
        videoPreviewView.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1);
        view.addSubview(videoPreviewView);
        
        // 动态指示层
        indicateView = CaptureOverView();
        view.addSubview(indicateView);
        
        // 添加底部控制视图
        controlView = UIView();
        controlView.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1);
        view.addSubview(controlView);
        
        leftButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80));
        leftButton.isHidden = true;
        leftButton.addTarget(self, action: #selector(leftButtonHandler), for: .touchUpInside);
        controlView.addSubview(leftButton);
        
        centerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80));
        centerButton.setImage(UIImage(named: "capture1"), for: .normal);
        centerButton.addTarget(self, action: #selector(test), for: .touchUpInside);
        controlView.addSubview(centerButton);
        
        rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80));
        rightButton.setImage(UIImage(named: "torchon"), for: .normal);
        rightButton.addTarget(self, action: #selector(rightButtonHandler), for: .touchUpInside);
        controlView.addSubview(rightButton);
        
        // 第一开始请求权限
        AVCaptureDevice.requestAccess(for: .video, completionHandler: requestAccessCompleteHandler);
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews();
        
        videoPreviewView.frame = CGRect(x: 0, y: topLayoutGuide.length + 60,
                                        width: view.bounds.width,
                                        height: view.bounds.height - bottomLayoutGuide.length - topLayoutGuide.length - 60);
        
        indicateView.frame = CGRect(x: 0, y: topLayoutGuide.length + 60,
                                    width: view.bounds.width,
                                    height: view.bounds.height - bottomLayoutGuide.length - topLayoutGuide.length - 160);
        
        controlView.frame = CGRect(x: 0,
                                   y: view.bounds.height - 100 - bottomLayoutGuide.length,
                                   width: view.bounds.width,
                                   height: 100);
        
        leftButton.center = CGPoint(x: controlView.bounds.width/4 - 30, y: controlView.bounds.height/2);
        centerButton.center = CGPoint(x: controlView.bounds.width/2, y: controlView.bounds.height/2);
        rightButton.center = CGPoint(x: controlView.bounds.width * 3/4 + 30, y: controlView.bounds.height/2);
    }
    
    @objc func test() -> Void
    {
        if (indicateView.isIndicate)
        {
            // 当前是指示模式 -> 进入拍照模式
            cameraCapture();
        }
        else
        {
            // 当前是裁剪模式  开始OCR识别
            if (indicateView.beganPoint != nil &&
                indicateView.endPoint != nil)
            {
                let xScale:CGFloat = videoPreviewImageView!.image!.size.width / videoPreviewImageView!.bounds.width;
                let yScale:CGFloat = videoPreviewImageView!.image!.size.height / videoPreviewImageView!.bounds.height;
                let newRect:CGRect = CGRect(x: indicateView.beganPoint!.x * xScale,
                                            y: indicateView.beganPoint!.y * yScale,
                                            width: (indicateView.endPoint!.x - indicateView.beganPoint!.x) * xScale,
                                            height: (indicateView.endPoint!.y - indicateView.beganPoint!.y) * yScale);
                let cropCGImage:CGImage? = videoPreviewImageView?.image?.cgImage?.cropping(to: newRect);
                let cropImage:UIImage = UIImage(cgImage: cropCGImage!);
                let cropImageData:Data? = UIImageJPEGRepresentation(cropImage, 1);
                thisToast.open(message: "正在识别", delayCloseTime: -1);
                AppService.getInstance().ocr(imageData: cropImageData!, completionHandler: ocrCompletionHandler);
            }
            else
            {
                let imageData:Data? = UIImageJPEGRepresentation(videoPreviewImageView!.image!, 1);
                thisToast.open(message: "正在识别", delayCloseTime: -1);
                AppService.getInstance().ocr(imageData: imageData!, completionHandler: ocrCompletionHandler);
            }
        }
    }
    
    @objc func leftButtonHandler() -> Void
    {
        if (indicateView.isIndicate)
        {
            
        }
        else
        {
            // 裁剪图片模式 点击左键 重新拍照 移除拍照的静态图
            videoPreviewImageView?.removeFromSuperview();
            indicateView.isIndicate = true;
            centerButton.setImage(UIImage(named: "capture1"), for: .normal);
            leftButton.isHidden = true;
            rightButton.setImage(UIImage(named: "torchon"), for: .normal);
        }
    }
    
    @objc func rightButtonHandler() -> Void
    {
        if (indicateView.isIndicate)
        {
            isTorchOn = !isTorchOn;
            if (isTorchOn)
            {
                rightButton.setImage(UIImage(named: "torchoff"), for: .normal);
            }
            else
            {
                rightButton.setImage(UIImage(named: "torchon"), for: .normal);
            }
        }
        else
        {
            // 裁剪图片模式
            indicateView.beganPoint = nil;
            indicateView.endPoint = nil;
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
        navigationController?.navigationBar.shadowImage = UIImage();
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
        
        if (captureSessionInitialized && captureSession != nil && !captureSession.isRunning)
        {
            captureSession.startRunning();
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated);
        
        if (captureSession != nil && captureSession.isRunning)
        {
            captureSession.stopRunning();
        }
    }
    
    func requestAccessCompleteHandler(permission:Bool) -> Void
    {
        if (permission)
        {
            // 开始查找捕获设备
            videoDevice = AVCaptureDevice.default(for: .video);
            
            if (videoDevice != nil)
            {
                let deviceInput:AVCaptureDeviceInput? = try? AVCaptureDeviceInput(device: videoDevice!);
                captureSession = AVCaptureSession();
                captureSession.sessionPreset = .high; // 设置捕捉的数据格式和质量
                if (captureSession.canAddInput(deviceInput!))
                {
                    captureSession.addInput(deviceInput!);
                }
                
                if (captureSession.canAddOutput(deviceOutput))
                {
                    captureSession.addOutput(deviceOutput);
                }
                else
                {
                }
                
                // 产生一个实时预览层
                DispatchQueue.main.async {
                    self.layer.frame = self.videoPreviewView.bounds;
                    self.layer.session = self.captureSession;
                    self.layer.videoGravity = AVLayerVideoGravity.resize;
                    self.videoPreviewView.layer.addSublayer(self.layer);
                    self.captureSession.startRunning();
                    
                    self.captureSessionInitialized = true;
                }
            }
            else
            {
            }
        }
        else
        {
        }
    }
    
    @IBAction func switchButton() -> Void
    {
        let language = AppUtil.sourceLanguage;
        AppUtil.sourceLanguage = AppUtil.targetLanguage;
        AppUtil.targetLanguage = language;
        sourceButton.setTitle(AppUtil.sourceLanguage.name, for: .normal);
        targetButton.setTitle(AppUtil.targetLanguage.name, for: .normal);
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews();
    }
    
    func cameraCapture() -> Void
    {
        if captureSession != nil && captureSession.isRunning {
            if let connection = deviceOutput.connection(with: .video) {
                deviceOutput.captureStillImageAsynchronously(from: connection, completionHandler: { (buffer, error) in
                    if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!) {
                        // 拍照成功退出指示模式
                        self.videoPreviewImageView = UIImageView(frame: self.videoPreviewView.bounds);
                        let image:UIImage = UIImage(data: imageData)!;
                        let image2:UIImage = self.fixOrientation(image: image);
                        self.isTorchOn = false; // 关闭闪光灯
                        self.videoPreviewImageView!.image = image2;
                        self.videoPreviewView.addSubview(self.videoPreviewImageView!);
                        self.indicateView.isIndicate = false;
                        self.leftButton.setImage(UIImage.init(named: "again"), for: .normal);
                        self.leftButton.isHidden = false;
                        self.centerButton.setImage(UIImage.init(named: "capture2"), for: .normal);
                        self.rightButton.setImage(UIImage.init(named: "smear"), for: .normal);
                    }
                })
            }
        }
    }
    
    @available(iOS 10.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?)
    {
        let imageData:Data? = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!,
                                                                               previewPhotoSampleBuffer: previewPhotoSampleBuffer);
        if (imageData != nil)
        {
            // 拍照成功退出指示模式
            videoPreviewImageView = UIImageView(frame: videoPreviewView.bounds);
            let image:UIImage = UIImage(data: imageData!)!;
            let image2:UIImage = fixOrientation(image: image);
            isTorchOn = false; // 关闭闪光灯
            videoPreviewImageView!.image = image2;
            videoPreviewView.addSubview(videoPreviewImageView!);
            indicateView.isIndicate = false;
            leftButton.setImage(UIImage.init(named: "again"), for: .normal);
            leftButton.isHidden = false;
            centerButton.setImage(UIImage.init(named: "capture2"), for: .normal);
            rightButton.setImage(UIImage.init(named: "smear"), for: .normal);
        }
        else
        {
        }
    }
    
    var sourceStr:String!;
    
    func ocrCompletionHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        // 关闭默认的提示
        DispatchQueue.main.async {
            self.thisToast.close();
            
            let result = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
            let resultDic:[String: AnyObject]? = result as? [String: AnyObject];
            
            var str:String;
            
            if (resultDic != nil)
            {
                str = self.extractStringFromDictionary(resultDic!);
                if (str.count > 0)
                {
                    self.sourceStr = str;
                    AppService.getInstance().translate(q: str, from: AppUtil.sourceLanguage.translateCode, to: AppUtil.targetLanguage.translateCode, completionHandler: self.translateCompletion)
                }
                else
                {
                    Toast.show(message: "无法识别");
                }
            }
            else
            {
                Toast.show(message: "无法识别");
            }
        }
    }
    
    func extractStringFromDictionary(_ dictionary: [String:AnyObject]) -> String
    {
        let stringArray = extractStringsFromDictionary(dictionary)
        
        let reducedArray = stringArray.enumerated().reduce("", {
            $0 + $1.element + ($1.offset < stringArray.endIndex-1 ? " " : "")
        }
        )
        return reducedArray
    }
    
    func extractStringsFromDictionary(_ dictionary: [String : AnyObject]) -> [String]
    {
        if dictionary["regions"] != nil {
            var extractedText : String = ""
            
            if let regionsz = dictionary["regions"] as? [AnyObject]{
                for reigons1 in regionsz
                {
                    if let reigons = reigons1 as? [String:AnyObject]
                    {
                        let lines = reigons["lines"] as! NSArray
                        for words in lines{
                            if let wordsArr = words as? [String:AnyObject]{
                                if let dictionaryValue = wordsArr["words"] as? [AnyObject]{
                                    for a in dictionaryValue {
                                        if let z = a as? [String : String]{
                                            extractedText += z["text"]! + " "
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            // Get text from words
            return [extractedText]
        }
        else
        {
            return [""];
        }
    }
    
    @IBAction func closeTragetView() -> Void
    {
        
    }
    
    func fixOrientation(image : UIImage) -> UIImage
    {
        if image.imageOrientation == .up
        {
            return image
        }
        var transform = CGAffineTransform.identity
        switch image.imageOrientation
        {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            
        default:
            break
        }
        
        switch image.imageOrientation
        {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        switch image.imageOrientation
        {
        case .left,.leftMirrored,.rightMirrored,.right:
            ctx?.draw(image.cgImage!, in: CGRect(x :0,y:0,width:image.size.height,height: image.size.width))
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x :0,y:0,width:image.size.width,height: image.size.height))
        }
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        return img
    }
    
    func translateCompletion(data:Data?) {
        if data != nil {
            let xmlParser = XMLParser(data: data!)
            xmlParser.delegate = self
            xmlParser.parse()
        } else {
        }
    }
    
}

extension TranslateView3Controller: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "string" {
            isTranslateResult = true
        } else {
            isTranslateResult = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isTranslateResult {
            DispatchQueue.main.async {
                let resultStr:String = self.sourceStr + "\n\n" + string;
                let alert:UIAlertController = UIAlertController(title: "识别结果", message: resultStr, preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil));
                self.present(alert, animated: true, completion: nil);
            }
        }
    }
    
}

