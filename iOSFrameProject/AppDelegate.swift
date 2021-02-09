//
//  AppDelegate.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/15.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

@objc protocol AppDelegateCustomDelegate: NSObjectProtocol {
    
    // 方法可选 - 定位失败
    @objc optional func locationFailed(error: NSError)
    
    
    /// 支付结果返回
    ///
    /// - Parameter isPaySuccess: 是否支付成功
    @objc optional func payCenterOnResultWith(isPaySuccess: Bool)
    
    // MARK: 微信第三方登录回调
    @objc optional func weiXinThirdPartyLogin(resp: SendAuthResp)
    
    // MARK: applicationWillResignActive
    @objc optional func  appWillResignActive()
    // MARK: applicationDidEnterBackground
    @objc optional func  appDidEnterBackground()
    // MARK: applicationWillEnterForeground
    @objc optional func  appWillEnterForeground()
    // MARK: applicationDidBecomeActive
    @objc optional func  appDidBecomeActive()
    // MARK: applicationWillTerminate
    @objc optional func  appWillTerminate()

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AMapLocationManagerDelegate, WXApiDelegate, UNUserNotificationCenterDelegate, LMSTakePhotoControllerDelegate, JMTabBarControllerDelegate {
    

    var window: UIWindow?
    
    var jmTabBarViewController:  JMTabBarController?
    
    weak var customDelegate: AppDelegateCustomDelegate?     // 自定义代理
    
    var isCheckApp: Bool = false                             // 是否是App审核
    
    // location lazy
    private lazy var locationManager: AMapLocationManager = {
        let tempLocationManager = AMapLocationManager.init()
        
        // set accuracy
        tempLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // set location timeOut
        tempLocationManager.locationTimeout = 5
        // set reGeocode timeOut
        tempLocationManager.reGeocodeTimeout = 5
        // delegate
        tempLocationManager.delegate = self
        
        return tempLocationManager
    }()
    
    // 定位信息
    var locationAddress: AMapLocationReGeocode?
    
    // 首页当前的选择城市
    var currenctSelectedCity: String?
    
    // 实时天气信息
    var locationWeather: AMapLocalWeatherLive?
    
    var currentLivePm25: Int?

    var currentUserInfo: UserInfoModel?
    
    var cityRegionCodeDict: NSDictionary?
    
    var isNotFirstOpenApp: Bool?
    
    var carbonRuleList: [TaskModel] = []
    
    // 友盟推送userInfo
    var umUserInfo: [AnyHashable : Any]?
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
        
        // 添加引导页
//        GuideManager.images = [UIImage.init(named: "img_index_01")!, UIImage.init(named: "img_index_02")!, UIImage.init(named: "img_index_03")!]
//        GuideManager.dismissButtonImage = #imageLiteral(resourceName: "rightNow")
//
//        // page control
//        GuideManager.isShowPageControl = true
//        GuideManager.pageIndicatorColor = UIColor.white
//        GuideManager.currentIndicatorColor = UIColor.red
//
//        GuideManager.begin()
        
        
        // 设置自定义的tabBarController
        self.setCustomTabBarController()
        
        // 注册高德地图
        AMapServices.shared().apiKey = AMAP_API_KEY
        AMapServices.shared().enableHTTPS = false   // 是否开始 https协议  （ATS：App transport security）
        
        // 开始定位
        self.singleStartLocationOnce(locationSuccess: nil, locationFailed: nil)
        
        // 设置友盟分享
        UMSocialManager.default().openLog(true)
        UMConfigure.initWithAppkey(UM_SHARE_APP_KEY, channel: "App Store")
//        UMSocialManager.default().umSocialAppkey = UM_SHARE_APP_KEY
        // 设置微信分享
        UMSocialManager.default().setPlaform(.wechatSession, appKey: WEIXIN_APPID, appSecret: WEIXIN_APP_SECRET, redirectURL: nil)
        // 设置QQ分享
        UMSocialManager.default().setPlaform(.QQ, appKey: QQ_APPID, appSecret: QQ_APP_SECRET, redirectURL: "http://mobile.umeng.com/social")
        UMSocialManager.default().setPlaform(.qzone, appKey: QQ_APPID, appSecret: QQ_APP_SECRET, redirectURL: "http://mobile.umeng.com/social")
        
        // 设置新浪微博分享
        UMSocialManager.default().setPlaform(.sina, appKey: Weibo_APPID, appSecret: Weibo_APP_SECRET, redirectURL: "https://api.weibo.com/oauth2/default.html")
        
        
        // 设置友盟Key
        UMConfigure.initWithAppkey(UM_SHARE_APP_KEY, channel: "App Store")
        /* appkey: 开发者在友盟后台申请的应用获得（可在统计后台的 “统计分析->设置->应用信息” 页面查看）*/
        // 统计组件基本功能配置
        UMConfigure.setLogEnabled(true)
//        MobClick.setCrashReportEnabled(true)    // 开启Crash收集
        // 统计组件配置
//        MobClick.setScenarioType(.E_UM_NORMAL)
        
        
        // 友盟推送
        // Push组件基本功能配置
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        let entity = UMessageRegisterEntity.init()
        //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标等
        entity.types = Int(UInt8(UMessageAuthorizationOptions.badge.rawValue) | UInt8(UMessageAuthorizationOptions.alert.rawValue))
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if granted {
                // 用户选择了接收Push消息
            } else {
                // 用户拒绝接收Push消息
                myPrint(message: "用户拒绝接收Push消息")
            }
        }
        
        
        // 微信支付注册
        WXApi.registerApp(WEIXIN_APPID, universalLink: "")
        
//        // 获取当前App环境
        self.checkAppEnvirmentStatus()
        
