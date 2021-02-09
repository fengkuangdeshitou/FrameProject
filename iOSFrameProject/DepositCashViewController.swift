//
//  DepositCashViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/3.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit


class DepositCashViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {
    var merchant: MerchantModel?

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var inputMoneyTextField: UITextField!
    
    @IBOutlet weak var payWayOneView: UIView!
    
    @IBOutlet weak var payWayOneSubTitleLabel: UILabel!
    
    @IBOutlet weak var payOneSelectImageView: UIImageView!
    
    @IBOutlet weak var payWayTwoView: UIView!
    
    @IBOutlet weak var payWayTwoSubTitleLabel: UILabel!
    
    @IBOutlet weak var payTwoSelectImageView: UIImageView!
    
    // 提现到账时间提醒
    @IBOutlet weak var depositMoneyTimeTapLB: UILabel!
    
    @IBOutlet weak var linkServiceBtn: UIButton!
    
    @IBOutlet weak var sureDepositBtn: UIButton!
    
    
    @IBOutlet weak var payOneViewHeightContrait: NSLayoutConstraint!
    
    @IBOutlet weak var payTwoViewHeightContrait: NSLayoutConstraint!
    
    
    fileprivate var selectPayType: PayType = PayType.weiXinPay // 默认选择支付方式
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "余额提现"
        
        //显示下划线
        let attribtDic = [NSAttributedString.Key.underlineStyle: NSNumber.init(value: NSUnderlineStyle.single.rawValue)]
        let attribtStr = NSMutableAttributedString.init(string: "联系客服", attributes: attribtDic)
        self.linkServiceBtn.titleLabel?.attributedText = attribtStr
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set textField
        self.inputMoneyTextField.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.inputMoneyTextField.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.inputMoneyTextField.delegate = self
        self.inputMoneyTextField.font = UIFont.boldSystemFont(ofSize: FONT_BIG_SIZE)
        self.inputMoneyTextField.keyboardType = UIKeyboardType.decimalPad
        
        // tableView
        self.tableView.tableFooterView = UIView.init()
        self.tableView.delegate = self
        
