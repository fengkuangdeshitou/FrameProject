//
//  MineViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SDWebImage
import WebKit

class MineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    fileprivate var dataSource: [Array<[String : String]>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showUserImageView: UIImageView!
    
    @IBOutlet weak var showUserNameLabel: UILabel!
    
    @IBOutlet weak var showDescriptionLabel: UILabel!
    
    @IBOutlet weak var carbonCoinBtn: UIButton!     // 碳币
    
    
    
    @IBOutlet weak var showSenceView: UIView!
    @IBOutlet weak var showAttentionView: UIView!
    @IBOutlet weak var showFansView: UIView!
    
    @IBOutlet weak var senceCountLabel: UILabel!
    
    @IBOutlet weak var attentionCountLabel: UILabel!
    
    @IBOutlet weak var fansCountLabel: UILabel!
    
    var carbonCoinShowCount: Int?       // 要显示碳币数
    
    // 红点view
    fileprivate lazy var showCoinTaskRedDotView: UIView = {
        let view = UIView.init(frame: CGRect(x: self.carbonCoinBtn.width - 10, y: 0, width: 10, height: 10))
        view.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5.0
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "我的"
        self.setInitDatSource()
        
        
        /// 设置响应事件
        // 设置点击用户头像点击事件
        self.showUserImageView.isUserInteractionEnabled = false
        self.showUserImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let modelOne = LWImageBrowserModel.init(placeholder: #imageLiteral(resourceName: "defaultUserImage"), thumbnailURL: URL.init(string: WEBBASEURL_IAMGE + (APP_DELEGATE.currentUserInfo?.avatar)!), hdurl: URL.init(string: WEBBASEURL_IAMGE + (APP_DELEGATE.currentUserInfo?.avatar)!), containerView: self.tableView.tableHeaderView, positionInContainer: self.showUserImageView.frame, index: 0)
            
            let browser = LWImageBrowser.init(imageBrowserModels: [modelOne!], currentIndex: 0)
            browser?.show()
        }))
        
        // 设置昵称点击响应
        self.showUserNameLabel.isUserInteractionEnabled = true
        self.showUserNameLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineInformationView") as! MineInformationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        // 设置说说点击响应
        self.showDescriptionLabel.isUserInteractionEnabled = true
        self.showDescriptionLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineInformationView") as! MineInformationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        
        // 设置实景点击响应
        self.showSenceView.isUserInteractionEnabled = true
        self.showSenceView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
            viewController.userInfo = APP_DELEGATE.currentUserInfo
            viewController.currentIndex = 0
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        // 设置关注响应
        self.showAttentionView.isUserInteractionEnabled = true
        self.showAttentionView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
            viewController.userInfo = APP_DELEGATE.currentUserInfo
            viewController.currentIndex = 1
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        // 设置粉丝点击响应
        self.showFansView.isUserInteractionEnabled = true
        self.showFansView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
            viewController.userInfo = APP_DELEGATE.currentUserInfo
            viewController.currentIndex = 2
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        
        // 设置导航栏
        let rihtBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "mine_setting.png"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.rightBarButtonItem = rihtBarBtnItem
        
        // set Table View
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -NAVIGATION_AND_STATUS_HEIGHT, right: 0)
        
        // 获取用户信息
        if APP_DELEGATE.currentUserInfo == nil {
            UserBusiness.shareIntance.responseWebLoginByDeviceId(deviceId: (UIDevice.current.identifierForVendor?.uuidString)!, responseSuccess: { (objectSuccess) in
                APP_DELEGATE.currentUserInfo = objectSuccess as? UserInfoModel
                self.setTableViewHeaderView()
            }) {(error) in
            }
        } else {
            self.setTableViewHeaderView()
        }
        
        
        // 判断是否任务完成
        var allCoinCount = 0    // 总可以获取的碳币数
        var doneCoinCount = 0   // 已获取的碳币数
        for taskInfo in APP_DELEGATE.carbonRuleList {
            taskInfo.coinCount =  taskInfo.coinCount == nil ? 0 : taskInfo.coinCount
            taskInfo.limitCount =  taskInfo.limitCount == nil ? 0 : taskInfo.limitCount
            taskInfo.finishCount =  taskInfo.finishCount == nil ? 0 : taskInfo.finishCount
            
            allCoinCount += taskInfo.coinCount! * taskInfo.limitCount!
            doneCoinCount += taskInfo.coinCount! * taskInfo.finishCount!
        }
        self.showCoinTaskRedDotView.isHidden = allCoinCount == doneCoinCount ? true : false
        
        
        
        
        /// 注册接收消息通知
        // 接收用户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        // 接收碳币任务更新的消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserCoinTaskUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_CoinTaskUpdate), object: nil)
    }
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserInfoUpdateNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        
        if userInfo == nil {
            self.setTableViewHeaderView()
        }
    }
    
    // MARK: 用户碳币任务更新的消息通知响应
    @objc func acceptUserCoinTaskUpdateNotification(notification: Notification) {
        let coinTaskType = notification.object as! String
        
        if coinTaskType == CoinTaskUpdateType.mineVC.rawValue {
            // 任务完成
            self.showCoinTaskRedDotView.isHidden = true
        } else if coinTaskType == CoinTaskUpdateType.updateCoinCount.rawValue {
            // 查询系统碳币数情况(更新用户信息）
            if APP_DELEGATE.currentUserInfo == nil {return}
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (objectSuccess) in
                APP_DELEGATE.currentUserInfo = objectSuccess as? UserInfoModel
                self.setTableViewHeaderView()
            }, responseFailed: { (error) in
            })
        }
    }
    
    // set dataSource
    func setInitDatSource() {
        self.dataSource = [[[DICT_IMAGE_PATH : "mine_order", DICT_TITLE : "我的订单", DICT_IDENTIFIER : "MineOrderView"],
                            [DICT_IMAGE_PATH : "mine_coupon", DICT_TITLE : "我的优惠券", DICT_IDENTIFIER : "MineCouponListView"]],
                           
                           [[DICT_IMAGE_PATH : "mine_user_info", DICT_TITLE : "个人信息", DICT_IDENTIFIER : "MineInformationView"],
                            [DICT_IMAGE_PATH : "mine_homepage", DICT_TITLE : "个人主页", DICT_IDENTIFIER : "MineHomePageView"]],
                           
                           [[DICT_IMAGE_PATH : "mine_support", DICT_TITLE : "我点赞的照片", DICT_IDENTIFIER : "MineSupportPhotoView"],
                            [DICT_IMAGE_PATH : "mine_attention", DICT_TITLE : "我关注的人", DICT_IDENTIFIER : "MineAttentionView"]],
                           
                           [[DICT_IMAGE_PATH : "mine_clear_cache", DICT_TITLE : "清除缓存", DICT_IDENTIFIER : ""]]]
        
        // 商户中心
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleMerchant.rawValue {
            self.dataSource.insert([[DICT_IMAGE_PATH : "mine_merchant_center", DICT_TITLE : "商家中心", DICT_IDENTIFIER : "MerchantCenterView"]], at: 0)
        } else {
            self.dataSource.insert([[DICT_IMAGE_PATH : "mine_merchant_center", DICT_TITLE : "商家入驻", DICT_IDENTIFIER : "RegisterMerchantView"]], at: 0)
        }
    }
    
    
    // MARK: set TableView HeaderView
    func setTableViewHeaderView() {
        self.setInitDatSource()
        
        
        // 设置用户头像
        self.showUserImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (APP_DELEGATE.currentUserInfo?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        self.showUserImageView.layer.masksToBounds = true
        self.showUserImageView.layer.cornerRadius = CORNER_NORMAL
        
        // set user Name
        self.showUserNameLabel.text = APP_DELEGATE.currentUserInfo?.nickname
        
        // 设置碳币余额
        self.carbonCoinBtn.setTopAndBottomImage(#imageLiteral(resourceName: "mine_carbon_coin"), withTitle: "\((APP_DELEGATE.currentUserInfo?.coinAmount)!)", for: .normal, andTintColor: COLOR_CARBON_COIN, withTextFont: self.carbonCoinBtn.titleLabel?.font, andImageTitleGap: 20)
        self.carbonCoinBtn.setTitleColor(COLOR_CARBON_COIN, for: .normal)
        self.carbonCoinBtn.titleLabel?.textColor = COLOR_CARBON_COIN
        self.carbonCoinBtn.addSubview(self.showCoinTaskRedDotView)
        
        // 设置描述
        self.showDescriptionLabel.text = APP_DELEGATE.currentUserInfo?.speak
        
        // 实景数
        self.senceCountLabel.text = "\(String(describing: (APP_DELEGATE.currentUserInfo?.publishPhotoAmount ?? 0)!))"
        // 关注数
        self.attentionCountLabel.text = "\(String(describing: (APP_DELEGATE.currentUserInfo?.attentionAmount ?? 0)!))"
        // 粉丝数
        self.fansCountLabel.text = "\(String(describing: (APP_DELEGATE.currentUserInfo?.followAmount ?? 0)!))"
        
        self.tableView.reloadData()
    }
    
    
    // MARK: leftBarBtnItem Click
    func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SettingView")
        self.navigationController?.pushViewController(viewController!, animated: true)
        
    }
    
    
    // MARK: - UITableView 代理方法的实现
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MineTableViewCell
        cell.accessoryType = .disclosureIndicator
        cell.showDetailLabel.text = ""
        
        // 解析数据
        let dictData = self.dataSource[indexPath.section][indexPath.row]
        
        // 设置消息红点
        cell.showRedDotView.isHidden = true
        
        // image
        cell.showImageView.image = UIImage.init(named: dictData[DICT_IMAGE_PATH]!)
        
        // title
        cell.showTitleLabel.text = dictData[DICT_TITLE]
        
        if dictData[DICT_TITLE] == "清除缓存" {
            cell.accessoryType = .none
            
            cell.showDetailLabel.text = NSString.fileSize(withInterge: Int(SDImageCache.shared().getSize()))
        }
        
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 解析数据
        let dictData = self.dataSource[indexPath.section][indexPath.row]
        
        if dictData[DICT_TITLE] == "清除缓存" {
            // 清除WebView 缓存
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
            // 清除iOS 9 以上的 WKWebView缓存
            self.clearWKWebViewCache()
            
            // 清除磁盘缓存
            SDImageCache.shared().cleanDisk()
            SDImageCache.shared().clearDisk()
            self.tableView.reloadData()
            MBProgressHUD.showSuccess("清除缓存成功", to: self.view)
        }
        
        
        if dictData[DICT_IDENTIFIER] != "" {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: dictData[DICT_IDENTIFIER]!)
            
            if dictData[DICT_IDENTIFIER] == "MineHomePageView" {
                // 个人主页
                let homePageVC = viewController as! MineHomePageViewController
                homePageVC.userInfo = APP_DELEGATE.currentUserInfo
            }
            
            if dictData[DICT_IDENTIFIER] == "MerchantCenterView" {
                // 商户中心
                let merchantCenterVC = viewController as! MerchantCenterViewController
                merchantCenterVC.merchant = APP_DELEGATE.currentUserInfo?.merchant
            }
            
            self.navigationController?.pushViewController(viewController!, animated: true)
            
        }
        
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CELL_NORMAL_HEIGHT+1
    }
    
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: section Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    // MARK: carbon conin button Click
    @IBAction func carbonCoinBtnClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "CarbonTaskView") as! CarbonTaskViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置导航栏
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }

    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 是否显示获取碳币的照片
        if self.carbonCoinShowCount != nil {
            APP_DELEGATE.showCarbonCoinCountTipWith(carbonCoinCount: self.carbonCoinShowCount!, awardReason: "新用户", vc: self)
            self.carbonCoinShowCount = nil
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: view did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // 清除WKWebView 的缓存
    func clearWKWebViewCache() {
        let dateFrom: NSDate = NSDate.init(timeIntervalSince1970: 0)

        if #available(iOS 9.0, *) {
            let websiteDataTypes: NSSet = WKWebsiteDataStore.allWebsiteDataTypes() as NSSet
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: dateFrom as Date) {
                print("清空缓存完成")
            }
        } else {
            let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as NSString
            let cookiesFolderPath = libraryPath.appending("/Cookies")
            try? FileManager.default.removeItem(atPath: cookiesFolderPath)
        }
    }
    
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
}
