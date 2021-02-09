//
//  MerchantInformationViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantInformationViewController: UIViewController {

    var merchant: MerchantModel?
    
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
    
    @IBOutlet weak var showMerchantDetailView: UIView!
    
    @IBOutlet weak var showMerchantDetailLabel: UILabel!
    
    @IBOutlet weak var showMerchantViewTopLineView: UIView!
    @IBOutlet weak var showMerchantViewMiddleLineView: UIView!
    @IBOutlet weak var showMerchantViewBottomLineView: UIView!
    
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
        
        // 设置商家信息
        self.setMerchantInfo()
    }

    // 设置商家信息
    func setMerchantInfo() {
        // 设置图片
        self.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (merchant?.logo!)!), placeholderImage: DEFAULT_IMAGE())
        
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
        self.addressLabel.text = merchant?.address
        
        // 设置电话号码
        self.callPhoneBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
        self.callPhoneBtn.setTitle((self.merchant?.contact)!, for: .normal)
        self.callPhoneBtn.titleLabel?.numberOfLines = 0
        self.callPhoneBtn.titleLabel?.font = UIFont.systemFont(ofSize: FONT_SMART_SIZE)
        
        // 设置店铺详细信息
        self.showMerchantDetailView.width = SCREEN_WIDTH
        self.showMerchantViewTopLineView.width = SCREEN_WIDTH
        self.showMerchantViewBottomLineView.width = SCREEN_WIDTH
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
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
            
            self.setMerchantInfo()
        }) { (error) in
            
        }
    }
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }

}
