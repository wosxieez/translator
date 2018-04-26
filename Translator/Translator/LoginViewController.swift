import UIKit

class LoginViewController: UIViewController
{
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var usernameDisplay: UITextField!;
    @IBOutlet weak var passwordDisplay: UITextField!;
    
    var codeTimer:DispatchSourceTimer!;
    var indicator:UIActivityIndicatorView!;
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        //        NotificationCenter.default.addObserver(self,
        //                                               selector: #selector(loginMessageAction),
        //                                               name: Notification.Name.init(rawValue: "loginMessage"),
        //                                               object: nil);
        
        // 添加一个Loading
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100));
        indicator.backgroundColor = UIColor.black;
        indicator.center = view.center;
        indicator.activityIndicatorViewStyle = .whiteLarge;
        indicator.layer.cornerRadius = 4;
        view.addSubview(indicator);
        
        let accountImage:UIImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24));
        accountImage.image = UIImage(named: "account");
        let accountView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44));
        accountView.addSubview(accountImage);
        usernameDisplay.leftView = accountView;
        usernameDisplay.leftViewMode  = UITextFieldViewMode.always;
        
        let passwordImage:UIImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 24, height: 24));
        passwordImage.image = UIImage(named: "password");
        let passwordView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44));
        passwordView.addSubview(passwordImage);
        passwordDisplay.leftView = passwordView;
        passwordDisplay.leftViewMode = UITextFieldViewMode.always;
        
        usernameDisplay.text = UserDefaults.standard.object(forKey: "username") as? String;
        passwordDisplay.text = UserDefaults.standard.object(forKey: "password") as? String;
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        navigationController?.setNavigationBarHidden(true, animated: animated);
        UIApplication.shared.statusBarStyle = .default;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func login() -> Void
    {
        indicator.startAnimating();
        // 开始登录吧
        //        let message:Message = Message();
        //        message.type = "appLogin";
        //        message.content = ["username": usernameDisplay.text, "password": passwordDisplay.text?.md5()];
        //        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "sendMessage"), object: message);
        
        
        AppService.getInstance().verifyUser(username: usernameDisplay.text,
                                            password: passwordDisplay.text,
                                            completionHandler: verifyUserHandler);
    }
    
    func verifyUserHandler(data:Data?, response:URLResponse?, error:Error?) -> Void
    {
        DispatchQueue.main.async {
            self.indicator.stopAnimating();
            
            if (data != nil)
            {
                let dataObject:[String: Any] = try! JSONSerialization.jsonObject(with: data!,
                                                                                 options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: Any];
                if (dataObject["resultCode"] as? String == "0")
                {
                    //记忆程序用户名密码
                    AppUtil.username = self.usernameDisplay.text;
                    AppUtil.password = self.passwordDisplay.text;
                    
                    // 将用户名密码信息保存到本地，供下次使用
                    UserDefaults.standard.set(AppUtil.username, forKey: "username");
                    UserDefaults.standard.set(AppUtil.password, forKey: "password");
                    UserDefaults.standard.synchronize();
                    
                    //登录成功 页面跳转
                    let mainViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController");
                    if (mainViewContoller != nil)
                    {
                        self.show(mainViewContoller!, sender: nil);
                    }
                }
                else
                {
                    Toast.show(message: dataObject["resultMsg"] as? String);
                }
            }
            else
            {
                // data == nil
                Toast.show(message: "登录失败");
            }
           
        }
    }
    
    //    @objc func loginMessageAction(notification:Notification) -> Void
    //    {
    //        indicator.stopAnimating();
    //
    //        let message:Message = notification.object as! Message;
    //        let content:[String: Any] = message.content as! [String: Any];
    //
    //        if ((content["resultCode"] as? String) == "0")
    //        {
    //            // 记忆程序用户名密码
    //            AppUtil.username = usernameDisplay.text;
    //            AppUtil.password = passwordDisplay.text;
    //
    //            // 将用户名密码信息保存到本地，供下次使用
    //            UserDefaults.standard.set(AppUtil.username, forKey: "username");
    //            UserDefaults.standard.set(AppUtil.password, forKey: "password");
    //            UserDefaults.standard.synchronize();
    //
    //            // 派发程序登录成功通知
    //            NotificationCenter.default.post(name: Notification.Name.init("appLogin"), object: nil);
    //
    //            // 登录成功 页面跳转
    //            let mainViewContoller = storyboard?.instantiateViewController(withIdentifier: "mainViewController");
    //            if (mainViewContoller != nil)
    //            {
    //                DispatchQueue.main.async {
    //                    self.show(mainViewContoller!, sender: nil);
    //                }
    //            }
    //        }
    //        else
    //        {
    //            // 登录失败 弹框提示原因
    //            DispatchQueue.main.async {
    //                Toast.show(message: content["resultMsg"] as? String);
    //            }
    //        }
    //    }
    
    @IBAction func resignResponder() -> Void
    {
        // 取消焦点
        usernameDisplay.resignFirstResponder();
        passwordDisplay.resignFirstResponder();
    }
    
}
