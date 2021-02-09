//
//  ChangeInfoViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/29.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit



/// 修改类型
///
/// - changeUserName: 修改昵称
/// - changeSpeek: 修改说说
/// - changeStopOnePhone: 修改手机号第一步 - 获取原手机号的验证码
/// - changeSaveNewPhone: 修改手机号第二步 - 获取新手机号验证码并保存
/// - changeEmail: 修改邮箱
/// - depositCash: 商家提现
public enum ChangeInfoType: Int {
    case changeUserName, changeSpeek, changeStopOnePhone, changeSaveNewPhone, changeEmail, depositCash
}


class ChangeInfoViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    
    var chageInfoType: ChangeInfoType?
    var defaultInputText: String?
    
    // 提现数据
    var depositCashMoney: Double?           // 提现金额
    var selectPayType: PayType?              // 提现类型
    
    
    fileprivate var timer: Timer?
    
    fileprivate var runLoopValue = RUN_LOOP_VALUE
    
    fileprivate var stringSavePhoneNum: String?     // 发送验证码成功的手机号
    fileprivate var stringSuccessCheckCode: String? // 验证码发送成功的返回验证码
    

    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var checkCodeTF: UITextField!
    
    @IBOutlet weak var checkCodeView: UIView!
    
    @IBOutlet weak var checkCodeBtn: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sureDepositCashBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.checkCodeBtn.layer.masksToBounds = true
        self.checkCodeBtn.layer.cornerRadius = CORNER_SMART
        self.checkCodeBtn.isUserInteractionEnabled = true
        self.checkCodeBtn.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(btnGetCheckCodeClick(gesture:))))
        self.inputTextField.placeholder = self.defaultInputText
        self.inputTextField.delegate = self
        self.inputTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        
        self.checkCodeTF.delegate = self
        self.checkCodeTF.keyboardType = .phonePad
        
        self.sureDepositCashBtn.layer.masksToBounds = true
        self.sureDepositCashBtn.layer.cornerRadius = CORNER_SMART
        
        // 设置tableView
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView.init()
        
        self.checkCodeView.isHidden = true
        switch self.chageInfoType {
        case .changeUserName?:
            // 修改姓名
            self.title = "修改昵称"
            if self.defaultInputText == "" {
                self.inputTextField.placeholder = "请输入昵称"
            } else {
                self.inputTextField.text = self.defaultInputText
            }
        case .changeSpeek?:
            // 修改说说
            self.title = "修改说说"
            if self.defaultInputText == "" {
                self.inputTextField.placeholder = "请输入说说"
            } else {
                self.inputTextField.text = self.defaultInputText
            }
           
        case .changeStopOnePhone?:
            // 修改手机号 第一步
            self.title = "验证原手机号"
            self.checkCodeView.isHidden = false
            self.inputTextField.keyboardType = .phonePad
            self.inputTextField.text = self.defaultInputText == "" ? "请输入手机号" : self.defaultInputText
            // 手机号＋*号
            if self.defaultInputText?.count == WORDCOUNT_USER_PHONE {
                self.inputTextField.text = AddressPickerDemo.stringPhoneNumEncodeStart(with: self.defaultInputText)
            }
            self.inputTextField.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem?.title = "下一步"
        case .changeSaveNewPhone?:
            // 修改手机号 第二步
            self.title = "新手机号"
            self.checkCodeView.isHidden = false
            self.inputTextField.keyboardType = .phonePad
            self.inputTextField.placeholder = "请输入新手机号"
        case .depositCash?:
            // 商家提现验证
            self.sureDepositCashBtn.isHidden = false
            self.title = "提现验证"
            self.checkCodeView.isHidden = false
            self.inputTextField.keyboardType = .phonePad
            self.inputTextField.text = self.defaultInputText == "" ? "请输入手机号" : self.defaultInputText
            // 手机号＋*号
            if self.defaultInputText?.count == WORDCOUNT_USER_PHONE {
                self.inputTextField.text = AddressPickerDemo.stringPhoneNumEncodeStart(with: self.defaultInputText)
            }
            self.inputTextField.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = nil
        default:
            // 修改邮箱
            self.title = "修改邮箱"
            self.checkCodeView.isHidden = false
            self.inputTextField.keyboardType = .emailAddress
            self.inputTextField.placeholder = self.defaultInputText == "" ? "请输入邮箱" : self.defaultInputText
        }
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextfieldDelegate 代理方法的实现
    // MARK:
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = textField.text! as NSString
        let nowString = textString.replacingCharacters(in: range, with: string)

        switch self.chageInfoType {
        case .changeUserName?:
            self.navigationItem.rightBarButtonItem?.isEnabled = !(nowString == APP_DELEGATE.currentUserInfo?.nickname || nowString == "")

        case .changeSpeek?:
            self.navigationItem.rightBarButtonItem?.isEnabled = !(nowString == APP_DELEGATE.currentUserInfo?.speak || nowString == "")
        case .changeStopOnePhone?, .changeSaveNewPhone?:    // 将两个case条件放在一起
            if textField == self.inputTextField {
                self.navigationItem.rightBarButtonItem?.isEnabled = (nowString != "" && self.checkCodeTF.text != "")
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = (self.inputTextField.text != "" && nowString != "")
            }

        default:
            self.navigationItem.rightBarButtonItem?.isEnabled = !(nowString == APP_DELEGATE.currentUserInfo?.mail || nowString == "")
        }

        return true
    }
    
    // MARK: 当输入框中内容改变时，调用
    @objc func textFieldChanged(textField: UITextField) {
        
        switch self.chageInfoType {
        case .changeUserName?:
            // 修改姓名
            if (textField.text?.count)! > WORDCOUNT_USERNAME {
                textField.text = CUTString(textStr: textField.text!, start: 0, length: WORDCOUNT_USERNAME)
            }
        case .changeSpeek?:
            // 修改说说
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_SPEAK))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_SPEAK))
            if getStr != nil {
                textField.text = getStr
            }
        case .changeStopOnePhone?, .changeSaveNewPhone?:
            // 修改手机号 第一步,第二步
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PHONE))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_PHONE))
            if getStr != nil {
                textField.text = getStr
                self.defaultInputText = getStr
            }
        default:
            // 修改邮箱
            let getStr = NSString.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_EMAIL))
