//
//  CommentBackView.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/17.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

protocol CommentBackDelegate {
    
    func evaluationResults(results: Bool)
}

class CommentBackView: UIView, UITextViewDelegate {
    
    var commentBackDelegate : CommentBackDelegate?
    
    @IBOutlet var commentContentTextView: UITextView!
    @IBOutlet var inputPromptLabel: UILabel!
    
    @IBOutlet weak var showRemainLabel: UILabel!
    
    @IBOutlet var contentLayoutConstraint: NSLayoutConstraint!
    
    var superiorOrganizationView: UIView?
    var commentBackView: CommentBackView?
    var photoId: String = ""
    var replyUserId: String = ""
    
    fileprivate var isShowTip = true
    
    override func draw(_ rect: CGRect) {
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
    }
    
    func initialFromXib() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CommentBackView", bundle: bundle)
        let contentView: UIView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentView.frame = bounds
        addSubview(contentView)
     
        commentContentTextView.delegate = self
    }
    
    func joinOrganization(view: UIView, commentBackView: CommentBackView, photoId: String, replyUserId: String) {
        
        self.superiorOrganizationView = view
        self.commentBackView = commentBackView
        self.photoId = photoId
        self.replyUserId = replyUserId
        self.superiorOrganizationView?.addSubview(self.commentBackView!)
        inputPromptLabel.isHidden = false
        commentContentTextView.text = ""
        self.showRemainLabel.text = String(WORDCOUNT_WATER_MARK_LONG)
        
        // 添加键盘出现和隐藏时的广播
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: CommentBackView.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: CommentBackView.keyboardWillHideNotification, object: nil)
        
        // 键盘弹出
        commentContentTextView.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        if text == "\n" {
//            
//            commentContentTextView.resignFirstResponder()
//        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text != "" {
            
            inputPromptLabel.isHidden = true
        }else {
            
            inputPromptLabel.isHidden = false
        }
        
        // 判断剩余字数
        let textLength = textView.text.count
        let Length = WORDCOUNT_WATER_MARK_LONG
        if textLength <= Length - 1 {
            self.showRemainLabel.textColor = COLOR_LIGHT_GAY
        } else {
            if self.isShowTip {
                MBProgressHUD.show("超过的字符将不能被提交", icon: nil, view: nil)
                self.isShowTip = false
            }
            self.showRemainLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        }
        self.showRemainLabel.text = "\(Length - textLength)"
    }
    
    // 关闭
    @IBAction func offView(_ sender: UIButton) {
        
        self.commentBackView!.removeFromSuperview()
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    // 键盘的出现
    @objc func keyBoardWillShow(_ notification: Notification) {
        
        // 获取userInfo
        let kbInfo = notification.userInfo
        // 获取键盘的size
        let kbRect = (kbInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        // 键盘的y偏移量
        let changeY = kbRect.origin.y - SCREEN_HEIGHT
        // 键盘弹出的时间
        let duration = kbInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            
            self.commentBackView!.transform = CGAffineTransform(translationX: 0, y: changeY)
        }
    }
    
    // 键盘的隐藏
    @objc func keyBoardWillHide(_ notification: Notification) {
        
        let kbInfo = notification.userInfo
        let kbRect = (kbInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        _ = kbRect.origin.y
        let duration = kbInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            
            self.commentBackView!.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    // 发表评论
    @IBAction func published(_ sender: UIButton) {
        
        if commentContentTextView.text!.removeAllSapce == "" {
            
            MBProgressHUD.show("发表内容不能为空", icon: nil, view: self.superiorOrganizationView)
            return
        }
        
        //   截取过长的字符串
        if commentContentTextView.text.count > WORDCOUNT_WATER_MARK_LONG - 1 {
            commentContentTextView.text = CUTString(textStr: commentContentTextView.text, start: 0, length: WORDCOUNT_WATER_MARK_LONG)
        }
        
        // 去除评论中连续的换行符和收尾换行符
        var contentStr = commentContentTextView.text! as NSString
        contentStr = contentStr.trimmingCharacters(in: CharacterSet.newlines) as NSString
        for i in 0..<WORDCOUNT_WATER_MARK_LONG {
            myPrint(message: "\(i)")
            contentStr = contentStr.replacingOccurrences(of: "\n\n\n", with: "\n\n") as NSString
        }
        
        getWebRphotoComment(replyUserId: replyUserId,
                            content: AddressPickerDemo.stringAddEncode(with: contentStr as String?))
    }
    
    // 添加评论
    func getWebRphotoComment(replyUserId: String, content: String) {
        MBProgressHUD.showMessage("", to: self.superiorOrganizationView)
        PhotoBusiness.shareIntance.responseWebphotoComment(replyUserId: replyUserId, photoId: photoId, content: content, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.superiorOrganizationView, animated: true)

            myPrint(message: objectSuccess)
            self.commentBackDelegate?.evaluationResults(results: true)
            self.offView(UIButton.init())
            MBProgressHUD.show("发表成功", icon: nil, view: nil)
        }) { (error) in
            
            self.commentBackDelegate?.evaluationResults(results: false)
            MBProgressHUD.hide(for: self.superiorOrganizationView, animated: true)
        }
    }
    
    // 设置输入提示
    func setInputPrompt(str: String) {
        
        inputPromptLabel.text = str
    }
}
