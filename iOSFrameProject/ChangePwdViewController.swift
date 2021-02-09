//
//  ChangePwdViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/29.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit


/// 修改密码的控制器类型
///
/// - registerUser: 用户注册
/// - forgetPwd: 忘记密码
/// - userUpdate: 用户升级
public enum ChangePwdType: Int {
    case registerUser
    case forgetPwd
    case userUpdate
}


class ChangePwdViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    var defaultInputText: String?
    
    fileprivate var timer: Timer?
    
    var isShowOtherUserLoginBtn: Bool?          // 是否显示登录其他用户的按钮
    
    var changeType: ChangePwdType?
    
    fileprivate var runLoopValue = RUN_LOOP_VALUE
    
    fileprivate var stringSavePhoneNum: String?     // 发送验证码成功的手机号
    fileprivate var stringSavePhoneCode: String?    // 发送成功的验证码

    @IBOutlet weak var newPasswordTF: UITextField!
    
    @IBOutlet weak var phoneNumTF: UITextField!
    
    
    @IBOutlet weak var checkCodeTF: UITextField!
    
    
    @IBOutlet weak var checkCodeBtn: UILabel!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    
    @IBOutlet weak var loginOtherUserBtn: UIButton!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.loginOtherUserBtn.isHidden = true
        self.registerBtn.layer.masksToBounds = true
        self.registerBtn.layer.cornerRadius = CORNER_SMART
        UIView.hideHalfAlphaNoAction(withYesOrNo: true, andView: self.registerBtn)
//        tools.hideViewHalfAlphaNoAction(withYesOrNo: true, andView: self.registerBtn)
        self.checkCodeBtn.layer.masksToBounds = true
        self.checkCodeBtn.layer.cornerRadius = CORNER_SMART
        self.checkCodeBtn.isUserInteractionEnabled = true
        self.checkCodeBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(btnGetCheckCodeClick(gesture:))))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if self.defaultInputText == nil || self.defaultInputText == "" {
            self.phoneNumTF.placeholder = "请输入手机号"
        } else {
            self.phoneNumTF.isUserInteractionEnabled = false
            self.phoneNumTF.text = self.defaultInputText
        }
        // 是否显示其他用户登录的按钮
        if self.isShowOtherUserLoginBtn != nil && self.isShowOtherUserLoginBtn! {
            self.loginOtherUserBtn.isHidden = false
        }
        
        self.phoneNumTF.delegate = self
        self.phoneNumTF.keyboardType = .phonePad
        self.newPasswordTF.isSecureTextEntry = true
        self.newPasswordTF.delegate = self
        self.newPasswordTF.keyboardType = .namePhonePad
        if self.changeType == ChangePwdType.registerUser {
            self.newPasswordTF.placeholder = "请输入密码"
        }
        
        self.checkCodeTF.delegate = self
        self.checkCodeTF.keyboardType = .phonePad
        self.phoneNumTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        self.newPasswordTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        self.checkCodeTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        if self.changeType == ChangePwdType.forgetPwd || self.changeType == ChangePwdType.userUpdate {
            self.navigationItem.rightBarButtonItem?.title = "保存"
            self.registerBtn.isHidden = true
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // 设置tableView
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView.init()
        
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableViewDelegate 实现
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
        case self.newPasswordTF:
            self.navigationItem.rightBarButtonItem?.isEnabled = (nowString != "" && self.phoneNumTF.text != "" && self.checkCodeTF.text != "")
            UIView.hideHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.phoneNumTF.text != "" && self.checkCodeTF.text != ""), andView: self.registerBtn)
//            tools.hideViewHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.phoneNumTF.text != "" && self.checkCodeTF.text != ""), andView: self.registerBtn)
        case self.phoneNumTF:
            self.navigationItem.rightBarButtonItem?.isEnabled = (nowString != "" && self.newPasswordTF.text != "" && self.checkCodeTF.text != "")
            UIView.hideHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.newPasswordTF.text != "" && self.checkCodeTF.text != ""), andView: self.registerBtn)