        // 是否第一次打开App
        self.isNotFirstOpenApp = UserDefaults.standard.bool(forKey: "isNotFirstOpenApp")
//        self.isNotFirstOpenApp = false
        // 更新第一次打开状态
        UserDefaults.standard.set(true, forKey: "isNotFirstOpenApp")
////        // 切换语言  test
//        let lans = ["en"];
//        UserDefaults.standard.set(lans, forKey: "AppleLanguages")
        
        UserDefaults.standard.synchronize()
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        myPrint(message: "ResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        myPrint(message: "Background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        myPrint(message: "Foreground")
        if self.customDelegate?.appWillEnterForeground != nil {
            self.customDelegate?.appWillEnterForeground!()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.'
        myPrint(message: "BecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        myPrint(message: "Terminate")
    }
    
    //iOS10以下使用这两个方法接收通知，
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //关闭友盟自带的弹出框
        UMessage.setAutoAlert(false)
        if UIDevice.current.systemVersion < "10" {
            UMessage.didReceiveRemoteNotification(userInfo)
            self.umUserInfo = userInfo;
            self.customDisReceivePushData(userInfo: userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    
    // MARK: - iOS 10 or later 需要实现 UNUserNotificationCenterDelegate 的回调方法(如下),并在其中调用上述上报接口
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.customDisReceivePushData(userInfo: userInfo)
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.trigger is UNPushNotificationTrigger {
            //应用处于前台时的远程推送接受
            //关闭友盟自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(umUserInfo)
            self.customDisReceivePushData(userInfo: notification.request.content.userInfo)
        } else {
            //应用处于后台时的本地推送接受
            //当应用处于前台时提示设置，需要哪个可以设置哪一个
            completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.sound.rawValue) | UInt8(UNNotificationPresentationOptions.badge.rawValue) | UInt8(UNNotificationPresentationOptions.alert.rawValue))))
        }
    }

    
    // MARK: didReceive Push Data 处理
    func customDisReceivePushData(userInfo: [AnyHashable : Any]) {
        myPrint(message: "customDisReceivePushData userInfo: \(userInfo)")
        // 解析数据
        let apsData = userInfo["aps"] as! NSDictionary
        
        if apsData["alert"] == nil {
            // 静默推送
            myPrint(message: "静默推送")
            
            if userInfo["type"] !=  nil {
                let messageType = userInfo["type"] as! String
                let token = userInfo["token"] as! String
                let oldToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
                myPrint(message: "\(String(describing: oldToken?.removingPercentEncoding))")
                let userId = APP_DELEGATE.currentUserInfo?.id
                if userId == nil || oldToken == nil || oldToken == "" {return}
                
                myPrint(message: "type:\(messageType)   token: \(token)")
                if messageType == MessageTypeCode.loginExpire.rawValue {
                    // 登录过期
                    if token == oldToken {return}
                    // 1. 发送登录过期通知
                    OtherBusiness.shareIntance.responseWebRequestPublishLoginExpirePush(newToken: token, userId: APP_DELEGATE.currentUserInfo?.id, isProduct: false, responseSuccess: { (objectSuccess) in
                    }) { (error) in
                    } 
                }
            }

            return
        }
        
        // 判断系统消息开关状态
        if UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType.init(rawValue: 0) {
            // 已关闭
            return
        }
        
        // 消息类型
        if userInfo["type"] == nil { return }
        let messageType = userInfo["type"] as! String
        let alertData = apsData["alert"] as! NSDictionary
//        let xgInfo = userInfo["xg"] as! NSDictionary
        
        
        // 设置APP角标
        if apsData["badge"] != nil {
            let badgeNum = apsData["badge"] as! Int
            UIApplication.shared.applicationIconBadgeNumber = badgeNum
        }
        
        // 普通推送
        var newToken = ""
        if alertData["new_token"] != nil {
            newToken = alertData["new_token"]! as! String
        }
        if UIApplication.shared.applicationState == .active {
            // 前台收到消息
            self.messageForegroundDeal(newToken: newToken, messageType: messageType, title: alertData["title"]! as! String, body: alertData["body"]! as! String)
        } else {
            // 后台收到消息
            self.messageBackgroundDeal(newToken: newToken, messageType: messageType, title: alertData["title"]! as! String, body: alertData["body"]! as! String)
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }
    
    // MARK: messageForeground Deal
    func messageForegroundDeal(newToken: String, messageType: String, title: String, body: String) {
        if messageType == MessageTypeCode.loginExpire.rawValue {
            // 登录过期处理
            let currentToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
            if currentToken != newToken {
                // 发送用户在其它地方登录的广播
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
            }
        } else {
            // 前台收到消息
            let alertVC = UIAlertController.init(title: title, message: body, preferredStyle: .alert)
            alertVC.view.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
            // 取消
            alertVC.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (sender) in
                
            }))
            // 确定
            alertVC.addAction(UIAlertAction.init(title: "查看", style: .default, handler: { (sender) in
                UIApplication.shared.applicationIconBadgeNumber -= 1
                
                // 发送显示系统推送响应消息通知
                let pushMessage = NotificationMessageModel.init()
                pushMessage.messageType = messageType
                pushMessage.title = title
                pushMessage.body = body
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_SystemPushMessage), object: pushMessage)
                
                
            }))
            
            self.jmTabBarViewController?.selectedViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // MARK: messageBackground Deal
    func messageBackgroundDeal(newToken: String, messageType: String, title: String, body: String) {
        // 后台消息处理
        // 存储消息类型和状态
        if messageType == MessageTypeCode.loginExpire.rawValue {
            // 登录过期处理
            let currentToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
            if currentToken != newToken {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    // 发送用户在其它地方登录的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
                }
            }
            
            
        } else {
            // 发送显示系统推送响应消息通知
            let pushMessage = NotificationMessageModel.init()
            pushMessage.messageType = messageType
            pushMessage.title = title
            pushMessage.body = body
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_SystemPushMessage), object: pushMessage)
            }
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.description.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")
        token = token.replacingOccurrences(of: " ", with: "")
        myPrint(message: "deviceToken:\(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        myPrint(message: "error:\(error)")
    }
    
    
    
    // MARK: - 设置系统回调
    // MARK: 支持所有iOS系统
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        let result = UMSocialManager.default().handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
        if !result {
            // 其他如支付等SDK的回调
        }
        
        // 微信
        if url.scheme == WEIXIN_APPID {
            WXApi.handleOpen(url, delegate: self as WXApiDelegate)
        }
        
        // 支付宝
        if url.host! == ALIPAY_ReturnCheckStr {
            //跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                //跳转支付宝钱包进行支付，处理支付结果
                let resultDict = (resultDic! as NSDictionary)
                let isPaySuccess = Int(resultDict["resultStatus"] as! String) == 9000 ? true : false
                self.customDelegate?.payCenterOnResultWith!(isPaySuccess: isPaySuccess)
            })
        }
        
        
        return result
    }
    
    
    // 仅支持iOS9以上系统，iOS8及以下系统不会回调
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
        let result = UMSocialManager.default().handleOpen(url, options: options)
        if !result {
            // 其他如支付等SDK的回调
        }
        
        // 微信
        if url.scheme == WEIXIN_APPID {
            WXApi.handleOpen(url, delegate: self as WXApiDelegate)
        }
        
        // 支付宝
        myPrint(message: "host: \(url.host!)")
        if url.host! == ALIPAY_ReturnCheckStr {
            //跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                //跳转支付宝钱包进行支付，处理支付结果
                let resultDict = (resultDic! as NSDictionary)
                let isPaySuccess = Int(resultDict["resultStatus"] as! String) == 9000 ? true : false
                self.customDelegate?.payCenterOnResultWith!(isPaySuccess: isPaySuccess)
            })
        }
        
        
        return result
    }
    
    // 支持目前所有iOS系统
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let result = UMSocialManager.default().handleOpen(url)
        if !result {
            // 其他如支付等SDK的回调
        }
        
        // 微信
        if url.scheme == WEIXIN_APPID {
            WXApi.handleOpen(url, delegate: self as WXApiDelegate)
        }
        
        // 支付宝
        if url.host! == ALIPAY_ReturnCheckStr {
            //跳转支付宝钱包进行支付，处理支付结果
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                //跳转支付宝钱包进行支付，处理支付结果
                let resultDict = (resultDic! as NSDictionary)
                let isPaySuccess = Int(resultDict["resultStatus"] as! String) == 9000 ? true : false
                self.customDelegate?.payCenterOnResultWith!(isPaySuccess: isPaySuccess)
            })
        }
        
        return result
    }
    
    
    
    // MARK: - 微信的支付结果返回代理方法
    func onResp(_ resp: BaseResp) {
        if resp is BaseResp {
            var isPaySuccess = false
            switch resp.errCode {
            case WXSuccess.rawValue:
                isPaySuccess = true;
            case WXErrCodeUserCancel.rawValue:
                isPaySuccess = false;
            case WXErrCodeSentFail.rawValue:
                isPaySuccess = false;
            case WXErrCodeAuthDeny.rawValue:
                isPaySuccess = false;
            default:
                isPaySuccess = false;
            }
            self.customDelegate?.payCenterOnResultWith!(isPaySuccess: isPaySuccess)
        } else if resp is SendAuthResp {
            // 第三方登录
            self.customDelegate?.weiXinThirdPartyLogin!(resp: resp as! SendAuthResp)
        }
    }
    
    
    
    // MARK: single start location
    open func singleStartLocationOnce(locationSuccess: ((_ sender: AMapLocationReGeocode, _ location: CLLocation) -> Void)?, locationFailed: ((_ error: NSError?) -> Void)?) {
        self.locationManager.requestLocation(withReGeocode: true) { (location, reGeocode, error) in
            let errorTemp = error as NSError?
            if (error != nil) {
                myPrint(message: "\(String(describing: errorTemp?.code)) - \(String(describing: error?.localizedDescription))")
                
                // location fail
                if locationFailed != nil {
                    locationFailed!(errorTemp!)
                }
                return
            }
            
            // location success
            myPrint(message: "\(String(describing: location))")
            if (reGeocode != nil) {
                if locationSuccess != nil && location != nil {
                    // 保存当前的经纬度， 地址字符串
                    UserDefaults.standard.set(location?.coordinate.latitude, forKey: LOCATION_LATITUDE)
                    UserDefaults.standard.set(location?.coordinate.longitude, forKey: LOCATION_LONGTITUDE)
                    UserDefaults.standard.set(reGeocode?.formattedAddress, forKey: LOCATION_ADDRESS)
                    UserDefaults.standard.synchronize()  // 同步数据
                    
                    
                    locationSuccess!(reGeocode!, location!)
                }
                self.locationAddress = reGeocode
                myPrint(message: "\(String(describing: reGeocode))")
            } else {
                // location fail
                if locationFailed != nil {
                    locationFailed!(errorTemp!)
                }
            }
        }
    }
    
    
    // MARK: - JMTabBarControllerDelegate
    // MARK: willShowSelectView
    func willShowSelectViewDidSelect(_ selectIndex: Int) -> Bool {
        if selectIndex != 3 {
            // 我的
            return true
        }
        
        // 判断是否登录
        if self.currentUserInfo == nil {
            self.jumpToLoginViewContollerWithContoller(vc: (self.jmTabBarViewController?.selectedViewController)!, tipMess: nil, isShowCancal: nil)
            return false
        }

        // 判断临时用户升级
        if self.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: (self.jmTabBarViewController?.selectedViewController)!)
            return false
        }
        
        return true
    }
    
    
    // MARK: - LMSTakePhotoControllerDelegate
    // MARK:didFinishPickingImage
    func didFinishPickingImage(_ pickerImageView: LMSTakePhotoController!, take previewImage: UIImage!) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "AddWaterMarkView") as! AddWaterMarkViewController
        viewController.originImage = previewImage
        pickerImageView.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 设置自定义的TabBarController
    func setCustomTabBarController() {
        let titleArr = ["实景", "视觉", "发现", "我的"]
        let imagesNomal = ["tab1_nor", "tab2_nor", "tab3_nor", "tab4_nor"]
        let imagesSelect = ["tab1_sel", "tab2_sel", "tab3_sel", "tab4_sel"]
        
        var controllersArr: [UIViewController] = []
        let storyBorad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        for (i,item) in titleArr.enumerated() {
            myPrint(message: item)
            if i == 0 {
                let homeNav = storyBorad.instantiateViewController(withIdentifier: "home_nav")
                controllersArr.append(homeNav)
            } else {
                let otherViewController = storyBorad.instantiateViewController(withIdentifier: "tabVC" + String(i))
                let nav = BaseNavigationController.init(rootViewController: otherViewController)
                controllersArr.append(nav)
            }
        }
        
        // 初始化配置信息
        let config = JMConfig.share()
        config?.isClearTabBarTopLine = false
        config?.tabBarTopLineColor = COLOR_SEPARATOR_LINE
        // 效果动画
        config?.tabBarAnimType = JMConfigTabBarAnimType.boundsMin
        
        self.jmTabBarViewController = JMTabBarController.init(tabBarControllers: controllersArr , norImageArr: imagesNomal, selImageArr: imagesSelect, titleArr: titleArr, config: config)
        
        // 中间的按钮
        let cameraBtn = UIButton.init(type: UIButton.ButtonType.custom)
        cameraBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        cameraBtn.setImage(#imageLiteral(resourceName: "add"), for: UIControl.State.normal)
        config?.addCustomBtn(cameraBtn, at: 2, btnClick: { (btn, index) in
            myPrint(message: "拍照点击")
            self.takePhotoBtnClick(viewController: (self.jmTabBarViewController?.selectedViewController)!, btn!)
        })
        self.jmTabBarViewController?.mmDelegate = self
        self.window?.rootViewController = self.jmTabBarViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    
    // MARK: 拍照点击
    func takePhotoBtnClick(viewController: UIViewController, _ sender: UIButton) {
        // 判断用户是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: viewController, tipMess: "请登录", isShowCancal: nil)
            return
        }
        // 判断是否是临时用户
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: viewController)
            return
        }
        
        // 正式调用
        let takePhotoVC = LMSTakePhotoController.init()
        if !takePhotoVC.isCameraAvailable || !takePhotoVC.isAuthorizedCamera {
            let alertViewController = UIAlertController.init(title: "未获取到拍照权限", message: "请在（设置->隐私->相机->250你发布）中开启", preferredStyle: .alert)
            // 取消
            alertViewController.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { (alertAction) in
                // 跳转到设置
                UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
            }))
            viewController.present(alertViewController, animated: true, completion: nil)
            
            return;
        }
        
        //注释以下两行其中一行可以切换前置或者后置摄像头
        takePhotoVC.position = .back;
        //p.position = TakePhotoPositionFront;
        
        //注释以下两行其中一行可以实现身份证正面照拍摄或者背面照拍摄
        //    p.functionType = TakePhotoIDCardFrontType;
        //    p.functionType = TakePhotoIDCardBackType;
        
        takePhotoVC.delegate = self;
        takePhotoVC.allowPreview = false
        
        let navigationVC = UINavigationController.init(rootViewController: takePhotoVC)
        MBProgressHUD.showMessage("", to: viewController.view)
        viewController.present(navigationVC, animated: true) {
            MBProgressHUD.hide(for: viewController.view, animated: true)
        }
    }
    
    
    // MARK: 跳转登录界面
    func jumpToLoginViewContollerWithContoller(vc: UIViewController, tipMess: String?, isShowCancal: Bool?) {
        
        // 跳转登录界面
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
        let userIconUrlStr = APP_DELEGATE.currentUserInfo?.avatar
        viewController.userAvatarUrl = userIconUrlStr ?? ""
        viewController.isShowCancelButton = isShowCancal == nil ? true : isShowCancal!
        let nav = UINavigationController.init(rootViewController: viewController)
        vc.present(nav, animated: true) {
            // 提示：信息
            if tipMess != nil {
                self.alertCommonShow(title: "提示", message: tipMess!, btn1Title: "确定", btn2Title: nil, vc: viewController, buttonClick: {_ in})
            }
        }
    }
    
    
    // MARK: 跳转用户升级界面
    func jumpToUserUpdateViewContoller(vc: UIViewController) {
        // 跳转登录界面
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChangePwdView") as! ChangePwdViewController
        viewController.defaultInputText = ""
        viewController.title = "用户升级"
        viewController.isShowOtherUserLoginBtn = true
        viewController.changeType = ChangePwdType.userUpdate
        vc.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    // MARK: 显示获取的碳币数的提醒ViewController
    func showCarbonCoinCountTipWith(carbonCoinCount: Int, awardReason: String, vc: UIViewController) {
        let viewController = CarbonGetCoinTipViewController.init(nibName: "CarbonGetCoinTipViewController", bundle: nil)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        viewController.carbonCoinCount = carbonCoinCount
        viewController.carbonCoinGetDesciption = awardReason
        vc.present(viewController, animated: true, completion: nil)
    }
    

    
    // MARK: 获取App当前环境（是审核状态，还是正式使用状态）
    func checkAppEnvirmentStatus() {
        let parameters = ["buildVersion" : "\(String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!))"]
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: "/appleVerify/verify", parameters: parameters as NSDictionary, resquestType: .GET, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 解析数据
            let isWebCheck = responseObject as! Bool
            
            // 判断数据
            
            if isWebCheck {
                self.isCheckApp = true
            } else {
                self.isCheckApp = false
            }
            
        }) { (error) in
            self.isCheckApp = false
            myPrint(message: error)
        }
    }
    
    
    // MARK: 公共弹窗
    func alertCommonShow(title: String, message: String, btn1Title: String, btn2Title: String?, vc: UIViewController?, buttonClick: @escaping (_ btnIndex: Int) -> ()) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.view.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        // button 1
        
        alertVC.addAction(UIAlertAction.init(title: btn1Title, style: .cancel, handler: { (sender) in
            buttonClick(0)
        }))
        // button 2
        if btn2Title != nil {
            alertVC.addAction(UIAlertAction.init(title: btn2Title!, style: .default, handler: { (sender) in
                buttonClick(1)
            }))
        }
        
        if vc == nil {
            self.jmTabBarViewController?.selectedViewController?.present(alertVC, animated: true, completion: nil)
        } else {
            vc?.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
}

