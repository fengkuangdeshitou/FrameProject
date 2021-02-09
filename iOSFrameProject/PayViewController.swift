//
//  PayViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class PayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AppDelegateCustomDelegate, UITextFieldDelegate, SelectCouponViewDelegate {

    var merchant: MerchantModel?
    
    fileprivate var merchantUser: UserInfoModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showMerchantImageView: UIImageView!
    
    @IBOutlet weak var showMerchantNameLabel: UILabel!
    
    @IBOutlet weak var showMerchantUserNameLabel: UILabel!
    
    @IBOutlet weak var inputMoneyTitleLabel: UILabel!
    
    @IBOutlet weak var inputMoneyTF: UITextField!
    
    @IBOutlet weak var finalMoneyLabel: UILabel!
    
    @IBOutlet weak var goToPayBtn: UIButton!
    
    fileprivate var paySelectIndex: Int = 0     // 支付方式的索引选择
    fileprivate var paySelectType: PayType = PayType.alipay     // 选择支付方式
    
    fileprivate var dataSource: [CommonModel] = []
    fileprivate var couponArray: [CouponModel] = []
    var selectedCoupon: CouponModel?
    fileprivate var isHaveCoupon = false    // 是否有优惠券
    
    fileprivate var serialNumber = ""   // 查询订单-序列号
    
    fileprivate var finalMoney: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.title = "支付"
        self.inputMoneyTitleLabel.text = "消费总额（￥）"
        // 设置商家信息
        self.showMerchantImageView.image = DEFAULT_IMAGE()
        self.showMerchantNameLabel.text = ""
        self.showMerchantUserNameLabel.text = ""
        
        APP_DELEGATE.customDelegate = self
        self.inputMoneyTF.keyboardType = UIKeyboardType.decimalPad
        self.inputMoneyTF.delegate = self
        self.inputMoneyTF.placeholder = "0"
        self.inputMoneyTF.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.inputMoneyTF.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 设置TableView
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = COLOR_SEPARATOR_LINE
        self.tableView.register(UINib.init(nibName: "PayTableViewCell", bundle: nil), forCellReuseIdentifier: PayTableViewCell.CELL_ID)
        
        // 设置dataSource
        let data1 = CommonModel.init()
        data1.title = "支付宝支付"
        data1.imagePathStr = "alipay_logo"
        data1.textValue = PayType.alipay.rawValue
        
        let data2 = CommonModel.init()
        data2.title = "微信支付"
        data2.imagePathStr = "weixinPay_logo"
        data2.textValue = PayType.weiXinPay.rawValue
        self.dataSource = [data2, data1]
        self.paySelectType = PayType.weiXinPay
        
        self.setFinalMoney(money: 0.00)
        
        // 获取优惠券列表
        if self.selectedCoupon == nil {
            self.getCouponList()
        }
        
        // 获取商家详情
        self.getMerchantDetail()
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    func rightBarBtnItemClick(sender: UIBarButtonItem) {
        
    }
    
    // MARK: 设置合计金额
    func setFinalMoney(money: Double) {
        // 设置优惠后的金额
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 20.0, minFont: FONT_SMART_SIZE, color: COLOR_HIGHT_LIGHT_SYSTEM, action: {})
        var moneyValue = money
        if moneyValue < 0.0 {moneyValue = 0}
        let strText = "合计：<help><link><FontMax>\(String(format: "%.2f", moneyValue))</FontMax></link></help>元" as NSString
        self.finalMoneyLabel.attributedText = strText.attributedString(withStyleBook: (textStyleDict as! [AnyHashable : Any]))
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 优惠券cell
        if indexPath.section == 0 {
            var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
                cell?.textLabel?.font = UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE)
                cell?.textLabel?.textColor = COLOR_DARK_GAY
                
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: FONT_SYSTEM_SIZE)
                
                cell?.accessoryType = .disclosureIndicator
            }
            
            if self.selectedCoupon == nil || !(self.selectedCoupon?.isReachedLimetAmountUse)! {
                cell?.textLabel?.text = ""
                cell?.detailTextLabel?.text = "请选择优惠券"
                cell?.detailTextLabel?.textColor = COLOR_LIGHT_GAY
            } else {
                cell?.detailTextLabel?.textColor = COLOR_HIGHT_LIGHT_SYSTEM
                
                if self.selectedCoupon?.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
                    // 折扣券
                    cell?.textLabel?.text = "满\(String(format: "%.2f", (self.selectedCoupon?.limitAmount)!))元可使用"
                    cell?.detailTextLabel?.text = "\((self.selectedCoupon?.discount)! * 10)折"
                } else {
                    // 直减券
                    cell?.textLabel?.text = "满\(String(format: "%.2f", (self.selectedCoupon?.limitAmount)!))元减\((self.selectedCoupon?.discount)!)"
                    cell?.detailTextLabel?.text = "-\((self.selectedCoupon?.discount)!)元"
                }
            }
            
        
            return cell!
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PayTableViewCell.CELL_ID) as! PayTableViewCell
        cell.selectionStyle = .none
        if paySelectIndex == indexPath.row {
            cell.showSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
        } else {
            cell.showSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_unselect.png")
        }
        
        // 解析数据
        let dataCommon = self.dataSource[indexPath.row]
        
        cell.showImageView.image = UIImage.init(named: dataCommon.imagePathStr!)
        cell.showTitleLabel.text = dataCommon.title
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
            if !self.isHaveCoupon {
                MBProgressHUD.show("前往领取优惠券", icon: nil, view: nil)
                // 判断栈中是否含有 MerchantDetialViewController 控制器
                let allViewControllerArray = self.navigationController?.viewControllers
                for item  in allViewControllerArray! {
                    if item.classForCoder == MerchantDetialViewController.classForCoder() {
                        let mineVc = item as! MerchantDetialViewController
                        self.navigationController?.popToViewController(mineVc, animated: true)
                        return
                    }
                }
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MerchantDetialView") as! MerchantDetialViewController
                viewController.merchant = self.merchant
                viewController.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
                self.navigationController?.pushViewController(viewController, animated: true)
            } else {
                // 选择优惠券
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SelectCouponView") as! SelectCouponViewController
                viewController.merchant = self.merchant
                viewController.payAllMoney = Double(self.inputMoneyTF.text!)
                viewController.selectCoupon = self.selectedCoupon
                viewController.customDelegate = self
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            
        } else {
            self.paySelectIndex = indexPath.row
            
            // 解析数据
            let common = self.dataSource[indexPath.row]
            if common.textValue == PayType.alipay.rawValue {
                self.paySelectType = PayType.alipay
            } else {
                self.paySelectType = PayType.weiXinPay
            }
        }
        
        
        tableView.reloadData()
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PayTableViewCell.CELL_HEIGHT
    }
    
    // MARK: header Title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "选择优惠券"
        }
        return "支付方式"
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: UITextFieldDelegate
    // MARK: shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textString = textField.text! as NSString
        var nowString = textString.replacingCharacters(in: range, with: string)
        
        // 统计总金额
        if nowString.hasPrefix(".") {
            nowString = "0"
            textField.text = "0"
        } else if nowString.hasSuffix(".") {
            nowString.insert("0", at: nowString.endIndex)
        } else if nowString == "" {
            return true
        }
        
        // 不能输入值等于0
        if nowString == "0" && string == "0" {
            return false
        }
        
        // 只能输入数字和小数点
        if !NSString.isOnlyhasNumberAndpoint(with: string, andFormat: ".0123456789") {
            return false
        }
        
        // 不能出现第二个小数点
        if textString.contains(".") && string == "." {
            MBProgressHUD.show("不能输入多个小数点", icon: nil, view: self.view)
            return false
        }
        
        // 消费总额不大于10万
        if Double(nowString)! > Double(WORDCOUNT_ADD_COUPON_FULLMONEY_MAX) {
            MBProgressHUD.show("消费总额最高为10万元", icon: nil, view: self.view)
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
        
        self.updateMoneyValue(nowString: nowString)
        
        return true
    }
    
    
    // MARK: - SelectCouponViewDelegate
    // MARK: selcted coupon
    func SelectCouponViewSuccess(coupon: CouponModel) {
        self.selectedCoupon = coupon
        
        // 输入金额是否大于等于满减金额
        let inputTextValue: Double = self.inputMoneyTF.text == "" ? 0 : Double(self.inputMoneyTF.text!)!
        if inputTextValue >= (self.selectedCoupon?.limitAmount)! {
            self.selectedCoupon?.isReachedLimetAmountUse = true
        } else {
            self.selectedCoupon?.isReachedLimetAmountUse = false
        }
        self.tableView.reloadData()
    }
    
    // MARK: - AppDelegateCustomDelegate
    // MARK: appWillEnterForeground
    func appWillEnterForeground() {
        // 查询订单状态
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            if self.serialNumber == "" {return}
            MBProgressHUD.showMessage("", to: self.view)
            PaymentBusiness.shareIntance.responseWebCheckOrderStatus(serialNumber: self.serialNumber, responseSuccess: { (objectSuccess) in
                MBProgressHUD.hide(for: self.view, animated: true)
                
                let payment = objectSuccess as! PaymentModel
                let doneStatus = PaymentStatusType.done.rawValue
                if payment.status! == Int(doneStatus) {
                    self.payCenterOnResultWith(isPaySuccess: true)
                } else {
                    self.payCenterOnResultWith(isPaySuccess: false)
                }
                
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    
    // MARK: -  支付成功代理方法的回调
    func payCenterOnResultWith(isPaySuccess: Bool) {
        self.serialNumber = ""
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayStatusView") as! PayStatusViewController
        if isPaySuccess {
            MBProgressHUD.showSuccess("支付成功", to: self.view)
            viewController.payStatus = 1
        } else {
            MBProgressHUD.showError("支付失败", to: self.view)
            viewController.payStatus = -1
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: goToPayBtn Click
    @IBAction func goToPayBtnClick(_ sender: UIButton) {
        if self.inputMoneyTF.text?.count == 0 || Double((self.inputMoneyTF.text)!) == 0 {
            MBProgressHUD.show("请输入金额", icon: nil, view: self.view)
            return
        }
        
        // 限制最小充值范围
        if self.finalMoney < 0.0  {
            MBProgressHUD.show("总计金额应大于0元", icon: nil, view: self.view)
            return
        }
        
        // 1. 创建订单(下单)
        self.responseWebPaymentPrepay(merchantId: (self.merchant?.id)!, amount: Double(self.inputMoneyTF.text!)!, couponId: self.selectedCoupon == nil ? nil : self.selectedCoupon?.id, payType: self.paySelectType.rawValue)
    }
    
    
    /// 下单
    ///
    /// - Parameters:
    ///   - merchantId: 商户id
    ///   - amount: 总金额
    ///   - couponId: 优惠券id
    ///   - payType: 支付方式
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebPaymentPrepay(merchantId: String, amount: Double, couponId: String?, payType: String) {
        
        let parameters = NSMutableDictionary.init(dictionary: [
            "merchantId" : merchantId,
            "amount" : String(amount),  //
            "payType" : payType,])
        
        if couponId != nil && (self.selectedCoupon?.isReachedLimetAmountUse)! {
            parameters.setValue(couponId!, forKey: "couponId")
        }
        
        MBProgressHUD.showMessage("")
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PaymentPrepay, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            MBProgressHUD.hide()
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            
            if dataSourceDict["serialNumber"] != nil {
                self.serialNumber = dataSourceDict["serialNumber"]! as! String
            }
            // 2. 获取支付方式
            switch self.paySelectIndex {
            case 1:
                self.aliPayInformationAssemb(dataDict: dataSourceDict)
                myPrint(message: "支付宝支付")
            case 0:
                self.weixinPayInformationAssemb(dataDict: dataSourceDict)
                myPrint(message: "微信支付")
            default:
                myPrint(message: "未选择支付方式")
            }
        }) { (error) in
            myPrint(message: error)
        }
    }
    
    
    // MARK: 更新优惠金额的数值
    func updateMoneyValue(nowString: String) {
        if self.selectedCoupon == nil {
            self.finalMoney = Double(nowString)!
        } else {
            if Double(nowString)! < (self.selectedCoupon?.limitAmount)! && (self.selectedCoupon?.limitAmount)! != 0.0 {
                self.finalMoney = Double(nowString)!
            } else {
                if self.selectedCoupon?.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
                    // 折扣券
                    self.finalMoney = Double(nowString)! * (self.selectedCoupon?.discount)!
                } else {
                    // 直减券
                    self.finalMoney = Double(nowString)! - (self.selectedCoupon?.discount)!
                }
            }
            
            // 输入金额是否大于等于满减金额
            if Double(nowString)! >= (self.selectedCoupon?.limitAmount)! {
                self.selectedCoupon?.isReachedLimetAmountUse = true
            } else {
                self.selectedCoupon?.isReachedLimetAmountUse = false
            }
            self.tableView.reloadSections(IndexSet.init(integer: 0), with: UITableView.RowAnimation.none)
        }
        self.setFinalMoney(money: self.finalMoney)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isHaveCoupon {
            self.getCouponList()
        }
        
        if self.inputMoneyTF.text != "" {
            self.updateMoneyValue(nowString: self.inputMoneyTF.text!)
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
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebGetMerchantDetail(merchantId: (self.merchant?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.merchant = objectSuccess as? MerchantModel
            
            // 设置商家信息
            self.showMerchantImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
            self.showMerchantNameLabel.text = self.merchant?.name
            self.showMerchantUserNameLabel.text = self.merchant?.trueName
            
            /** 暂不使用对应用户的名称
            // 获取用户信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.merchant?.userId)!, responseSuccess: { (objectSuccess) in
                let user = objectSuccess as! UserInfoModel
                
                self.showMerchantUserNameLabel.text = user.nickname!
            }, responseFailed: { (error) in
            })
            */
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 获取优惠券列表
    func getCouponList()  {
        if self.merchant == nil {
            return
        }
        
        CouponBusiness.shareIntance.responseWebGetMyCouponList(merchantId: (self.merchant?.id)!, status: CouponStatusType.unuse.rawValue, pageSize: 100, pageCode: 1, responseSuccess: { (objectSuccess) in
            
            let pageResult = objectSuccess as! PageResultModel<CouponModel>
            self.couponArray.removeAll()
            self.couponArray = pageResult.beanList!
            
            if self.couponArray.count > 0 {
                self.isHaveCoupon = true
            }
//            for coupon in self.couponArray {
//                self.isHaveCoupon = true
//                let startDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.startTime! / 1000))
//                let endDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.endTime! / 1000))
//                let startDateStr = NSDate.string(from: startDate, andFormatterString: "yyyy-MM-dd")
//                let endDateStr = NSDate.string(from: endDate, andFormatterString: "yyyy-MM-dd")
//                let currentDateStr = NSDate.string(from: Date.init(), andFormatterString: "yyyy-MM-dd")
//
//                if startDateStr?.compare(currentDateStr!).rawValue != 1 && endDateStr?.compare(currentDateStr!).rawValue != -1 {
//                    self.selectedCoupon = coupon
//                    break
//                }
//
//            }
            
            myPrint(message: objectSuccess)
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
        }
    }
    
    
    
    // MARK: 我的钱包支付 的信息组装
    func myMoneyBagInformationAssemb() {
        MBProgressHUD.show("我的钱包支付", icon: nil, view: self.view)
    }
    
    
    // MARK: 支付宝支付 的信息组装
    func aliPayInformationAssemb(dataDict: NSDictionary) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        let appScheme = "ECOCityProject"
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        let orderString = dataDict["orderInfo"] as! String
        
        // NOTE: 调用支付结果开始支付
        AlipaySDK.defaultService().payOrder(orderString, fromScheme: appScheme, callback: { (resultDic) in
            myPrint(message: "\(String(describing: resultDic))")
            let resultDict = (resultDic! as NSDictionary)
            let isPaySuccess = Int(resultDict["resultStatus"] as! String) == 9000 ? true : false
            self.payCenterOnResultWith(isPaySuccess: isPaySuccess)
        })
    }
    
    // MARK: 微信支付 的信息组装
    func weixinPayInformationAssemb(dataDict: NSDictionary) {
        
        // 微信支付
        //需要创建这个支付对象
        
//        let req   = PayReq.init();
//        //由用户微信号和`AppID组成的唯一标识，用于校验微信用户
//        req.openID = dataDict["appid"] as? String;
//
//        // 商家id，在注册的时候给的
//        req.partnerId = dataDict["partnerid"] as? String;
//
//        // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
//        req.prepayId  = dataDict["prepayid"] as? String;
//
//        // 根据财付通文档填写的数据和签名
//        //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
//        req.package   = dataDict["package"] as? String;
//
//        // 随机编码，为了防止重复的，在后台生成
//        req.nonceStr  = dataDict["noncestr"] as? String;
//
//        // 这个是时间戳，也是在后台生成的，为了验证支付的
//        req.timeStamp = UInt32(dataDict["timestamp"] as! String)!;
//
//        // 这个签名也是后台做的
//        req.sign = dataDict["sign"] as? String;
        
        //发送请求到微信，等待微信返回onResp
        let isInstall = UMSocialManager.default().isInstall(.wechatSession)
        if !isInstall {
            MBProgressHUD.show("请安装微信程序", icon: nil, view: self.view)
            return
        }
        
//        let isSuccess = WXApi.send(req)
//        if !isSuccess {
//            APP_DELEGATE.alertCommonShow(title: "提示", message: "1.请检查是否安装微信程序\n2.请检查是否授权\"打开微信\"", btn1Title: "确定", btn2Title: nil, vc: self, buttonClick: {_ in})
//        }
    }

}
