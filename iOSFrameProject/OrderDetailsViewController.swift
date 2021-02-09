//
//  OrderDetailsViewController.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class OrderDetailsViewController: UIViewController, UIAlertViewDelegate, UIGestureRecognizerDelegate {
    
    var payment: PaymentModel?
    
    @IBOutlet var shopPicImage: UIImageView!
    @IBOutlet var shopNameButton: UIButton!
    @IBOutlet weak var methodPaymentBtn: UIButton!
    @IBOutlet var methodPaymentLabel: UILabel!
    @IBOutlet var methodPaymentLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var totalConsumption: UILabel!
    @IBOutlet var favorableConditionsLabel: UILabel!
    @IBOutlet var discountAmountLabel: UILabel!
    @IBOutlet var finalPriceLabel: UILabel!
    @IBOutlet var orderNoLabel: UILabel!
    @IBOutlet var orderCreationTime: UILabel!
    @IBOutlet var payDoneTime: UILabel!
    
    @IBOutlet weak var couponDetailView: UIView!
    
    @IBOutlet weak var couponDetailViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "订单详情"
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        // 获取订单详情
        self.getMineOrderDetail()
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 查看商户
    @IBAction func checkMerchants(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MerchantDetialView") as! MerchantDetialViewController
        viewController.merchant = self.payment?.merchant
        viewController.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // 拨打商户电话
    @IBAction func makePhone(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL.init(string: "tel://\((self.payment?.merchant?.contact)!)")! as URL)
    }
    
    
    // MARK: goToPay
    @IBAction func goToPayClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as! PayViewController
        viewController.merchant = self.payment?.merchant
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // 展示数据
    func initDisplayData() {
        if self.payment?.merchant == nil {
            return
        }
        
        
        // show Shop Image
        self.shopPicImage.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.payment?.merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
        
        // shop Name
        shopNameButton.setRightAndleftTextWith(UIImage.init(named: "nav_back_reverse.png"), withTitle: (self.payment?.merchant?.name)!, for: UIControl.State.normal, andImageFontValue: 5, andTitleFontValue: 16, andTextAlignment: UIControl.ContentHorizontalAlignment.left)
        
        // pay type
        if self.payment?.payType == PayType.alipay.rawValue {
            methodPaymentBtn.setImage(#imageLiteral(resourceName: "order_detail_alipay.png"), for: .normal)
            methodPaymentLabel.text = "支付宝支付"
        } else {
            methodPaymentBtn.setImage(#imageLiteral(resourceName: "order_detail_wxpay.png"), for: .normal)
            methodPaymentLabel.text = "微信支付"
        }
        methodPaymentLayoutConstraint.constant = CGFloat((methodPaymentLabel.text?.count)! * 15)
        
        var attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        var symbol: NSAttributedString = NSAttributedString(string: "￥", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
        let amountStr = NSString.removeFloatAllZero((String(format: "%.2f", (self.payment?.amount)!) as NSString) as String?)!
        var price: NSAttributedString = NSAttributedString(string: amountStr, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.7), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
        attributedStrM.append(symbol)
        attributedStrM.append(price)
        totalConsumption.attributedText = attributedStrM
        
        if (self.payment?.deductionAmount)! <= 0.0 {
            self.couponDetailView.isHidden = true
            self.couponDetailViewHeightConstraint.constant = 0
        } else {
            self.couponDetailView.isHidden = false
            self.couponDetailViewHeightConstraint.constant = 50
            let deductionAmountStr = NSString.removeFloatAllZero((String(format: "%.2f", (self.payment?.deductionAmount)!) as NSString) as String?)!
            favorableConditionsLabel.text = "已优惠\(deductionAmountStr)元"
            discountAmountLabel.text = String(format: "-%@", deductionAmountStr) + "元"
        }
        
        
        attributedStrM = NSMutableAttributedString()
        symbol = NSAttributedString(string: "￥", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
        let autualPayStr = NSString.removeFloatAllZero((String(format: "%.2f", (self.payment?.actualAmount)!) as NSString) as String?)!
        price = NSAttributedString(string: autualPayStr, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.7), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 20.0)])
        attributedStrM.append(symbol)
        attributedStrM.append(price)
        finalPriceLabel.attributedText = attributedStrM
        
        orderNoLabel.text = "订单编号：\((self.payment?.serialNumber)!)"
        
        let createDate = Date.init(timeIntervalSince1970: TimeInterval((self.payment?.createdTime)! / 1000))
        let payDoneDate = Date.init(timeIntervalSince1970: TimeInterval((self.payment?.finishTime)! / 1000))
        orderCreationTime.text = "创建时间：\(NSDate.string(from: createDate, andFormatterString: DATE_STANDARD_FORMATTER)!)"
        payDoneTime.text = "付款时间：\(NSDate.string(from: payDoneDate, andFormatterString: DATE_STANDARD_FORMATTER)!)"
    }
    
    
    // MARK: 获取订单详情
    func getMineOrderDetail() {
        if self.payment == nil {
            return
        }
        MBProgressHUD.showMessage("", to: self.view)
        PaymentBusiness.shareIntance.responseWebGetPaymentDetail(orderId: (self.payment?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.payment = objectSuccess as? PaymentModel
            
            self.initDisplayData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    // MARK: - UIGestureRecognizerDelegate 代理方法的实现
    // MARK:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
