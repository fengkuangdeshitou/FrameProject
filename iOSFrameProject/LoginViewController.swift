//
//  LoginViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/29.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITextFieldDelegate, AppDelegateCustomDelegate {

    var userAvatarUrl: String?
    
    var isShowCancelButton: Bool?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var showBgImageView: UIImageView!
    
    
    @IBOutlet weak var showUserImageView: UIImageView!
    
    @IBOutlet weak var showInputView: UIView!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var userPasswordTF: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        APP_DELEGATE.customDelegate = self
//        self.cancelBtn.isHidden = (self.isShowCancelButton == nil || self.isShowCancelButton!) ? false : true
        self.cancelBtn.isHidden = false
        self.tableView.delegate = self
        self.showInputView.layer.masksToBounds = true
        self.showInputView.layer.cornerRadius = CORNER_NORMAL
        self.showInputView.layer.borderColor = UIColor.white.cgColor
        self.showInputView.layer.borderWidth = BORDER_WIDTH
        
        self.cancelBtn.layer.masksToBounds = true
        self.cancelBtn.layer.cornerRadius = CORNER_SMART
        
        self.loginBtn.layer.masksToBounds = true
        self.loginBtn.layer.cornerRadius = CORNER_SMART
        
        // 设置导航栏
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
        
        // 设置头像背景
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .dark))
        effectView.frame = self.showBgImageView.bounds
        effectView.width = SCREEN_WIDTH
        effectView.height = SCREEN_HEIGHT
        self.showBgImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + self.userAvatarUrl!), placeholderImage: #imageLiteral(resourceName: "applogo"))
        self.showBgImageView.contentMode = .scaleAspectFill
        self.showBgImageView.addSubview(effectView)
        
        // 设置用户头像
        self.showUserImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + self.userAvatarUrl!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        self.showUserImageView.layer.masksToBounds = true
        self.showUserImageView.layer.cornerRadius = self.showUserImageView.height / 2
        
        // set textField
        UIView.hideHalfAlphaNoAction(withYesOrNo: true, andView: self.loginBtn)
        self.userNameTF.delegate = self
        self.userNameTF.placeholder = "请输入昵称/手机号"
        self.userNameTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
            // 设置 placeholder 字体颜色
        let userNamePlaceholder = NSMutableAttributedString.init(string: self.userNameTF.placeholder!)
        userNamePlaceholder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(white: 1.0, alpha: 0.5), range: NSRange(location: 0, length: (self.userNameTF.placeholder?.count)!))
        self.userNameTF.attributedPlaceholder = userNamePlaceholder
        self.userNameTF.keyboardType = .default
        
        self.userPasswordTF.delegate = self
        self.userPasswordTF.placeholder = "请输入密码"
        self.userPasswordTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
            // 设置 placeholder 字体颜色
        let userPwdPlaceholder = NSMutableAttributedString.init(string: self.userPasswordTF.placeholder!)
        userPwdPlaceholder.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(white: 1.0, alpha: 0.5), range: NSRange(location: 0, length: (self.userPasswordTF.placeholder?.count)!))
        self.userPasswordTF.attributedPlaceholder = userPwdPlaceholder
        
        
        // 接收用户注册成功的消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserRegisterNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserRegister), object: nil)
        
    }
    
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserRegisterNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        if userInfo != nil {
            self.userNameTF.text = userInfo?.nickname
        }
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: scrollViewWillBeginDragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextfieldDelegate 代理方法的实现
    // MARK:
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)
        
        switch textField {
        case self.userNameTF:
            // 用户名
            UIView.hideHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.userPasswordTF.text != ""), andView: self.loginBtn)
//            tools.hideViewHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.userPasswordTF.text != ""), andView: self.loginBtn)
        default:
            // 密码
            UIView.hideHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.userNameTF.text != ""), andView: self.loginBtn)
