//
//  ChangeSpeekViewController.swift
//  ECOCityProject
//
//  Created by 陈帆 on 2017/12/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class ChangeSpeekViewController: UIViewController, UITextViewDelegate, UITableViewDelegate {
    
    var defaultInputText: String?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: UIPlaceHolderTextView!
    
    @IBOutlet weak var showRemaindLabel: UILabel!
    
    fileprivate var isShowTip = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "修改说说"
        self.tableView.delegate = self
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "保存", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        rightBarBtnItem.isEnabled = false
        
        // set text View
        self.textView.layer.masksToBounds = true
        self.textView.layer.cornerRadius = CORNER_NORMAL
        self.textView.delegate = self
        self.textView.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        self.textView.textColor = COLOR_DARK_GAY
        if self.defaultInputText == "" {
            self.textView.placeholder = "请输入说说"
        } else {
            self.textView.text = self.defaultInputText
        }
        self.showRemaindLabel.text = "\(WORDCOUNT_USER_SPEAK - self.textView.text.count)"
        self.textView.placeholderColor = UIColor.lightGray
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // 保存说说
        // 全局过滤
        // 禁止表情的输入
        self.textView.text = NSString.disable_emoji(self.textView.text)
//        self.textView.text = tools.disable_emoji(self.textView.text)
        
        var inputText = self.textView.text! as NSString
        // 去掉头和尾的空格,和新的换行
        inputText = inputText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        
        // 判断是否为空
        if inputText == "" {
            self.textView.text = ""
            MBProgressHUD.show("请输入有效字符", icon: nil, view: self.view)
            return
        }
        
        // 修改说说
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUpdateUserSpeek(userSpeek: inputText as String, responseSuccess: { (objectSuccess) in
            let userInfo = objectSuccess as! UserInfoModel
            
            // 修改成功
            self.view.endEditing(true)
            MBProgressHUD.hide()
            MBProgressHUD.showSuccess("保存成功")
            APP_DELEGATE.currentUserInfo = userInfo
            // 发送更新用户信息的广播
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
            
            // 返回
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }) {(error) in
        }
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextViewDelegate 代理方法的实现
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
        
        if textLength <= WORDCOUNT_USER_SPEAK {
            self.showRemaindLabel.textColor = UIColorFromRGB(rgbValue: 0x7e7e7e)
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            if self.isShowTip {
                MBProgressHUD.show("超过的字符将不能被保存", icon: nil, view: self.view)
                self.isShowTip = false
            }
            self.showRemaindLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        self.showRemaindLabel.text = "\(WORDCOUNT_USER_SPEAK - textLength)"
        
        // 判断是否为空
        if textView.text == "" || textView.text == self.defaultInputText {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
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
