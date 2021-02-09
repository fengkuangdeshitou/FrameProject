//
//  TradeRecordDetailViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class TradeRecordDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tradeRecord: MerchantTradeRecordModel?
    
    fileprivate var dataSource: [[String: String]] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var showMoneyTitleLabel: UILabel!
    
    @IBOutlet weak var showMoneyValueLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.showMoneyTitleLabel.text = ""
        self.showMoneyValueLabel.text = ""
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        // set tableView
        self.tableView.tableFooterView = UIView.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // 获取详细数据
        self.getTradeRecordDetail()
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TradeRecordDetailTableViewCell
        cell.selectionStyle = .none
        
        // 解析数据
        let dict = self.dataSource[indexPath.row]
        
        cell.showTitleLabel.text = dict[DICT_TITLE]
        cell.showRightLabel.text = dict[DICT_SUB_TITLE]
        cell.showRightLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
        
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
    
    // 交易记录详情
    func getTradeRecordDetail() {
       MBProgressHUD.showMessage("")
    MerchantBusiness.shareIntance.responseWebGetMerchantTradeRecordDetail(tradeId: (self.tradeRecord?.id)!, responseSuccess: { (objectSuccess) in
            self.tradeRecord = objectSuccess as? MerchantTradeRecordModel
            self.title = (self.tradeRecord?.description)!
            if (self.tradeRecord?.changeAmount)! > 0.0 {
                // 用户支付
                self.showMoneyTitleLabel.text = "入账金额"
                // 获取订单详情
                PaymentBusiness.shareIntance.responseWebGetPaymentDetail(orderId: (self.tradeRecord?.businessId)!, responseSuccess: { (objectSuccess) in
                    MBProgressHUD.hide()
                    let payment = objectSuccess as! PaymentModel
                    
                    var payTypeName = "微信"
                    if payment.payType == PayType.alipay.rawValue {
                        payTypeName = "支付宝"
                    }
                    
                    let data1 = [DICT_TITLE : "付款人", DICT_SUB_TITLE : (payment.user?.nickname)!]
                    
                    let takeDate = Date.init(timeIntervalSince1970: TimeInterval((self.tradeRecord?.createdTime)! / 1000))
                    
                    let data2 = [DICT_TITLE : "时间", DICT_SUB_TITLE : NSDate.string(from: takeDate, andFormatterString: DATE_STANDARD_FORMATTER)!]
                    let data3 = [DICT_TITLE : "交易单号", DICT_SUB_TITLE : (self.tradeRecord?.id)!]
                    
                    let data4 = [DICT_TITLE : "支付方式", DICT_SUB_TITLE : payTypeName]
                    
                    if payment.deductionAmount! != 0.0 {
                        let data5 = [DICT_TITLE : "使用优惠券", DICT_SUB_TITLE : String(format: "-%.2f元", payment.deductionAmount!)]
                        self.dataSource = [data1, data2, data3, data4, data5]
                    } else {
                        self.dataSource = [data1, data2, data3, data4]
                    }
                    self.tableView.reloadData()
                    
                }, responseFailed: { (error) in
                    MBProgressHUD.hide()
                })
            } else {
                // 提现
                self.showMoneyTitleLabel.text = "提现金额"
                
                // 获取提现详情
            MerchantBusiness.shareIntance.responseWebGetWithdrawDetail(withDrawId: (self.tradeRecord?.businessId)!, responseSuccess: { (objectSuccess) in
                    let withDraw = objectSuccess as! WithdrawModel
                MBProgressHUD.hide()
                // 数据整理
                var payTypeName = "微信"
                if withDraw.payType == PayType.alipay.rawValue {
                    payTypeName = "支付宝"
                }
                
                let data1 = [DICT_TITLE : "提现到账户", DICT_SUB_TITLE : payTypeName + "-" + withDraw.accountName!]
                
                let takeDate = Date.init(timeIntervalSince1970: TimeInterval((withDraw.createdTime)! / 1000))
                
                let data2 = [DICT_TITLE : "时间", DICT_SUB_TITLE : NSDate.string(from: takeDate, andFormatterString: DATE_STANDARD_FORMATTER)!]
                let data3 = [DICT_TITLE : "交易单号", DICT_SUB_TITLE : (self.tradeRecord?.id)!]
                
                self.dataSource = [data1, data2, data3]
                self.tableView.reloadData()
                }, responseFailed: { (error) in
                    MBProgressHUD.hide()
                })
            }
            self.showMoneyValueLabel.text = String(format: "%.2f", (self.tradeRecord?.changeAmount)!)
        }) { (error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
    }

}
