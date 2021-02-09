//
//  MerchantCenterViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MerchantCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var merchant: MerchantModel?

    @IBOutlet weak var showMerchantBgImageView: UIImageView!
    
    @IBOutlet weak var showMerchantImageView: UIImageView!
    
    @IBOutlet weak var showTitleLabel: UILabel!
    
    @IBOutlet weak var showSubTitleLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSource: [Array<[String : String]>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = ""
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.frame = self.showMerchantBgImageView.bounds
        effectView.width = SCREEN_WIDTH
        self.showMerchantBgImageView.addSubview(effectView)
        
        self.dataSource = [[[DICT_IMAGE_PATH : "merchant_center_info", DICT_TITLE : "店铺信息", DICT_IDENTIFIER : "MerchantInformationView"]],
                           
                           [[DICT_IMAGE_PATH : "merchant_center_wallet", DICT_TITLE : "我的钱包", DICT_IDENTIFIER : "MerchantWalletView"],
                            [DICT_IMAGE_PATH : "merchant_center_coupon", DICT_TITLE : "优惠券管理", DICT_IDENTIFIER : "CouponManageView"]],
                           
                           [[DICT_IMAGE_PATH : "merchant_center_record", DICT_TITLE : "交易流水", DICT_IDENTIFIER : "TradeRecordListView"]]]
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // setTableHeaderView
        self.setTableHeaderView()
        
        // set table
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: -NAVIGATION_AND_STATUS_HEIGHT, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = UIEdgeInsets(top: -NAVIGATION_AND_STATUS_HEIGHT, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "MerchantCenterCell", bundle: nil), forCellReuseIdentifier: MerchantCenterCell.CELL_ID)
        
        // 获取商家详情
        if self.merchant?.id == "" {
            // 获取用户信息
        UserBusiness.shareIntance.responseWebAccessTokenGetUserInfo(responseSuccess: { (objectSuccess) in
                APP_DELEGATE.currentUserInfo = objectSuccess as? UserInfoModel
                self.merchant = APP_DELEGATE.currentUserInfo?.merchant
                self.getMerchantDetail()
            }) { (error) in
            }
        } else {
            self.getMerchantDetail()
        }
        
        /// 注册接收消息通知
        // 接收用户的商户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoMerchantUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo_Merchant), object: nil)
        
    }
    
    
    // MARK: 用户的商户信息更新消息响应
    @objc func acceptUserInfoMerchantUpdateNotification(notification: Notification) {
        self.getMerchantDetail()
    }
    
    
    
    func setTableHeaderView() {
        if self.merchant == nil {
            return
        }
    
        self.showMerchantBgImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
        self.showMerchantImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
        self.showTitleLabel.text = self.merchant?.name
        self.showSubTitleLabel.text = self.merchant?.description
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
         return self.dataSource.count
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionArray = self.dataSource[section]
        
        return sectionArray.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MerchantCenterCell.CELL_ID) as! MerchantCenterCell
        
        cell.accessoryType = .disclosureIndicator
        cell.showSubTitleLabel.text = ""
        
        // 解析数据
        let dictData = self.dataSource[indexPath.section][indexPath.row]
        
        // image
        cell.showImageView.image = UIImage.init(named: dictData[DICT_IMAGE_PATH]!)
        
        // title
        cell.showTitleLabel.text = dictData[DICT_TITLE]
        
        if dictData[DICT_TITLE] == "我的钱包" {
            if self.merchant != nil {
                cell.showSubTitleLabel.text = String(format: "%.2f元", (self.merchant?.amount)!)
            } else {
                cell.showSubTitleLabel.text = "0.00元"
            }
        }
        
        
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let dictData = self.dataSource[indexPath.section][indexPath.row]
        
        if dictData[DICT_IDENTIFIER] == "" {
            return
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: dictData[DICT_IDENTIFIER]!)
        if dictData[DICT_IDENTIFIER] == "MerchantInformationView" {
            // 店铺详情
            let vc = viewController as! MerchantInformationViewController
            vc.merchant = self.merchant
            // 传入当前的定位的经纬度
            vc.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        }
        
        if dictData[DICT_IDENTIFIER] == "MerchantWalletView" {
            // 我的钱包
            let vc = viewController as! MerchantWalletViewController
            vc.merchant = self.merchant
        }
        
        if dictData[DICT_IDENTIFIER] == "CouponManageView" {
            // 优惠券管理
            let vc = viewController as! CouponManageViewController
            vc.merchant = self.merchant
        }
        
        if dictData[DICT_IDENTIFIER] == "TradeRecordListView" {
            // 交易流水
            let vc = viewController as! TradeRecordListViewController
            vc.merchant = self.merchant
        }
        
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MerchantCenterCell.CELL_HEIGHT
    }
    
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 10
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
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // 判断是否普通用户
        if APP_DELEGATE.currentUserInfo != nil && APP_DELEGATE.currentUserInfo?.roleCode != RoleCodeType.roleMerchant.rawValue {
           self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: 获取商家详细信息
    func getMerchantDetail() {
        MBProgressHUD.showMessage("", to: self.view)
        
        MerchantBusiness.shareIntance.responseWebGetMerchantDetail(merchantId: (self.merchant?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.merchant = objectSuccess as? MerchantModel
            self.setTableHeaderView()
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }

}