//            tools.hideViewHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.newPasswordTF.text != "" && self.checkCodeTF.text != ""), andView: self.registerBtn)
        default:
            self.navigationItem.rightBarButtonItem?.isEnabled = (nowString != "" && self.phoneNumTF.text != "" && self.newPasswordTF.text != "")
            UIView.hideHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.phoneNumTF.text != "" && self.newPasswordTF.text != ""), andView: self.registerBtn)
//            tools.hideViewHalfAlphaNoAction(withYesOrNo: !(nowString != "" && self.phoneNumTF.text != "" && self.newPasswordTF.text != ""), andView: self.registerBtn)
        }
        
        return true
    }
    
    // MARK: 当输入框中内容改变时，调用
    @objc func textFieldChanged(textField: UITextField) {
        switch textField {
        case self.newPasswordTF:
            // 密码
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PASSWORD))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PASSWORD))
            if getStr != nil {
                textField.text = getStr
            }
        case self.phoneNumTF:
            // 手机号
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PHONE))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PHONE))
            if getStr != nil {
                textField.text = getStr
            }
        default:
            // 验证码
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_CHECK_CODE))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_CHECK_CODE))
            if getStr != nil {
                textField.text = getStr
            }
        }
    }
    
    
    
    // MARK: 获取验证码响应
    @objc func btnGetCheckCodeClick(gesture: UIGestureRecognizer) {
        // 判断是否输入手机号 或 邮箱为空
        if self.phoneNumTF.text == "" {
            MBProgressHUD.show("请输入手机号", icon: nil, view: self.view)
            return
        }
        
        // 判断手机号位数是否为11位
        if self.phoneNumTF.text?.count != WORDCOUNT_USER_PHONE {
            MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
            return
        }
        
        // 判断是否为手机号
        if !NSString.checkPhoneNumInput(withPhoneNum: self.phoneNumTF.text) {
            MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
            return
        }
        
        // 设置计时器
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunLoop(timer:)), userInfo: nil, repeats: true)
        self.timer?.fire()
        
        self.checkCodeBtn.isUserInteractionEnabled = false
        self.checkCodeBtn.backgroundColor = UIColor.lightGray
        
        
        self.view.endEditing(true)
        // 发送手机验证码
        let paramters = ["phoneNumber" : self.phoneNumTF.text!]
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserSenSmsCode, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            self.stringSavePhoneNum = self.phoneNumTF.text
            self.stringSavePhoneCode = responseObject as? String
            MBProgressHUD.showSuccess("发送验证码成功", to: self.view)
        }) { (error) in
            self.checkCodeBtn.text = "发送验证码"
            self.checkCodeBtn.isUserInteractionEnabled = true
            self.checkCodeBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.timer?.invalidate()
        }
    }
    
    
    // MARK: 下一步按钮点击
    @IBAction func registerBtnClick(_ sender: UIButton) {
        // 判断输入的手机号是否发送验证码
        if self.phoneNumTF.text != self.stringSavePhoneNum {
            MBProgressHUD.show(GLOBAL_CHECK_PHONE_NOT_SEND_TIP, icon: nil, view: self.view)
            return
        }
        
        // 判断验证码是否正确
        if self.stringSavePhoneCode != self.checkCodeTF.text {
            MBProgressHUD.show(GLOBAL_CHECK_PHONE_CHECK_CODE_TIP, icon: nil, view: self.view)
            return
        }
        
        // 判断密码位数
        if (self.newPasswordTF.text?.count)! < WORDCOUNT_USER_PASSWORD_MIN && (self.newPasswordTF.text?.count)! > WORDCOUNT_USER_PASSWORD {
            MBProgressHUD.show(GLOBAL_CHECK_PASSWORD_LENGTH_TIP, icon: nil, view: self.view)
            return
        }
        
        
        // 验证手机号是否已经注册
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserPhoneNumIsExist(phoneNum: self.stringSavePhoneNum!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            let isExist = objectSuccess as! Bool
            if isExist {
                // 存在
                MBProgressHUD.show("该手机号已注册，请登录", icon: nil, view: self.view)
            } else {
                // 不存在
                // 跳转到下一步
                let storyBoardMain = UIStoryboard.init(name: "Main", bundle: nil)
                let viewController = storyBoardMain.instantiateViewController(withIdentifier: "RegisterTwoView") as! RegisterTwoViewController
                viewController.passwordStr = self.newPasswordTF.text
                viewController.phoneNumStr = self.stringSavePhoneNum
                viewController.smsCodeStr = self.stringSavePhoneCode
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }) { (error) in
        }
    }
    
    
    // MARK: 其他账号登录方法响应
    @IBAction func loginOtherUserBtnClick(_ sender: UIButton) {
        APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    // MARK: 定时器循环方法
    @objc func timerRunLoop(timer: Timer) {
        self.runLoopValue = self.runLoopValue - 1
        var stringMessage = "(\(self.runLoopValue))后重新获取"
        
        if self.runLoopValue < 0 {
            self.runLoopValue = RUN_LOOP_VALUE
            
            stringMessage = "发送验证码"
            if self.phoneNumTF.text == self.stringSavePhoneNum {
                stringMessage = "重新获取验证码"
            }
            
            self.checkCodeBtn.isUserInteractionEnabled = true
            self.checkCodeBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            timer.invalidate()
        }
        
        self.checkCodeBtn.text = stringMessage
    }
    
    
    
    // 保存点击
    @IBAction func saveBtnClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        // 判断输入的手机号是否发送验证码
        if self.phoneNumTF.text != self.stringSavePhoneNum {
            MBProgressHUD.show(GLOBAL_CHECK_PHONE_NOT_SEND_TIP, icon: nil, view: self.view)
            return
        }
        
        // 判断密码位数
        if (self.newPasswordTF.text?.count)! < WORDCOUNT_USER_PASSWORD_MIN || (self.newPasswordTF.text?.count)! > WORDCOUNT_USER_PASSWORD {
            MBProgressHUD.show(GLOBAL_CHECK_PASSWORD_LENGTH_TIP, icon: nil, view: self.view)
            return
        }
        
        if self.changeType == ChangePwdType.forgetPwd {
            MBProgressHUD.showMessage("")
            UserBusiness.shareIntance.responseWebUpdateUserForgetPassword(phoneNumStr: self.phoneNumTF.text!, smsCodeStr: self.checkCodeTF.text!, newPassword: self.newPasswordTF.text!, responseSuccess: { (objectSuccess) in
                self.modifySuccessDoing(userInfo: objectSuccess as! UserInfoModel)
            }) {(error) in
            }
        } else if self.changeType == ChangePwdType.userUpdate {
            MBProgressHUD.showMessage("")
            UserBusiness.shareIntance.responseWebUpdateUserPhoneOrPassword(phoneNumStr: self.phoneNumTF.text!, smsCodeStr: self.checkCodeTF.text!, newPassword: self.newPasswordTF.text!, responseSuccess: { (objectSuccess) in
                self.modifySuccessDoing(userInfo: objectSuccess as! UserInfoModel)
            }, responseFailed: { (error) in
            })
        }
    }
    
    // MARK: 修改后成功后操作
    func modifySuccessDoing(userInfo: UserInfoModel) {
        // 修改成功
        self.view.endEditing(true)
        MBProgressHUD.hide()
        MBProgressHUD.showSuccess("保存成功")
        APP_DELEGATE.currentUserInfo = userInfo
//        // 发送更新用户信息的广播
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        
        // 返回
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    
    // MAR: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationStyle()
    }
    
    // view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
    }
    
    // MARK:  设置导航栏样式
    func setNavigationStyle() {
        //        self.automaticallyAdjustsScrollViewInsets = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
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

}
