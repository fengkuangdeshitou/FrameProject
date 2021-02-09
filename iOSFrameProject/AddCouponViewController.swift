//
//  AddCouponViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/4.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

protocol AddCouponViewDelegate: NSObjectProtocol {
    func addCouponSuccess();
}

class AddCouponViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {

    weak var customDelegate: AddCouponViewDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var disountBtn: UIButton!
    
    @IBOutlet weak var priceBtn: UIButton!
    
    @IBOutlet weak var beginTimeTextField: UITextField!
    
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var sendCountTextField: UITextField!
    
    @IBOutlet weak var costCarbonCountTF: UITextField!
    
    @IBOutlet weak var fullMoneyCutTextField: UITextField!
    
    
    @IBOutlet weak var discountTitleLabel: UILabel!
    
    @IBOutlet weak var discountTextField: UITextField!
    
    
    @IBOutlet weak var sendCouponBtn: UIButton!
    
    
    // 时间选择器
    fileprivate lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker.init()
        
        picker.datePickerMode = .date
        
        return picker
    }()
    
    // keyBoard 上的选择栏
    fileprivate lazy var keyBoardTopView: UIView = {
        let topView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT))
        topView.backgroundColor = UIColor.white
        
        let btnW: CGFloat = 60, btnH: CGFloat = 30
        
        // cancel
        let cancelBtn = UIButton.init(frame: CGRect(x: 10, y: (topView.height - btnH) / 2, width: btnW, height: btnH))
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.setTitleColor(COLOR_DARK_GAY, for: UIControl.State.normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        cancelBtn.addTarget(self, action: #selector(keyBoardTopViewCancelBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(cancelBtn)
        
        // sure
        let sureBtn = UIButton.init(frame: CGRect(x: SCREEN_WIDTH - btnW - 10, y: (topView.height - btnH) / 2, width: btnW, height: btnH))
        sureBtn.setTitle("确定", for: UIControl.State.normal)
        sureBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        sureBtn.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        sureBtn.layer.masksToBounds = true
        sureBtn.layer.cornerRadius = CORNER_SMART
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE)
        sureBtn.addTarget(self, action: #selector(keyBoardTopViewSureBtnClick(sender:)), for: UIControl.Event.touchUpInside)
        topView.addSubview(sureBtn)
        
        // 设置分割线
        let topLineView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.5))
        topLineView.backgroundColor = COLOR_SEPARATOR_LINE
        let bottomLineView = UIView.init(frame: CGRect(x: 0, y: topView.height - 0.5, width: SCREEN_WIDTH, height: 0.5))
        bottomLineView.backgroundColor = COLOR_SEPARATOR_LINE
        topView.addSubview(topLineView)
        topView.addSubview(bottomLineView)
        
        return topView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "添加优惠券"
        self.sendCouponBtn.layer.masksToBounds = true
        self.sendCouponBtn.layer.cornerRadius = CORNER_NORMAL
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "？", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        
        // set table View
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView.init()
        
        
        // set textField
        let beginTimeRightImageView = UIImageView.init(image: #imageLiteral(resourceName: "add_coupon_time_arrow.png"))
        beginTimeRightImageView.contentMode = .scaleAspectFit
        beginTimeRightImageView.width += 5.0
        self.beginTimeTextField.rightViewMode = .always
        self.beginTimeTextField.rightView = beginTimeRightImageView
        self.beginTimeTextField.inputView = self.datePicker
        self.beginTimeTextField.inputAccessoryView = self.keyBoardTopView
        
        let endTimeRightImageView = UIImageView.init(image: #imageLiteral(resourceName: "add_coupon_time_arrow.png"))
        endTimeRightImageView.contentMode = .scaleAspectFit
        endTimeRightImageView.width += 5.0
        self.endTimeTextField.rightViewMode = .always
        self.endTimeTextField.rightView = endTimeRightImageView
        self.endTimeTextField.inputView = self.datePicker
        self.endTimeTextField.inputAccessoryView = self.keyBoardTopView
        
        // set delegate
        self.beginTimeTextField.delegate = self
        self.endTimeTextField.delegate = self
        self.sendCountTextField.delegate = self
        self.costCarbonCountTF.delegate = self
        self.fullMoneyCutTextField.delegate = self
        self.discountTextField.delegate = self
        
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
//        let viewController = AddCouponHelpViewController.init(nibName: "AddCouponHelpViewController", bundle: nil)
//        self.navigationController?.pushViewController(viewController, animated: true)
        
        // 协议点击（发布优惠券帮助）
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/publishCoupon.html"
        webViewController.isShowWebPageTrack = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: - UITableViewDelegate
    // MARK:
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - UITextFieldDelegate
    // MARK: shouldChangeCharactersIn
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.beginTimeTextField || textField == self.endTimeTextField {
            return true
        }
        
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
            } else {
                if textField == self.discountTextField && !self.priceBtn.isSelected && range.location - ran.location > 1 {
                    MBProgressHUD.show("只能输入到小数点后1位", icon: nil, view: self.view)
                    return false
                }
            }
        }
        
        
        
        // 发送数量
        if textField == self.sendCountTextField {
            let text = nowString == "" ? "0" : nowString
            if Int(text)! > WORDCOUNT_ADD_COUPON_SENDCOUNT_MAX {
                MBProgressHUD.show("发放数量最高为1万张" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 每张价值碳币数
        if textField == self.costCarbonCountTF {
            let text = nowString == "" ? "0" : nowString
            if Int(text)! > WORDCOUNT_ADD_COUPON_COSTCARBON_MAX {
                MBProgressHUD.show("价值碳币数最高为10万枚" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 满减金额
        if textField == self.fullMoneyCutTextField {
            let text = nowString == "" ? "0" : nowString
            
//            if self.priceBtn.isSelected && self.discountTextField.text != "" {
//                if Double(text)! <= Double(self.discountTextField.text!)! {
//                    MBProgressHUD.show("满减金额须大于优惠金额" , icon: nil, view: self.view)
//                    return false
//                } else if Double(text)! > Double(WORDCOUNT_ADD_COUPON_FULLMONEY_MAX)  {
//                    MBProgressHUD.show("满减金额最高为10万元" , icon: nil, view: self.view)
//                    return false
//                }
//            } else {
//                if Double(text)! > Double(WORDCOUNT_ADD_COUPON_FULLMONEY_MAX) {
//                    MBProgressHUD.show("满减金额最高为10万元" , icon: nil, view: self.view)
//                    return false
//                }
//            }
            
            if Double(text)! > Double(WORDCOUNT_ADD_COUPON_FULLMONEY_MAX) {
                MBProgressHUD.show("满减金额最高为10万元" , icon: nil, view: self.view)
                return false
            }
        }
        
        // 优惠折扣  / 优惠金额
        if textField == self.discountTextField {
            let text = nowString == "" ? "0" : nowString
            if self.priceBtn.isSelected {
                //优惠金额
//                if self.fullMoneyCutTextField.text != "" {
//                    if Double(text)! >= Double(self.fullMoneyCutTextField.text!)! {
//                        MBProgressHUD.show("优惠金额须小于满减金额" , icon: nil, view: self.view)
//                        return false
//                    }
//                } else {
//                    if Double(text)! >= Double(WORDCOUNT_ADD_COUPON_DISCOUNT_PRICE_MAX) {
//                        MBProgressHUD.show("优惠金额须小于10万元" , icon: nil, view: self.view)
//                        return false
//                    }
//                }
                
                if Double(text)! >= Double(WORDCOUNT_ADD_COUPON_DISCOUNT_PRICE_MAX) {
                    MBProgressHUD.show("优惠金额须小于10万元" , icon: nil, view: self.view)
                    return false
                }
                
            } else {
                //优惠折扣
                if Double(text)! > WORDCOUNT_ADD_COUPON_DISCOUNT_DISCOUNT_MAX {
                    MBProgressHUD.show("优惠折扣最高为9.9折" , icon: nil, view: self.view)
                    return false
                }
            }
        }
 
        
        return true
    }
    
    // MARK: textFieldShouldBeginEditing
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == self.beginTimeTextField {
            // 开始时间
            self.datePicker.minimumDate = Date.init()
            if self.endTimeTextField.text == "" {
                let maxDate = NSDate.init(toStringForOtherDateFromNowDays: 0, andOriginalDate: Date.init(timeIntervalSince1970: 253433894399))
                self.datePicker.maximumDate = maxDate! as Date
            } else {
                let maxDate = NSDate.init(toStringForOtherDateFromNowDays: 0, andOriginalDate: NSDate.init(from: self.endTimeTextField.text, andFormatterString: "yyyy-MM-dd") as Date?)
                self.datePicker.maximumDate = maxDate! as Date
            }
        } else if textField == self.endTimeTextField {
            // 结束时间
            if self.beginTimeTextField.text == "" {
                let tomorrowDate = NSDate.init(toStringForOtherDateFromNowDays: 0, andOriginalDate: Date.init())
                self.datePicker.minimumDate = tomorrowDate! as Date
            } else {
                let beginDate = NSDate.init(from: self.beginTimeTextField.text, andFormatterString: "yyyy-MM-dd")
                let tomorrowDate = NSDate.init(toStringForOtherDateFromNowDays: 0, andOriginalDate: beginDate! as Date)
                
                self.datePicker.minimumDate = tomorrowDate! as Date
            }
            self.datePicker.maximumDate = Date.init(timeIntervalSince1970: 253433894399)
        }
        
        return true
    }
    
    
    
    // MARK: keyBoard Top View -- cancelBtnClick
    @objc func keyBoardTopViewCancelBtnClick(sender: UIButton) {
        self.view.endEditing(true)
    }
    // MARK: keyBoard Top View -- sureBtnClick
    @objc func keyBoardTopViewSureBtnClick(sender: UIButton) {
        if self.beginTimeTextField.isEditing {
            self.beginTimeTextField.text = NSDate.string(from: self.datePicker.date, andFormatterString: "yyyy-MM-dd")
        } else if self.endTimeTextField.isEditing {
            self.endTimeTextField.text = NSDate.string(from: self.datePicker.date, andFormatterString: "yyyy-MM-dd")
        }
        
        self.view.endEditing(true)
    }
    
    
    
    // MARK: 折扣券点击
    @IBAction func discountBtnClick(_ sender: UIButton) {
        sender.isSelected = true
        self.priceBtn.isSelected = false
        
        self.discountTitleLabel.text = "优惠折扣（折）"
        self.discountTextField.placeholder = "8.8折"
        self.discountTextField.text = ""
    }
    
    
    // MARK: 价格券点击
    @IBAction func priceBtnClick(_ sender: UIButton) {
        sender.isSelected = true
        self.disountBtn.isSelected = false
        
        self.discountTitleLabel.text = "优惠金额（元）"
        self.discountTextField.placeholder = "5元"
        self.discountTextField.text = ""
    }
    
    
    // MARK: 发布优惠券点击
    @IBAction func sendCouponBtnClick(_ sender: UIButton) {
        let text1 = NSString.verifyString(self.beginTimeTextField.text)
        let text2 = NSString.verifyString(self.endTimeTextField.text)
        let text3 = NSString.verifyString(self.sendCountTextField.text)
        let text4 = NSString.verifyString(self.costCarbonCountTF.text)
        let text5 = NSString.verifyString(self.fullMoneyCutTextField.text)
        let text6 = NSString.verifyString(self.discountTextField.text)
        if text1 == "" || text2 == "" || text3 == "" || text4 == "" || text5 == "" || text6 == "" {
            MBProgressHUD.show("请填写每一项", icon: nil, view: self.view)
            return
        }
        
        // 发放数量
        if Int(text3!)! < 1 {
            MBProgressHUD.show("发放数量最低为1张", icon: nil, view: self.view)
            return
        }
        
        // 价值碳币数
        if Int(text4!)! < 1 {
            MBProgressHUD.show("价值碳币数最低为1枚", icon: nil, view: self.view)
            return
        }

        // 满减金额
        if Double(text5!)! < 1 {
            MBProgressHUD.show("满减金额最低为1元", icon: nil, view: self.view)
            return
        }
        
        
        // 整理优惠券参数
        var couponName = "折扣券"
        var couponType = CouponTypeCode.discountCoupon.rawValue
        var discount = Double(self.discountTextField.text!)! / 10
        if self.priceBtn.isSelected {
            // 价格券
            couponName = "满减券"
            couponType = CouponTypeCode.moneyCoupon.rawValue
            discount = Double(self.discountTextField.text!)!
            
            if discount >= Double(self.fullMoneyCutTextField.text!)! {
                MBProgressHUD.show("优惠金额须小于满减金额", icon: nil, view: self.view)
                return
            }
            if discount < 0.01 {
                MBProgressHUD.show("优惠金额最低为0.01元", icon: nil, view: self.view)
                return
            }
        } else {
            // 折扣券
            if discount > WORDCOUNT_ADD_COUPON_DISCOUNT_DISCOUNT_MAX / 10 {
                MBProgressHUD.show("优惠折扣最高为9.9折", icon: nil, view: self.view)
                return
            }
            
            if discount < 0.01  {
                MBProgressHUD.show("优惠折扣最低为0.1折", icon: nil, view: self.view)
                return
            }
        }
        
        MBProgressHUD.showMessage("")
        CouponBusiness.shareIntance.responseWebPublishCouponGroup(name: couponName, description: couponName, couponTypeCode: couponType, startTime: self.beginTimeTextField.text! + " 00:00:00", endTime: self.endTimeTextField.text! + " 23:59:59", limitAmount: Double(self.fullMoneyCutTextField.text!), cointPrice: Int(self.costCarbonCountTF.text!)!, discount: discount, total: Int(self.sendCountTextField.text!)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            MBProgressHUD.showSuccess("已发布", to: self.view)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                self.customDelegate?.addCouponSuccess()
                self.navigationController?.popViewController(animated: true)
            })
            
        }) { (error) in
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
