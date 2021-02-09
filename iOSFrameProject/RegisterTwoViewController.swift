//
//  RegisterTwoViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/1.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class RegisterTwoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    var passwordStr: String?            // 密码
    
    var phoneNumStr: String?            // 手机号
    
    var smsCodeStr: String?             // 验证码
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any addition
        // 初始化
        self.title = "创建昵称"
        self.registerBtn.layer.masksToBounds = true
        self.registerBtn.layer.cornerRadius = CORNER_SMART
        self.tableView.tableFooterView = UIView.init()
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        self.userNameTF.delegate = self
        self.userNameTF.addTarget(self, action: #selector(textFieldChanged(textField:)), for: .editingChanged)
        
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: right Bar Btn Item Click
    func rightBarBtnItemClick(sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: 注册按钮点击
    @IBAction func registerBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.userNameTF.text?.count == 0 {
            MBProgressHUD.show("请输入昵称", icon: nil, view: self.view)
            return
        }
        
        // 全局过滤
        // 禁止表情的输入
        self.userNameTF.text = NSString.disable_emoji(self.userNameTF.text)
//        self.userNameTF.text = tools.disable_emoji(self.userNameTF.text)
        
        var inputText = self.userNameTF.text! as NSString
        // 去掉头和尾的空格,和新的换行
        inputText = inputText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        
        if inputText == "" {
            self.userNameTF.text = ""
            MBProgressHUD.show("请输入有效字符", icon: nil, view: self.view)
            return
        }
        
        
        // 用户注册
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserRegister(nickName: inputText as String, password: self.passwordStr!, phoneNum: self.phoneNumStr!, sendCode: self.smsCodeStr!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            let userInfo = objectSuccess as! UserInfoModel
            
            // 注册成功，跳转登录界面
            MBProgressHUD.show("注册成功", icon: nil, view: self.view)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                // 跳转登录
                let viewControllers = self.navigationController?.viewControllers
                self.navigationController?.popToViewController(viewControllers![0], animated: true)
                
                // 传递数据到登录界面
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_UserRegister), object: userInfo)
            })
            
        }) { (error) in
        }
    }
    
    
    // MARK: 当输入框中内容改变时，调用
    @objc func textFieldChanged(textField: UITextField) {
        // 修改姓名
        if (textField.text?.count)! > WORDCOUNT_USERNAME {
            textField.text = CUTString(textStr: textField.text!, start: 0, length: WORDCOUNT_USERNAME)
        }
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
