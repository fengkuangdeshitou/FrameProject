//
//  MerchantDetialViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantDetialViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var merchant: MerchantModel?
    
    fileprivate var couponGroupArray: [CouponGroupModel] = []
    fileprivate var mineOwnCouponArray: [CouponModel] = []
    
    var userLocation: CLLocationCoordinate2D?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    @IBOutlet weak var showDistanceLabel: UILabel!
    
    @IBOutlet weak var alipayFloagImageView: UIImageView!
    
    @IBOutlet weak var weixinPayFloagImageView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var callPhoneBtn: UIButton!
    
    
    @IBOutlet weak var couponView: UIView!
    
    @IBOutlet weak var couponScrollView: UIScrollView!
    
    
    
    @IBOutlet weak var showMerchantDetailView: UIView!
    
    @IBOutlet weak var showMerchantDetailLabel: UILabel!
    
    @IBOutlet weak var showMerchantViewTopLineView: UIView!
    
    @IBOutlet weak var showMerchantViewMiddleLineView: UIView!
    
    @IBOutlet weak var showMerchantViewBottomLineView: UIView!
    
    
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var couponSelLabel: UILabel!
    
    @IBOutlet weak var gotToPayBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = self.merchant?.name
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // 设置tableView
        self.tableView.tableFooterView = UIView.init()
        
        // 设置scrollView
        self.couponScrollView.showsVerticalScrollIndicator = false
        self.couponScrollView.showsHorizontalScrollIndicator = false
        
        // 设置商家信息
        self.setMerchantInfo()
        
        // 获取Web商家详细信息
        self.getMerchantDetail()
        
        // MARK: 获取商家的优惠券列表
        self.getMerchantCouponList()
        
        // MARK: 获取我领取该商家的优惠券列表
        self.getMineCouponList()
    }
    
    // 设置商家信息
    func setMerchantInfo() {
        // 设置图片
        self.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
        
        // name
        self.showTitleLabel.text = merchant?.name
        
        // 描述
        self.showSubTitleLabel.text = merchant?.description
        
        // 距离
        // 计算当前位置到商家的位置的距离(坐标点的直线距离)
        let point1 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: (merchant?.latitude)!, longitude: (merchant?.longitude)!))
        let point2 = MAMapPointForCoordinate(CLLocationCoordinate2D(latitude: (userLocation?.latitude)!, longitude: (userLocation?.longitude)!))
        // 计算距离
        let distance = MAMetersBetweenMapPoints(point1,point2)
        self.showDistanceLabel.text = "距离我" + (NSString.init(readDistanceWith: CGFloat(distance))! as String) as String
        
        // 支付方式标记
        self.alipayFloagImageView.isHidden = merchant?.aliAccount == ""
        self.weixinPayFloagImageView.isHidden = merchant?.wxAccount == ""
        
        // 设置定位信息
        self.addressLabel.textAlignment = .left
        self.addressLabel.text = merchant?.address
        
        // 设置店铺详细信息
        self.showMerchantDetailView.width = SCREEN_WIDTH
        self.showMerchantViewBottomLineView.width = SCREEN_WIDTH
        self.showMerchantViewTopLineView.width = SCREEN_WIDTH
        self.showMerchantViewMiddleLineView.width = SCREEN_WIDTH
        self.showMerchantDetailLabel.text = self.merchant?.introduction
        self.showMerchantDetailLabel.width = SCREEN_WIDTH - 22*2
        
        // 设置label高度
        UILabel.setLabelSpace(self.showMerchantDetailLabel, withValue: self.showMerchantDetailLabel.text, with: self.showMerchantDetailLabel.font, andLineSpaceing: 6.0)
        
        let detailHeight = UILabel.getSpaceLabelHeight(self.showMerchantDetailLabel.text, with: self.showMerchantDetailLabel.font, withWidth: self.showMerchantDetailLabel.width, andLineSpaceing: 6.0)
        
        self.showMerchantDetailLabel.height = detailHeight
        self.showMerchantDetailView.height = detailHeight + 35
        self.showMerchantViewBottomLineView.y = self.showMerchantDetailView.height - 0.5
        self.tableView.tableHeaderView?.height = CGFloat(85.0 + 75.0 + 106.0 + 3.0*8.0) + self.showMerchantDetailView.height
        
        // 设置默认的优惠券选择
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 20.0, minFont: FONT_SMART_SIZE, color: COLOR_HIGHT_LIGHT_SYSTEM, action: {})
        let strText = "已领取<help><link><FontMax>\(String(describing: self.mineOwnCouponArray.count))</FontMax></link></help>张优惠券" as NSString
        self.couponSelLabel.attributedText = strText.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: 打电话点击
    @IBAction func callPhoneBtnClick(_ sender: UIButton) {
        UIApplication.shared.openURL(NSURL.init(string: "tel://\((self.merchant?.contact)!)")! as URL)
    }
    
    // MARK: 去支付点击
    @IBAction func goToPayBtnClick(_ sender: UIButton) {
        // 判断是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: true)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        var viewController: PayViewController?
        for vc in (self.navigationController?.viewControllers)! {
            if vc is PayViewController {
                viewController = vc as? PayViewController
                break
            }
        }
        
        if viewController == nil {
            viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as? PayViewController
            viewController?.merchant = self.merchant
            self.navigationController?.pushViewController(viewController!, animated: true)
        } else {
            self.navigationController?.popToViewController(viewController!, animated: true)
        }
    }
    
    // MARK: 优惠券点击
    @objc func couponViewClick(gesture: UIGestureRecognizer) {
        
        // 判断是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        myPrint(message: "优惠券点击- \(String(describing: (gesture.view?.tag)!))")
        
        // 解析数据
        let couponGroup = self.couponGroupArray[(gesture.view?.tag)!]
        
        APP_DELEGATE.alertCommonShow(title: "提示", message: "获取此优惠券将消耗你 \(couponGroup.coinPrice!)碳币", btn1Title: "取消", btn2Title: "确定", vc: self) { (btnIndex) in
            if btnIndex == 1 {
                self.getCouponWithCarbonCoin(couponGroup: couponGroup)
            }
        }
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            self.setMerchantInfo()
        }) { (error) in
            
        }
    }
    
    
    // MARK: 获取商家的优惠券列表
    func getMerchantCouponList() {
        MBProgressHUD.showMessage("", to: self.view)
      CouponBusiness.shareIntance.responseWebGetMerchantCouponGroupList(merchantId: (self.merchant?.id)!, isExpired: false, isFinished: false, pageSize: 100, pageCode: 1, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<CouponGroupModel>
            self.couponGroupArray = pageResult.beanList!
        
        if self.couponGroupArray.count > 0 {
            self.couponScrollView.isHidden = false
            self.couponScrollView.backgroundColor = UIColor.white
        } else {
            self.couponScrollView.isHidden = true
        }
        
            // 设置优惠券
            for (i, item) in self.couponGroupArray.enumerated() {
                let nibView = Bundle.main.loadNibNamed("SmallCouponView", owner: nil, options: nil)
                let couponView = nibView?.first as! SmallCouponView
                
                // 设置数据
                couponView.loadInitData(couponGroup: item)
                
                couponView.x = CGFloat(10 + 5*(i+1)) + CGFloat(i) * couponView.width
                
                self.couponScrollView.addSubview(couponView)
                
                couponView.isUserInteractionEnabled = true
                couponView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.couponViewClick(gesture:))))
                couponView.tag = i
            }
            self.couponScrollView.contentSize = CGSize(width: CGFloat(10 + 5 * (self.couponGroupArray.count + 1) + self.couponGroupArray.count * 203), height: STATUS_BAR_HEIGHT)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 获取我领取该商家的优惠券列表
    func getMineCouponList()  {
        if self.merchant == nil {
            return
        }
        CouponBusiness.shareIntance.responseWebGetMyCouponList(merchantId: (self.merchant?.id)!, status: CouponStatusType.unuse.rawValue, pageSize: 1000, pageCode: 1, responseSuccess: { (objectSuccess) in
            
            let pageResult = objectSuccess as! PageResultModel<CouponModel>
            self.mineOwnCouponArray.removeAll()
            self.mineOwnCouponArray = pageResult.beanList!
            self.setMerchantInfo()
        }) { (error) in
        }
    }
    
    
    // MARK: 使用碳币购买优惠券
    func getCouponWithCarbonCoin(couponGroup: CouponGroupModel) {
        MBProgressHUD.showMessage("", to: self.view)
        CouponBusiness.shareIntance.responseWebGetCouponBuy(couponGroupId: couponGroup.id!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.show("已获取此优惠券", icon: nil, view: self.view)
            
            // 更新用户信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (objectSuccess) in
                let userInfo = objectSuccess as! UserInfoModel
                APP_DELEGATE.currentUserInfo = userInfo
                // 发送更新用户信息的广播
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
                
                // 获取我领取该商家的优惠券列表
                self.getMineCouponList()
            }, responseFailed: { (error) in
            })
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
