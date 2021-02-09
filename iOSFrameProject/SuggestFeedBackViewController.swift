//
//  SuggestFeedBackViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class SuggestFeedBackViewController: UIViewController, UITextViewDelegate, UITableViewDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: UIPlaceHolderTextView!
    
    @IBOutlet weak var showRemaindLabel: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    fileprivate var isShowTip = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "意见反馈"
        self.showRemaindLabel.text = String(SUGGEST_INFO_LENGTH)
        self.submitBtn.layer.masksToBounds = true
        self.submitBtn.layer.cornerRadius = CORNER_NORMAL
        self.tableView.delegate = self
        
        // set text View
        self.textView.layer.masksToBounds = true
        self.textView.layer.cornerRadius = CORNER_NORMAL
        self.textView.delegate = self
        self.textView.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        self.textView.textColor = COLOR_DARK_GAY
        self.textView.placeholder = "请留下您的宝贵意见~"
        self.textView.placeholderColor = UIColor.lightGray
        
        
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
    
    
    // MARK: - UITextViewDelegate 代理方法的实现
    func textViewDidChange(_ textView: UITextView) {
        let textLength = textView.text.count
//        // 禁止表情的输入
//        let toBeString = textView.text
//        textView.text = tools.disable_emoji(toBeString)
        
        if textLength <= SUGGEST_INFO_LENGTH - 1 {
            self.showRemaindLabel.textColor = UIColorFromRGB(rgbValue: 0x7e7e7e)
        } else {
            if self.isShowTip {
                MBProgressHUD.show("超过的字符将不能被提交", icon: nil, view: self.view)
                self.isShowTip = false
            }
            self.showRemaindLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        self.showRemaindLabel.text = "\(SUGGEST_INFO_LENGTH - textLength)"
    }
    
    
    // MARK: 提交按钮点击
    @IBAction func submitBtnClick(_ sender: UIButton) {
        self.view.endEditing(true)
        // 判断是否为空
        if self.textView.text == "" {
            MBProgressHUD.show("请输入您的宝贵意见", icon: nil, view: self.view)
            return
        }
        
        //   截取过长的字符串
        if self.textView.text.count > SUGGEST_INFO_LENGTH - 1 {
            self.textView.text = CUTString(textStr: self.textView.text, start: 0, length: SUGGEST_INFO_LENGTH)
            myPrint(message: "\( self.textView.text)")
        }
        
        // 将反馈信息UTF8编码
        let sendMessageStr = AddressPickerDemo.stringAddEncode(with: self.textView.text)
        
        OtherBusiness.shareIntance.responseWebSendUserFeedBack(linkStr: "", content: sendMessageStr!, responseSuccess: { (objectSuccess) in
            // 反馈成功
            MBProgressHUD.showSuccess("反馈成功", to: self.view)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }) { (error) in
            MBProgressHUD.hide()
            MBProgressHUD.hide(for: self.view, animated: true)
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
