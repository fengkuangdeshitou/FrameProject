//
//  MerchantWalletViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit


class MerchantWalletViewController: UIViewController {
    var merchant: MerchantModel?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var walletMoneyLabel: UILabel!
    
    @IBOutlet weak var showTodayIncomeLabel: UILabel!
    
    @IBOutlet weak var depositToCashBtn: UIButton!
    
    @IBOutlet weak var depositRuleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "我的钱包"
        self.depositToCashBtn.layer.masksToBounds = true
        self.depositToCashBtn.layer.cornerRadius = CORNER_NORMAL
        self.depositRuleLabel.isUserInteractionEnabled = true
        self.depositRuleLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(depositRuleClick(sender:))))
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // tableview init
        self.tableView.tableFooterView = UIView.init()
        
        // setTableHeaderView
        self.setTableHeaderView()
        
        // 获取商家详情
        self.getMerchantDetail()
        
        
        /// 注册接收消息通知
        // 接收用户的商户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoMerchantUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo_Merchant), object: nil)
    }
    
    
    // MARK: 用户的商户信息更新消息响应
    @objc func acceptUserInfoMerchantUpdateNotification(notification: Notification) {
        self.getMerchantDetail()
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: setTableHeaderView
    func setTableHeaderView() {
        // 设置余额
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 23.0, minFont: FONT_SMART_SIZE, color: COLOR_HIGHT_LIGHT_SYSTEM, action: {})
        let strText = "<help><link><FontMax>\(String(format: "%.2f", (self.merchant?.amount)!))</FontMax></link></help>元" as NSString
        self.walletMoneyLabel.attributedText = strText.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 今日营收
        self.showTodayIncomeLabel.textColor = COLOR_GAY
        self.showTodayIncomeLabel.text = "今日营收：0.00元"
    MerchantBusiness.shareIntance.responseWebGetMerchantTradeRecordTodayIncome(responseSuccess: { (objectSuccess) in
            let income = objectSuccess as! Double
            self.showTodayIncomeLabel.text = "今日营收：\(String(format: "%.2f", income))元"
        }) { (error) in
        }
    }
    
    
    // MARK: 提现点击
    @IBAction func depositToCashBtnClick(_ sender: UIButton) {
        // 判断钱包余额
        if (self.merchant?.amount)! < 1.0 {
            MBProgressHUD.show("余额不足1元,不能提现", icon: nil, view: self.view)
            return
        }
        
        // 判断是否包含支付宝和微信提现账户
        if self.merchant?.aliAccount == nil && self.merchant?.wxAccount == nil {
            MBProgressHUD.show("请设置微信和支付宝支付相关信息", icon: nil, view: self.view)
            return
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DepositCashView") as! DepositCashViewController
        viewController.merchant = self.merchant
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: 提现规则点击
    @objc func depositRuleClick(sender: UIGestureRecognizer) {
        
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/withdraw.html"
        webViewController.isShowWebPageTrack = false
        self.navigationController?.pushViewController(webViewController, animated: true)
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
    
    // MARK: 获取商家详情接口
    func getMerchantDetail() {
        MerchantBusiness.shareIntance.responseWebGetMerchantDetail(merchantId: (self.merchant?.id)!, responseSuccess: { (objectSuccess) in
            self.merchant = objectSuccess as? MerchantModel
            
            self.setTableHeaderView()
        }) { (error) in
        }
    }

    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
}