        // setTableHeaderView
        self.setTableHeaderView()
        
    }
    
    // MARK: left Bar Btn Item Click
    @objc    func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: setTableHeaderView
    func setTableHeaderView() {
        // 设置支付账号名称
        if self.merchant?.aliAccount != "" && self.merchant?.wxAccount == "" {
            self.payWayOneView.isHidden = true
            self.payOneViewHeightContrait.constant = 0
            self.payWayTwoSubTitleLabel.text = self.merchant?.aliAccount
            self.payTwoSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
            self.selectPayType = PayType.alipay
        } else if self.merchant?.wxAccount != "" && self.merchant?.aliAccount == "" {
            self.payWayTwoView.isHidden = true
            self.payTwoViewHeightContrait.constant = 0
            self.payWayOneSubTitleLabel.text = self.merchant?.wxAccount
            self.payOneSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
            self.selectPayType = PayType.weiXinPay
        } else {
            self.payOneSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
            self.selectPayType = PayType.weiXinPay
            self.payWayOneSubTitleLabel.text = self.merchant?.wxAccount
            self.payWayTwoSubTitleLabel.text = self.merchant?.aliAccount
        }
        
        // 设置余额
        self.inputMoneyTextField.placeholder = "可提现金额\(String(format: "%.2f", (self.merchant?.amount)!))元"
        
        // 设置到账时间
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: FONT_SMART_SIZE, color: COLOR_CARBON_COIN, action: {})
        let strText = "预计<help><link><FontMax>1~2个工作日内</FontMax></link></help>到账" as NSString
        self.depositMoneyTimeTapLB.attributedText = strText.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        self.sureDepositBtn.layer.masksToBounds = true
        self.sureDepositBtn.layer.cornerRadius = CORNER_NORMAL
        
        // 设置支付方式点击事件
        self.payWayOneView.isUserInteractionEnabled = true
        self.payWayOneView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.payOneSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
            self.payTwoSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_unselect.png")
            self.selectPayType = PayType.weiXinPay
        }))
        self.payWayTwoView.isUserInteractionEnabled = true
        self.payWayTwoView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.payOneSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_unselect.png")
            self.payTwoSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
            self.selectPayType = PayType.alipay
        }))
    }
    
    
    // MARK: - UITableViewDelegate
    // MARK: scrollViewWillBeginDragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.inputMoneyTextField.resignFirstResponder()
    }
    
    
    // MARK: - UITextFieldDelegate
    // MARK: shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = textField.text! as NSString
        var nowString = textString.replacingCharacters(in: range, with: string)
        
        // 统计总金额
        if nowString.hasPrefix(".") {
            nowString = "0"
            textField.text = nowString
        } else if nowString.hasSuffix(".") {
            nowString.insert("0", at: nowString.endIndex)
        } else if nowString == "" {
            nowString = "0"
        }
        
        if !NSString.isOnlyhasNumberAndpoint(with: string, andFormat: ".0123456789") {
            return false
        }
        
        // 不能出现第二个小数点
        if textString.contains(".") && string == "." {
            MBProgressHUD.show("不能输入多个小数点", icon: nil, view: self.view)
            return false
        }
        
        
        // 限制小数位数
        if textString.contains(".") {
            let ran = textString.range(of: ".")
            if  range.location - ran.location > 2 {
                MBProgressHUD.show("只能输入到小数点后2位", icon: nil, view: self.view)
                return false
            }
        }
        
        if Double(nowString)! > Double(WORDCOUNT_ADD_COUPON_FULLMONEY_MAX) {
            MBProgressHUD.show("提现金额最高为10万元" , icon: nil, view: self.view)
            return false
        }
        
        return true
    }
    
    
    // MARK: 全部提现点击
    @IBAction func allMoneyDepositBtnClick(_ sender: UIButton) {
        self.inputMoneyTextField.text = String(format: "%.2f", (self.merchant?.amount)!)
    }
    
    // MARK: 联系客服点击
    @IBAction func linkServiceBtnClick(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL.init(string: "tel://029-82245879")! as URL)
    }
    
    // 确认提现点击
    @IBAction func sureDepositBtnClick(_ sender: UIButton) {
        // 是否输入提现金额
        if self.inputMoneyTextField.text == "" || self.inputMoneyTextField.text == "" {
            MBProgressHUD.show("请输入提现金额", icon: nil, view: self.view)
            return
        }
        
        // 判断钱包余额
        if Double((self.inputMoneyTextField.text)!)! < 1.0 {
            MBProgressHUD.show("提现金额最小1元", icon: nil, view: self.view)
            return
        }
        
        // 提现金额是否合理
        if Double((self.inputMoneyTextField.text)!)! > (self.merchant?.amount)! {
            MBProgressHUD.show("提现金额不能大于余额", icon: nil, view: self.view)
            return
        }
        
        // 验证商家今日是否可以提现
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebTodayCanWithDraw(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let isCanDraw = objectSuccess as! Bool
            if isCanDraw {
                // 商家手机号验证
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeInfoView") as! ChangeInfoViewController
                viewController.chageInfoType = .depositCash
                viewController.depositCashMoney = Double(String(format: "%.2f", Double(self.inputMoneyTextField.text!)!))
                viewController.selectPayType = self.selectPayType
                viewController.defaultInputText = APP_DELEGATE.currentUserInfo?.phoneNumber
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                MBProgressHUD.show("今日提现次数已用完", icon: nil, view: self.view)
            }
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 判断是否普通用户
        if APP_DELEGATE.currentUserInfo != nil && APP_DELEGATE.currentUserInfo?.roleCode != RoleCodeType.roleMerchant.rawValue {
            self.navigationController?.popToRootViewController(animated: false)
        }
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