//            tools.hideViewHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.userNameTF.text != ""), andView: self.loginBtn)
        }
        
        return true
    }
    
    // MARK: 当输入框中内容改变时，调用
    @objc func textFieldChanged(textField: UITextField) {
        switch textField {
        case self.userNameTF:
            // 姓名
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USERNAME))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USERNAME))
            if getStr != nil {
                textField.text = getStr
            }
        default:
            // 密码
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PASSWORD))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PASSWORD))
            if getStr != nil {
                textField.text = getStr
            }
        }
    }
    
    
    // MARK: - AppDelegateCustomDelegate
    // MARK: 微信第三方登录回调
    func weiXinThirdPartyLogin(resp: SendAuthResp) {
        myPrint(message: "errorCode:\(resp.errCode)")
        if resp.errCode == -4 {
            MBProgressHUD.show("用户拒绝授权", icon: nil, view: self.view)
            return
        }
        if resp.errCode == -2 {
            MBProgressHUD.show("用户取消登录", icon: nil, view: self.view)
            return
        }
        if resp.errCode != 0 {
            MBProgressHUD.show("登录失败", icon: nil, view: self.view)
            return
        }
        
        // 用户同意
        let paramter = ["appid" : WEIXIN_APPID,
                        "secret" : WEIXIN_APP_SECRET,
                        "code" : resp.code,
                        "grant_type" : "authorization_code",]
        
        MBProgressHUD.showMessage("")
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "https://api.weixin.qq.com", strApi: "/sns/oauth2/access_token", parameters: paramter as NSDictionary, resquestType: RequestType.GET, outRequestTime: 20, AESCPwd: nil, isTipInfo: true, responseProgress: { _ in}, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            
            let dataDict = objectSuccess as! NSDictionary
            
            if dataDict["errcode"] == nil {
                myPrint(message: "openID: \(String(describing: dataDict["openid"]!))")
                // 获取用户信息
                self.getWeixinThirdPartyLoginUserInfo(openId: String(describing: dataDict["openid"]!), accessToken: String(describing: dataDict["access_token"]!))
            } else {
                MBProgressHUD.showError("errmsg：\(String(describing: dataDict["errmsg"]!))", to: self.view)
            }
            
        }) { (error) in
            MBProgressHUD.hide()
        }
        
    }
    
    // MARK: 获取微信用户的个人信息
    func getWeixinThirdPartyLoginUserInfo(openId: String, accessToken: String) {
        // 用户同意
        let paramter = ["openid" : openId,
                        "access_token" : accessToken]
        
        MBProgressHUD.showMessage("")
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "https://api.weixin.qq.com", strApi: "/sns/userinfo", parameters: paramter as NSDictionary, resquestType: RequestType.GET, outRequestTime: 20, AESCPwd: nil, isTipInfo: true, responseProgress: { _ in}, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            
            let dataDict = objectSuccess as! NSDictionary
            
            if dataDict["errcode"] == nil {
                myPrint(message: "nickname: \(String(describing: dataDict["nickname"]!))")
            } else {
                MBProgressHUD.showError("errmsg：\(String(describing: dataDict["errmsg"]!))", to: self.view)
            }
            
        }) { (error) in
            MBProgressHUD.hide()
        }
    }
    
    
    // MARK: 登录按钮点击
    @IBAction func LoginBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserLogin(nickName: self.userNameTF.text!, password: self.userPasswordTF.text!, responseSuccess: { (responseSuccess) in
            let userInfo = responseSuccess as! UserInfoModel
            MBProgressHUD.hide()
            // 登录成功
            /// 1. 退出前一个用户登录(出问题：保存的accessToken有问题)
            //            WebDataDealFactory.shareIntance.responseWebExitCurrentUserLogin()
            
            // 2. 更新本地用户信息（封装接口中已更新）
            
            // 3. 更新当前用户信息
            APP_DELEGATE.currentUserInfo = userInfo
            
            // 4. 上传消息通知账户
            UMessage.addAlias((APP_DELEGATE.currentUserInfo?.id)!, type: UM_ALIAS_TYPE, response: { (object, error) in
                myPrint(message: "addAliasError: \(String(describing: error))")
            })
            
            
            // 4. 发送更新用户信息广播通知
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
            
            // 5. 提醒登录成功，并退出登录界面
//            MBProgressHUD.showSuccess("登录成功")
            
            // 判断每日第一次完成登录任务提醒
            if userInfo.finishLoginTask != nil && (userInfo.finishLoginTask)! {
                // ＋碳币提示
                MBProgressHUD.show("登录成功 +10枚碳币", icon: "login_carbon_big.png", view: nil)
            } else {
                MBProgressHUD.show("登录成功", icon: nil, view: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                self.dismiss(animated: true, completion: nil)
            })
            
            // 6. 获取碳币奖励规则列表
            OtherBusiness.shareIntance.responseWebGetTaskList(responseSuccess: { (objectSuccess) in
                APP_DELEGATE.carbonRuleList = objectSuccess as! [TaskModel]
            }) { (error) in
            }
        }) { (error) in
        }
        
    }

    
    // MARK: 忘记密码点击
    @IBAction func forgetBtnClick(_ sender: UIButton) {
        let storyBoardMain = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoardMain.instantiateViewController(withIdentifier: "ChangePwdView") as! ChangePwdViewController
        viewController.title = "忘记密码"
        viewController.changeType = ChangePwdType.forgetPwd
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: 取消按钮点击
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true) {
//            if self.isShowCancelButton != nil && self.isShowCancelButton == false {
//                // 退出到首页
//                let VC = APP_DELEGATE.jmTabBarViewController?.selectedViewController
//                if VC?.classForCoder == UINavigationController.classForCoder() {
//                    let nav = VC as! UINavigationController
//                    nav.popViewController(animated: false)
//                } else {
//                    VC?.navigationController?.popViewController(animated: false)
//                }
//                APP_DELEGATE.jmTabBarViewController?.selectedIndex = 0
//            }
        }
    }
    
    // MARK: 注册点击
    @IBAction func registerBtnClick(_ sender: UIButton) {
        let storyBoardMain = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoardMain.instantiateViewController(withIdentifier: "ChangePwdView") as! ChangePwdViewController
        viewController.title = "注册"
        viewController.changeType = ChangePwdType.registerUser
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 微信登录点击
    @IBAction func weixinLoginClick(_ sender: UIButton) {
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
        myPrint(message: "my_token:\(String(describing: accessToken))")
        //构造SendAuthReq结构体
        let req = SendAuthReq.init()
        req.scope = "snsapi_userinfo"
        req.state = "123Bacddihje" + NSDate.string(from: Date.init(), andFormatterString: "yyyyMMddHHmmss")
 
        //第三方向微信终端发送一个SendAuthReq消息结构
        WXApi.send(req)
    }
    
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 退出到首页
        let VC = APP_DELEGATE.jmTabBarViewController?.selectedViewController
        if VC is UINavigationController {
            let nav = VC as! UINavigationController
            nav.popToRootViewController(animated: false)
        } else {
            let nav = VC?.navigationController
            nav?.popToRootViewController(animated: false)
        }
        APP_DELEGATE.jmTabBarViewController?.selectedIndex = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UIGestureRecognizerDelegate 代理方法的实现
    // MARK:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }

}
