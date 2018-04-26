import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameDisplay: UITextField!
    @IBOutlet weak var passwordDisplay: UITextField!
    @IBOutlet weak var commitButton: UIButton!
    var indicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(registerSuccessAction), name: Notification.Name("registerSuccess"), object: nil)
        
        // 给确定按钮添加圆角
        commitButton.layer.cornerRadius = 22
        commitButton.backgroundColor = AppUtil.themeColor
        
        // 添加一个Loading
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        indicator.backgroundColor = UIColor.black
        indicator.center = view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.layer.cornerRadius = 4
        view.addSubview(indicator);
        
        // 添加用户名输入框 左视图 24|12 *******
        let usernameLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 44))
        usernameDisplay.leftView = usernameLeftView
        usernameDisplay.leftViewMode = .always
        let usernameIcon = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))
        usernameIcon.contentMode = .left
        usernameIcon.image = UIImage(named: "loginUsernameIcon")
        usernameLeftView.addSubview(usernameIcon)
        let usernameLine = UIView(frame: CGRect(x: 28, y: 11, width: 1, height: 22))
        usernameLine.backgroundColor = UIColor(red: 36/255, green: 171/255, blue: 1, alpha: 1)
        usernameLeftView.addSubview(usernameLine)
        
        // 添加密码输入框 左视图 24|12 *******
        let passwordLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 44))
        passwordDisplay.leftView = passwordLeftView
        passwordDisplay.leftViewMode = .always
        let passwordIcon = UIImageView(frame: CGRect(x: 0, y: 10, width: 24, height: 24))
        passwordIcon.contentMode = .left
        passwordIcon.image = UIImage(named: "loginPasswordIcon")
        passwordLeftView.addSubview(passwordIcon)
        let passwordLine = UIView(frame: CGRect(x: 28, y: 11, width: 1, height: 22))
        passwordLine.backgroundColor = UIColor(red: 36/255, green: 171/255, blue: 1, alpha: 1)
        passwordLeftView.addSubview(passwordLine)
        
        usernameDisplay.text = UserDefaults.standard.object(forKey: "username") as? String
        passwordDisplay.text = UserDefaults.standard.object(forKey: "password") as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default // 黑色字体状态栏
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func login() {
        view.endEditing(true)
        indicator.startAnimating()
        AppService.getInstance().verifyUser(username: usernameDisplay.text,
                                            password: passwordDisplay.text,
                                            completionHandler: verifyUserHandler);
    }
    
    func verifyUserHandler(data:Data?, response:URLResponse?, error:Error?) -> Void {
        DispatchQueue.main.async {
            self.indicator.stopAnimating();
            
            if data != nil {
                let dataObject:[String: Any] = try! JSONSerialization.jsonObject(with: data!,
                                                                                 options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String: Any];
                if dataObject["resultCode"] as? String == "0" {
                    // 将用户名密码信息保存到本地，供下次使用
                    AppUtil.username = self.usernameDisplay.text
                    AppUtil.password = self.passwordDisplay.text
                    AppUtil.sex = dataObject["sex"] as? String
                    UserDefaults.standard.set(AppUtil.username, forKey: "username")
                    UserDefaults.standard.set(AppUtil.password, forKey: "password")
                    
                    //登录成功 页面跳转
                    let mainViewContoller = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController");
                    if mainViewContoller != nil {
                        self.show(mainViewContoller!, sender: nil);
                    }
                    
                    NotificationCenter.default.post(name: AppNotification.AppLogin, object: nil)
                } else {
                    Toast.show(message: dataObject["resultMsg"] as? String);
                }
            } else {
                Toast.show(message: "登录失败");
            }
        }
    }
    
    @objc func registerSuccessAction() {
        //  有新用户注册成功
        usernameDisplay.text = AppUtil.uesrnameForRegister
        passwordDisplay.text = ""
    }
    
    
}