//            let getStr = tools.getSubCharString(textField.text, andMaxLength: Int32(WORDCOUNT_USER_EMAIL))
            if getStr != nil {
                textField.text = getStr
            }
        }
    }
    
    
    // MARK: 保存用户信息点击
    @IBAction func saveInfoBtnClick(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        // 全局过滤
        // 禁止表情的输入
        self.inputTextField.text = NSString.disable_emoji(self.inputTextField.text)
//        self.inputTextField.text = tools.disable_emoji(self.inputTextField.text)
        
        var inputText = self.inputTextField.text! as NSString
        // 去掉头和尾的空格,和新的换行
        inputText = inputText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        
        if inputText == "" {
            self.inputTextField.text = ""
            MBProgressHUD.show("请输入有效字符", icon: nil, view: self.view)
            return
        }
        
        switch self.chageInfoType {
        case .changeUserName?:
            // 修改姓名
            MBProgressHUD.showMessage("")
            UserBusiness.shareIntance.responseWebUpdateUserNickName(nickName: inputText as String, responseSuccess: { (objectSuccess) in
                self.changeUserInfoSuccess(userInfo: objectSuccess as! UserInfoModel)
            }) { (error) in
            }
        case .changeSpeek?:
            // 修改说说
            MBProgressHUD.showMessage("")
            UserBusiness.shareIntance.responseWebUpdateUserSpeek(userSpeek: inputText as String, responseSuccess: { (objectSuccess) in
                self.changeUserInfoSuccess(userInfo: objectSuccess as! UserInfoModel)
            }) { (error) in
            }
        case .changeStopOnePhone?:
            // 修改手机号 第一步
            if self.checkCodeTF.text == self.stringSuccessCheckCode {
                // 验证码输入正确
                // 跳转手机验证第二步
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeInfoView") as! ChangeInfoViewController
                viewController.chageInfoType = .changeSaveNewPhone
                viewController.defaultInputText = APP_DELEGATE.currentUserInfo?.phoneNumber
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                MBProgressHUD.show("验证码不正确", icon: nil, view: self.view)
            }
            
        case .changeSaveNewPhone?:
            // 判断是否是当前发送验证码的手机号
            if self.inputTextField.text != self.stringSavePhoneNum {
                MBProgressHUD.show("该手机号未发送验证码", icon: nil, view: self.view)
                return
            }
            
            if self.checkCodeTF.text == self.stringSuccessCheckCode {
                // 修改手机号
                MBProgressHUD.showMessage("")
                UserBusiness.shareIntance.responseWebUpdateUserPhoneNum(phoneNum: self.defaultInputText!, smsCode: self.stringSuccessCheckCode!, responseSuccess: { (objectSuccess) in
                    self.changeUserInfoSuccess(userInfo: objectSuccess as! UserInfoModel)
                }) { (error) in
                }
            } else {
                MBProgressHUD.show("验证码不正确", icon: nil, view: self.view)
            }
        default:
            // 修改邮箱
            self.title = "修改邮箱"
            self.checkCodeView.isHidden = false
        }
    }
    
    
    // MARK: 确认提现响应
    @IBAction func sureDepositCashBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        // 验证手机号是否输入
        if self.checkCodeTF.text == "" {
            MBProgressHUD.show("请输入验证码", icon: nil, view: self.view)
            return
        }
        
        
        // 判断输入验证码是否正确
        OtherBusiness.shareIntance.responseWebVerfiyCodeVerify(phoneNumber: self.defaultInputText!, code: self.checkCodeTF.text!, responseSuccess: { (isEqual) in
            let isCodeEqual = isEqual as! Bool
            if isCodeEqual {
                self.depositCash()
            } else {
                MBProgressHUD.show("验证码不正确", icon: nil, view: self.view)
            }
        }) { (error) in
        }
    }
    
    
    
    
    // MARK: 修改信息成功后处理
    func changeUserInfoSuccess(userInfo: UserInfoModel) {
        // 修改成功
        self.view.endEditing(true)
        MBProgressHUD.hide()
        MBProgressHUD.showSuccess("保存成功")
        APP_DELEGATE.currentUserInfo = userInfo
        // 发送更新用户信息的广播
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        
        // 返回
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            for itemVC in (self.navigationController?.viewControllers)! {
                if itemVC.classForCoder == MineInformationViewController.classForCoder() {
                    self.navigationController?.popToViewController(itemVC, animated: true)
                }
            }
        })
    }
    
    
    // MARK: 获取验证码响应
    @objc func btnGetCheckCodeClick(gesture: UIGestureRecognizer) {
        self.view.endEditing(true)
        // 判断是否输入手机号 或 邮箱为空
        if self.defaultInputText == "" {
            switch self.chageInfoType {
            case .changeStopOnePhone?, .changeSaveNewPhone?:
                // 修改手机号
                MBProgressHUD.show("请输入手机号", icon: nil, view: self.view)
            default:
                // 修改邮箱
                MBProgressHUD.show("请输入邮箱", icon: nil, view: self.view)
            }
            return
        }
        
        switch self.chageInfoType {
        case .changeStopOnePhone?, .changeSaveNewPhone?, .depositCash?:
            // 手机号
            // 判断手机号位数是否为11位
            if self.defaultInputText?.count != WORDCOUNT_USER_PHONE {
                MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
                return
            }
            
            // 判断是否为手机号
            if !NSString.checkPhoneNumInput(withPhoneNum: self.defaultInputText) {
                MBProgressHUD.show("手机号格式不对", icon: nil, view: self.view)
                return
            }
        default:
            // 邮箱
            // 判断是否为邮箱格式
            if !NSString.checkEmailInput(withEmail: self.defaultInputText) {
                MBProgressHUD.show("邮箱格式不对", icon: nil, view: self.view)
                return
            }
        }
        
        
        // 设置计时器
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerRunLoop(timer:)), userInfo: nil, repeats: true)
        self.timer?.fire()
        
        self.checkCodeBtn.isUserInteractionEnabled = false
        self.checkCodeBtn.backgroundColor = UIColor.lightGray
        
        
        switch self.chageInfoType {
        case .changeStopOnePhone?, .changeSaveNewPhone?, .depositCash?:
            // 手机号
            // 发送手机验证码
            let paramters = ["phoneNumber" : self.defaultInputText]
            WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserSenSmsCode, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
                self.stringSuccessCheckCode = responseObject as? String
                self.stringSavePhoneNum = self.defaultInputText
                MBProgressHUD.showSuccess("发送验证码成功", to: self.view)
            }) { (error) in
                self.checkCodeBtn.text = "发送验证码"
                self.checkCodeBtn.isUserInteractionEnabled = true
                self.checkCodeBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
                self.timer?.invalidate()
            }
        default:
            // 邮箱
            MBProgressHUD.show("请输入邮箱", icon: nil, view: self.view)
        }
        
    }
    
    
    // MARK: 定时器循环方法
    @objc func timerRunLoop(timer: Timer) {
        self.runLoopValue = self.runLoopValue - 1
        var stringMessage = "(\(self.runLoopValue))后重新获取"
        
        if self.runLoopValue < 0 {
            self.runLoopValue = RUN_LOOP_VALUE
            
            stringMessage = "发送验证码"
            if self.inputTextField.text == self.stringSavePhoneNum {
                stringMessage = "重新获取验证码"
            }
            
            self.checkCodeBtn.isUserInteractionEnabled = true
            self.checkCodeBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            timer.invalidate()
        }
        
        self.checkCodeBtn.text = stringMessage
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
    
    // MARK: 提现请求
    func depositCash() {
        //提现请求
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebGetWithdraw(amount: self.depositCashMoney!, payType: (self.selectPayType?.rawValue)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            // 发送更新用户的商户信息的广播
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo_Merchant), object: nil)
            
            let viewController = DepositCashStatusViewController.init(nibName: "DepositCashStatusViewController", bundle: nil)
            viewController.isSuccess = true
            self.navigationController?.pushViewController(viewController, animated: true)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }
    }

}
