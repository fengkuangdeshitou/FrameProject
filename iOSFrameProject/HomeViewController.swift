//
//  ViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/15.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

public enum ESRefreshExampleType {
    case defaulttype, meituan, wechat
}

public enum ESRefreshExampleListType {
    case tableview, collectionview
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, LPBannerViewDelegate, HomeHeaderViewDelegate, AddressPickerDemoDelegate, EditPhotoViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AMapSearchDelegate, WeatherViewDelegate, NewFunctionTipViewDelegate, SYStickHeaderWaterFallDelegate, QQScanViewDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    private var isShowLoginView = false
    
    fileprivate let NAV_USER_WH:CGFloat = 37.0              // 导航栏上用户头像大小
    fileprivate var currentButton = 0       // 当前所示的按钮索引
    
    fileprivate var isAutoShowWeatherAlert: Bool = true     // 是否自动显示天气窗口
    fileprivate var isWeatherBtnClick:Bool = false          // 是否是天气按钮点击
    
    // map search api
    fileprivate lazy var mapSearch: AMapSearchAPI = {
        let mapSearchTemp = AMapSearchAPI.init()
        mapSearchTemp?.delegate = self
        return mapSearchTemp!
    }()
    
    fileprivate lazy var goToTopBtn: UIButton = {
        let goToTopBtnTemp = UIButton.init(type: UIButton.ButtonType.custom)
        goToTopBtnTemp.backgroundColor = UIColor.red
        
        return goToTopBtnTemp
    }()
    fileprivate var collectView: UICollectionView?
    fileprivate var reusableView: UICollectionReusableView?
    fileprivate var headView: HomeHeaderView?
    
    // menu buttons
    fileprivate let menuButtonsViewHeight:CGFloat = 75.0
    fileprivate lazy var menuButtonsView: UIView = {
        let menuButtonsViewTemp = UIView.init(frame: CGRect(x: 0, y: self.adverViewHeight, width: SCREEN_WIDTH, height: self.menuButtonsViewHeight))
        menuButtonsViewTemp.backgroundColor = UIColor.white
        
        // 设置 实景墙  排行榜 添加关注 等按钮
        let senceWallBtn = UIButton.init(type: UIButton.ButtonType.custom)
        senceWallBtn.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH/3, height: menuButtonsViewTemp.height - 10.0)
        senceWallBtn.setTopAndBottomImage(#imageLiteral(resourceName: "home_sence_wall"), withTitle: NSLocalizedString("senceWall", comment: ""), for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: FONT_SMART_SIZE), andImageTitleGap: 20.0)
        senceWallBtn.addTarget(self, action: #selector(senceWallBtnClick(_:)), for: UIControl.Event.touchUpInside)
        menuButtonsViewTemp.addSubview(senceWallBtn)
        
        let rankBtn = UIButton.init(type: UIButton.ButtonType.custom)
        rankBtn.frame = CGRect(x: SCREEN_WIDTH/3 * 1, y: 0, width: SCREEN_WIDTH/3, height: menuButtonsViewTemp.height - 10.0)
        rankBtn.setTopAndBottomImage(#imageLiteral(resourceName: "home_rank"), withTitle: NSLocalizedString("rank", comment: ""), for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: FONT_SMART_SIZE), andImageTitleGap: 20.0)
        rankBtn.addTarget(self, action: #selector(rankBtnClick(_:)), for: UIControl.Event.touchUpInside)
        menuButtonsViewTemp.addSubview(rankBtn)
        
        let addAttentionBtn = UIButton.init(type: UIButton.ButtonType.custom)
        addAttentionBtn.frame = CGRect(x: SCREEN_WIDTH/3 * 2, y: 0, width: SCREEN_WIDTH/3, height: menuButtonsViewTemp.height - 10.0)
        addAttentionBtn.setTopAndBottomImage(#imageLiteral(resourceName: "home_addAttention"), withTitle: NSLocalizedString("addAttention", comment: ""), for: .normal, andTintColor: COLOR_GAY, withTextFont: UIFont.systemFont(ofSize: FONT_SMART_SIZE), andImageTitleGap: 20.0)
        addAttentionBtn.addTarget(self, action: #selector(addAttentionBtnClick(_:)), for: UIControl.Event.touchUpInside)
        menuButtonsViewTemp.addSubview(addAttentionBtn)
        
        // 分割块
        let separatorPieceView = UIView.init(frame: CGRect(x: 0, y: addAttentionBtn.height, width: SCREEN_WIDTH, height: 10.0))
        separatorPieceView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
        // 分割线 top
        let separatorLineView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0.5))
        separatorLineView.backgroundColor = COLOR_SEPARATOR_LINE
        separatorPieceView.addSubview(separatorLineView)
        
        menuButtonsViewTemp.addSubview(separatorPieceView)
        
        return menuButtonsViewTemp
    }()
    
    
    fileprivate var scrollImageView: UIView!
    
    
    @IBOutlet weak var selectedCityBtn: UIButton!
    
    @IBOutlet weak var weatherBtn: UIButton!
    
    
    @IBOutlet weak var userIconContentView: UIView!
    
    // 懒加载 --- 拍照按钮点击
    fileprivate lazy var takePhotoBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect(x: (SCREEN_WIDTH - 62)/2, y: SCREEN_HEIGHT - 80 - NAVIGATION_AND_STATUS_HEIGHT, width: 62, height: 62))
        
        btn.setImage(UIImage.init(named: "take_photo_icon"), for: UIControl.State.normal)
        btn.addTarget({ (sender) in
            APP_DELEGATE.takePhotoBtnClick(viewController: self, sender!)
        }, andEvent: UIControl.Event.touchUpInside)
        
        return btn
    }()
    
    
    fileprivate var rightNavBtn: UIButton?              // 导航栏上右边的按钮
    
    fileprivate var messageBtnRedDotView: UIView?      // 消息上的红点
    
    
    fileprivate var adverViewHeight:CGFloat = 0         // 广告轮播的高度
    
    // data
    var dataSource: [PhotoModel] = []    // cell list data
    var scrollImagesDataSource: [SubjectModel] = [] // subject Data
    
    var popDelegate: UIGestureRecognizerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setViewUI()
        
        // set collectionView
        self.initCollectionView()
        
        // 检测版本更新
        // MARK: 监测250平台的更新
        self.customCheck250PublishUpdate()
        
//        // 添加拍照按钮
//        self.view.addSubview(self.takePhotoBtn)
        
        // 上传应用数据统计
        OtherBusiness.shareIntance.responseWebPublishAppInCommonData(userId: APP_DELEGATE.currentUserInfo?.id, responseSuccess: { (objectSuccess) in
        }, responseFailed: { (error) in
        })
    }
    
    // MARK: initCollectionView
    func initCollectionView() {
        let cvLayout = SYStickHeaderWaterFallLayout.init()
        cvLayout.delegate = self
//    cvLayout.itemWidth = (kDeviceWidth-15)/2;
//    cvLayout.topInset = 0.0f;
//    cvLayout.bottomInset = 0.0f;
        cvLayout.isStickyHeader = true
        
        self.collectView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - NAVIGATION_AND_STATUS_HEIGHT - TOOL_BAR_HEIGHT), collectionViewLayout: cvLayout)
        self.collectView?.alwaysBounceVertical = true       // 总是显示bounce
        self.collectView?.delegate = self
        self.collectView?.dataSource = self
        self.collectView?.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        self.view.addSubview(self.collectView!)
//        self.view.insertSubview(self.goToTopBtn, aboveSubview: self.collectView!)
        
        self.collectView?.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: IMAGE_COLLECTION_CELL)
        self.collectView?.register(HomeHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HOME_HEADER_ID)
        
        self.collectView?.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        self.collectView?.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "head")
        
        // 设置刷新
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.collectView!, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
    }
    
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserInfoUpdateNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        
        if userInfo == nil {
//            self.setUserIconImage()
        }
        // 判断消息状态
        self.checkMessageReadStatus()
    }
    
    
    // MARK: 图片信息更新消息通知响应
    @objc func acceptPhotoInfoUpdateNotification(notification: Notification) {
        let photoInfo = notification.object as? PhotoModel
        
        if photoInfo == nil {
            // 设置用户头像
            self.refresh()
        } else {
            for item in self.dataSource {
                if item.id == photoInfo?.id {
                    item.description = photoInfo?.description
                    item.dehazePhoto = photoInfo?.dehazePhoto
                    item.thumbPhoto = photoInfo?.thumbPhoto
                    item.likeCount = photoInfo?.likeCount
                    item.isLike = photoInfo?.isLike
                }
            }
            self.collectView?.reloadData()
        }
    }
    
    // MARK: 用户登录在其它地方的消息通知响应
    @objc func acceptUserOtherLoginNotification(notification: Notification) {
//        if self.isShowLoginView { return }
//        self.isShowLoginView = true
        
//        // 清空本地用户登录信息 和 全局当前登录用户
        self.messageBtnRedDotView?.isHidden = true
        // 解绑推送
        if APP_DELEGATE.currentUserInfo != nil {
            UMessage.removeAlias((APP_DELEGATE.currentUserInfo?.id)!, type: UM_ALIAS_TYPE, response: { (object, error) in
                myPrint(message: "addAliasError: \(String(describing: error))")
            })
        }
        APP_DELEGATE.currentUserInfo = nil
        UserDefaults.standard.set(nil, forKey: DICT_USER_INFO)
        UserDefaults.standard.set("", forKey: ACCESS_TOKEN)
        UserDefaults.standard.synchronize()
        
        // 清空
        
        // 跳转登录界面
        self.dismiss(animated: false, completion: nil)
        APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: OTHER_LOGING_TIP, isShowCancal: false)
    }
    
    // MARK: 用户碳币任务更新的消息通知响应
    @objc func acceptUserCoinTaskUpdateNotification(notification: Notification) {
        let coinTaskType = notification.object as! String
        
        if coinTaskType == CoinTaskUpdateType.homeVC.rawValue {
            // 碳币任务完成
        } else if coinTaskType == CoinTaskUpdateType.updateCoinCount.rawValue {
            // 查询系统碳币数情况(更新用户信息）
            if APP_DELEGATE.currentUserInfo == nil {return}
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (objectSuccess) in
            }, responseFailed: { (error) in
            })
        }
    }
    
    
    // MARK: 接收App消息全部已读通知响应
    @objc func acceptUserMessageAllReadUpdateNotification(notification: Notification) {
        let isAllRead = UserDefaults.standard.bool(forKey: DICT_IS_MESSAGE_ALL_READED)
        self.messageBtnRedDotView?.isHidden = isAllRead
    }
    
    // MARK: 接收系统推送消息通知响应
    @objc func acceptUserSystemPushMessageNotification(notification: Notification) {
        if notification.object == nil {return}
        
        
//        let pushMessage = notification.object as! NotificationMessageModel
        
        self.messageBtnRedDotView?.isHidden = false
        // 消息通知列表
        if self.navigationController?.visibleViewController is MessageListViewController {
            let messageVC = self.navigationController?.visibleViewController as! MessageListViewController
            messageVC.refresh()
        } else {
            var viewController: MessageListViewController?
            for vc in (self.navigationController?.viewControllers)! {
                if vc is MessageListViewController {
                    viewController = vc as? MessageListViewController
                    viewController?.refresh()
                    break
                }
            }
            let myFatherVC = APP_DELEGATE.jmTabBarViewController?.selectedViewController as! UINavigationController
            if viewController == nil {
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                viewController = storyBoard.instantiateViewController(withIdentifier: "MessageListView") as? MessageListViewController
                myFatherVC.pushViewController(viewController!, animated: true)
            } else {
                myFatherVC.popViewController(animated: true)
            }
        }
        
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        
        // 获取天气数据
        self.getWeatherData()
        if APP_DELEGATE.currenctSelectedCity == nil {
            APP_DELEGATE.singleStartLocationOnce(locationSuccess: { (locationReGeocode, location) in
                // 定位成功
                APP_DELEGATE.locationAddress = locationReGeocode
                self.setLocationBtnShowText(cityName: locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY)
                
                // 获取网络数据
                self.getSenceListData(selectedCity: locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY, buttonIndex: 0, pageCount: self.page)
                
                // MARK: 获取主题列表数据
                self.getSubjectListData()
                // MARK: 检测消息状态
                self.checkMessageReadStatus()
                
                // 获取天气数据
                APP_DELEGATE.currenctSelectedCity = locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY
                self.getWeatherData()
            }) { (error) in
                // 定位失败
                self.setLocationBtnShowText(cityName: DEFAULT_LOCATIONFAILED_CITY)
                MBProgressHUD.show("未获取到定位城市", icon: nil, view: self.view)
                
                // 获取网络数据
                self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: self.currentButton, pageCount: self.page)
                // MARK: 获取主题列表数据
                self.getSubjectListData()
                // MARK: 检测消息状态
                self.checkMessageReadStatus()
                
            }
        } else {
            // 获取网络数据
            self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: self.currentButton, pageCount: self.page)
            // MARK: 获取主题列表数据
            self.getSubjectListData()
            // MARK: 检测消息状态
            self.checkMessageReadStatus()
        }
        
        
        
        // 停止刷新
        MBProgressHUD.showMessage("", to: self.collectView)
        self.collectView?.isScrollEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.collectView?.isScrollEnabled = true
            MBProgressHUD.hide(for: self.collectView, animated: true)
            self.collectView?.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: self.currentButton, pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.collectView?.es.stopLoadingMore()
        }
    }
    
    
    // MARK:  设置导航栏样式
    func setNavigationStyle() {
//        self.automaticallyAdjustsScrollViewInsets = true
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    
    // MARK: setUserIconImage
    func setUserIconImage() {
        if APP_DELEGATE.currentUserInfo == nil {return}
        // 设置用户头像
        self.rightNavBtn?.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (APP_DELEGATE.currentUserInfo?.avatar)!), for: .normal, completed: { (image, error, cacheType, imageUrl) in
            if image != nil {
                self.rightNavBtn?.setImage(UIImage.scal(toSize: image, size: CGSize(width: self.NAV_USER_WH, height: self.NAV_USER_WH)), for: .normal)
            } else {
                self.rightNavBtn?.setImage(UIImage.scal(toSize: #imageLiteral(resourceName: "defaultUserImage"), size: CGSize(width: self.NAV_USER_WH, height: self.NAV_USER_WH)), for: .normal)
            }
        })
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        // 判断用户是否登录、
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        
        myPrint(message: "扫一扫")
        let vc = QQScanViewController()
        var style = LBXScanViewStyle()
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_light_red")
        vc.scanStyle = style
        vc.delegate = self
        vc.title = "扫码付款"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: right nav Btn Item Click
    @objc func rightNavBtnClick(sender: UIButton) {
        // 判断用户是否登录、
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        // 消息通知列表
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageListView") as! MessageListViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 设置定位按钮显示
    func setLocationBtnShowText(cityName: String) {
        if cityName == APP_DELEGATE.locationAddress?.city {
            // 所选为定位城市
            self.selectedCityBtn.setImage(#imageLiteral(resourceName: "home_location_icon"), for: .normal)
            self.selectedCityBtn.setTitle(cityName, for: .normal)
        } else {
            self.selectedCityBtn.setImage(nil, for: .normal)
            self.selectedCityBtn.setTitle(cityName, for: .normal)
        }
    }
    
    // MARK: 设置广告轮播图片
    func homeScrollImagesWithArray(subjectArray: [String]) {
        if subjectArray.count == 0 {
            return
        }
        
        let bannerView = LPBannerView(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: adverViewHeight))
        bannerView.delegate = self
        bannerView.placeholderImage = DEFAULT_IMAGE()
        bannerView.isAutoScroll = true
        bannerView.backgroundColor = UIColor.white
        bannerView.autoScrollTimeInterval = 3.0
        bannerView.pageDotColor = UIColor.init(white: 1.0, alpha: 0.5)
        bannerView.pageContolAliment = .right
        UIView.removeSubviews(self.scrollImageView)
//        tools.removeSubviews(self.scrollImageView)
        self.scrollImageView.addSubview(bannerView)

        // 异步网络请求得到相关数据之后赋值刷新
        bannerView.imagePaths = subjectArray // 请求到的图片url字符串或者本地图片名称
    }
    
    // MARK: UICollectionDelegate
    // MARK:numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // MARK:numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var itemCount = 1
        if section == 1 {
            if self.dataSource.count != 0 {
                itemCount = self.dataSource.count
            }
        }
        return itemCount
    }
    
    // MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            
            let cycleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cycleCollectionViewCell.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: adverViewHeight + HOME_HEADER_HEIGHT + self.menuButtonsViewHeight)
            cycleCollectionViewCell.addSubview(self.scrollImageView)
            cycleCollectionViewCell.addSubview(self.menuButtonsView)
            cycleCollectionViewCell.isUserInteractionEnabled = true
            return cycleCollectionViewCell
        } else {
            let cell = collectView?.dequeueReusableCell(withReuseIdentifier: IMAGE_COLLECTION_CELL, for: indexPath) as! ImageCollectionViewCell
            
            // right View
            if self.dataSource.count == 0 {
                return cell
            }
            let rightSence = self.dataSource[indexPath.row]
            // image
//            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + rightSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + rightSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            
            // PM2.5
            if rightSence.pm25 == nil {rightSence.pm25 = 0}
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SYSTEM_SIZE, minFont: 10.0, color: colorPm25WithValue(pm25Value: rightSence.pm25!), action: {})
            let strText = "PM2.5：<help><link><FontMax>\(String(describing: rightSence.pm25!))</FontMax></link></help>" as NSString?
            cell.showPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            // Address
            // Address
            cell.showAddressLabel.text = AddressPickerDemo.getReadCityAddress(withAddressStr: rightSence.address, andCurrentCity: self.selectedCityBtn.titleLabel?.text)
            UILabel.setLabelSpace(cell.showAddressLabel, withValue: cell.showAddressLabel.text, with: cell.showAddressLabel.font, andLineSpaceing: 2.0)
            // support
            if rightSence.isLike != nil && rightSence.isLike! {
                cell.showSupportBtn.isSelected = true
            } else {
                cell.showSupportBtn.isSelected = false
            }
            cell.showSupportBtn.isSelected = false
            cell.showSupportBtn.setTitle(String(describing: rightSence.likeCount!), for: .normal)
            
            return cell
        }
    }
    
    // MARK:viewForSupplementaryElementOfKind
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        self.reusableView = nil
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0 {
            
            self.reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "head", for: indexPath)
            self.reusableView?.frame = CGRect.zero
            self.reusableView?.isHidden = true
            
            return self.reusableView!
        } else {
            self.headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HOME_HEADER_ID, for: indexPath) as? HomeHeaderView
            self.headView?.tag = 1001
            self.headView?.homeHeaderdelegate = self
            
            self.reusableView = self.headView
            
            return self.reusableView!
        }
    }
    
    // MARK:didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && self.dataSource.count != 0 {
            let senceData = self.dataSource[indexPath.row]
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowPhotoView") as! ShowPhotoViewController
            viewController.senceData = senceData
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    // MARK: - SYStickHeaderWaterFallDelegate
    // MARK:heightForItemAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SYStickHeaderWaterFallLayout, heightForItemAt indexPath: IndexPath) -> CGFloat {
        var cellHeight:CGFloat = adverViewHeight + self.menuButtonsViewHeight
        if indexPath.section == 1 {
            if self.dataSource.count == 0 {
                cellHeight = 0.0
            } else {
                if indexPath.item > self.dataSource.count - 1 { return 150}
                let cellModel = self.dataSource[indexPath.item]
                if cellModel.imageHeight == nil {
                    var lastChar = cellModel.id! as NSString
                    lastChar = lastChar.substring(from: lastChar.length - 1) as NSString
                    let charInt = Int(lastChar.character(at: 0))
                    cellModel.imageHeight = getRandomCellHeight(cellWidth: Float((SCREEN_WIDTH-15)/2), randomNumber: charInt)
                }
                cellHeight = CGFloat(cellModel.imageHeight! + 48.0)
            }
        }
        
        return cellHeight
    }
    
    // MARK:heightForHeaderAt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SYStickHeaderWaterFallLayout, heightForHeaderAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return HOME_HEADER_HEIGHT
        }
        return 0.0
    }
    
    // MARK: widthForItemInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SYStickHeaderWaterFallLayout, widthForItemInSection section: Int) -> CGFloat {
        if section == 0 {
            return SCREEN_WIDTH
        } else if section == 1 {
            return (SCREEN_WIDTH-15)/2
        }
        return 0.0
    }
    
    // MARK:topInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SYStickHeaderWaterFallLayout, topInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: bottomInSection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SYStickHeaderWaterFallLayout, bottomInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    // MARK: - LPBannerViewDelegate 代理方法的实现
    // MARK:  图片Item点击方法的回调
    func cycleScrollView(_ scrollView: LPBannerView, didSelectItemAtIndex index: Int) {
        myPrint(message: "index = \(index)")
        let subject = self.scrollImagesDataSource[index]
        
        // 判断是否是年报
        var isShowShareBtn = false
        if subject.subjectTypeCode == SubjectTypeCode.yearReport.rawValue {
            // 判断用户是否登录、
            if APP_DELEGATE.currentUserInfo == nil {
                APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
                return
            }
            
            // 判断临时用户升级
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
                return
            }
            
        } else if subject.subjectTypeCode == SubjectTypeCode.merchantRegister.rawValue {
            // 商家入驻
            // 判断用户是否登录、
            if APP_DELEGATE.currentUserInfo == nil {
                APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
                return
            }
            
            // 判断临时用户升级
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
                return
            }
            
            // 判断是否是商家
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleMerchant.rawValue {
                MBProgressHUD.show("你已是平台商家，无需再次入驻", icon: nil, view: self.view)
                return
            }
            
            let merchantRegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterMerchantView")
            self.navigationController?.pushViewController(merchantRegisterVC!, animated: true)
            return
        } else if subject.subjectTypeCode == SubjectTypeCode.normal.rawValue {
            // 普工主题
            isShowShareBtn = true
        } else {
            MBProgressHUD.show("功能开发中，敬请期待...", icon: nil, view: self.view)
            return
        }
        
        // 跳转到web页面
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        viewController.isUserGesture = true
        viewController.pageUrlStr = subject.url
        viewController.isShowShareBtn = isShowShareBtn
        viewController.isYearReportShare = subject.subjectTypeCode == SubjectTypeCode.yearReport.rawValue ? true : false
        viewController.pageThumbImageUrl = WEBBASEURL_IAMGE + subject.coverImg!
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: -  HomeHeaderViewDelegate 代理方法的实现
    // MARK: Button 点击回调
    func homeHeaderViewButtonIndexClick(index: Int) -> Bool {
        myPrint(message: "buttonIndex = \(index)")
        if index == 2 {
            // 判断是否登录
            if APP_DELEGATE.currentUserInfo == nil {
                APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
                return false
            }
            
            // 判断临时用户升级
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
                return false
            }
        }
        
        self.currentButton = index
        
        self.page = 1
        // 获取网络数据
        self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: self.currentButton, pageCount: self.page)
        
        return true
    }
    
    
    // MARK: - AddressPickerDemoDelegate
    // MARK: 选中城市响应方法
    func addressPickerDemo(_ addressDemo: AddressPickerDemo!, didSelectedCity city: String!) {
        myPrint(message: "\(city)")
        var newCity = city
        if !city.hasSuffix("市") && !city.hasSuffix("地区") && !city.hasSuffix("自治州") {
            newCity = city + "市"
        }
        
        self.setLocationBtnShowText(cityName: newCity! )
        //addressDemo.dismiss(animated: true, completion: nil)
        
        // 获取选中城市的天气数据
        MBProgressHUD.showMessage("更新天气数据", to: self.view)
        APP_DELEGATE.currenctSelectedCity = newCity
        self.getWeatherData()
        
        // 刷新网络数据
        if self.currentButton == 0 {
            // 身边此刻是刷新
            self.page = 1
            self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: self.currentButton, pageCount: self.page)
        }
        
    }
    
    
    // MARK: - AMapSearchDelegate 代理方法的实现
    // MARK: weather search done
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        if response.lives.count > 0 {
            let localWeatherLive = response.lives[0]
            APP_DELEGATE.locationWeather = localWeatherLive
            self.weatherBtn.setTitle("\(localWeatherLive.temperature!)°", for: .normal)
            // 获取天气图标
            let filePath = Bundle.main.path(forResource: "weatherIcon", ofType: "plist")
            let weatherIconDict = NSDictionary.init(contentsOfFile: filePath!)
            if localWeatherLive.weather == nil { return }
            myPrint(message: "weather: \(localWeatherLive.weather!)")
            
            // 去掉天气中的空格和换行
            var weatherName = localWeatherLive.weather! as NSString
            weatherName = weatherName.replacingOccurrences(of: " ", with: "") as NSString
            weatherName = weatherName.replacingOccurrences(of: "\n", with: "") as NSString
            
            let weatherIconPath = weatherIconDict?.object(forKey: weatherName)
            if weatherIconPath != nil {
                let weatherImage = UIImage.init(named: weatherIconPath as! String)
                self.weatherBtn.setImage(UIImage.scal(toSize: weatherImage, size: CGSize(width: 28, height: 28)), for: .normal)
            }
            
            if self.isWeatherBtnClick {
                // 获取PM2.5值
                self.getCurrentWeatherPm25Data(isShowHub: false, isJumpVC: true)
            } else {
                let isAutoHideTip = UserDefaults.standard.bool(forKey: WEATHER_IS_SHOW_AUTO_KEY)
                if !isAutoHideTip {
                    // 获取PM2.5值
                    self.getCurrentWeatherPm25Data(isShowHub: false, isJumpVC: true)
                } else {
                    self.getCurrentWeatherPm25Data(isShowHub: false, isJumpVC: false)
                }
            }
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: failed
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if (error != nil) {
            MBProgressHUD.hide(for: self.view, animated: true)
            MBProgressHUD.showBottom("获取天气数据出错", icon: nil, view: nil)
        }
    }
    
    
    // MARK: - WeatherViewDelegate 代理方法的实现
    // MARK: 天气界面的点击城市选择的回调
    func weatherViewSelectedCity() {
        myPrint(message: "点击天气的城市选择的回调")
        self.selectedCityBtnClick(UIButton.init())
    }
    
    // MARK: 天气界面的点击用户头像的回调
    func weatherViewUserIcon() {
        myPrint(message: "点击天气的用户头像的回调")
    }
    
    // MARK: 天气界面的点击背景的回调
    func weatherViewBackground() {
        myPrint(message: "点击天气背景的回调")
    }
    
    // MARK: 更新天气数据回调
    func weatherRefleshWeatherData() {
        if APP_DELEGATE.locationWeather != nil {
            self.weatherBtn.setTitle("\(APP_DELEGATE.locationWeather?.temperature! ?? "0")°", for: .normal)
            // 获取天气图标
            let filePath = Bundle.main.path(forResource: "weatherIcon", ofType: "plist")
            let weatherIconDict = NSDictionary.init(contentsOfFile: filePath!)
            let weatherImage = UIImage.init(named: weatherIconDict?.object(forKey: APP_DELEGATE.locationWeather?.weather! ?? "晴") as! String)
            self.weatherBtn.setImage(UIImage.scal(toSize: weatherImage, size: CGSize(width: 28, height: 28)), for: .normal)
        }
    }
    
    
    // MARK: - NewFunctionTipViewDelegate 新功能提醒
    // MARK: imageViewClickWiathDataDict
    func imageViewClickWiathDataDict(dataDict: [String : String]) {
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
        
        // 数据处理
        let imageUrlStr = dataDict[DICT_SUB_VALUE1]
        if (imageUrlStr?.hasPrefix("http"))! {
            // 网址链接
            // 跳转WKWebView
            let wkWebViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
            wkWebViewController.isUserGesture = true
            wkWebViewController.pageUrlStr = imageUrlStr
            wkWebViewController.pageThumbImageUrl = dataDict[DICT_IMAGE_PATH]
            self.navigationController?.pushViewController(wkWebViewController, animated: true)
        } else {
            switch imageUrlStr {
            case "MineView"?:
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: imageUrlStr!) as! MineViewController
                viewController.carbonCoinShowCount = 10
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                myPrint(message: "界面跳转异常")
            }
            
        }
    }
    
    
    // MARK: - QQScanViewDelegate
    // MARK:
    func qqScanViewSuccessWithString(textStr: String) {
        if textStr.hasPrefix("wxp") || textStr.hasPrefix("HTTPS://QR.ALIPAY") {
            myPrint(message: "微信或支付宝支付")
            MBProgressHUD.showMessage("")
            // 微信或支付宝支付
            // 1. 根据QRStr查询商户信息
            MerchantBusiness.shareIntance.responseWebGetMerchantDetailByQR(qrCodeStr: textStr, responseSuccess: { (objectSuccess) in
                let result = objectSuccess as! WebResultModel<MerchantModel>
                MBProgressHUD.hide()
                if result.status == ResponseCodeType.success.rawValue {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as! PayViewController
                    viewController.merchant = result.data
                    self.navigationController?.pushViewController(viewController, animated: true)
                } else {
                    APP_DELEGATE.alertCommonShow(title: "提示", message: "该商户未加入250支付平台，请联系029-82245879加入我们", btn1Title: "取消", btn2Title: "确定", vc: self, buttonClick: { (btnIndex) in
                        if btnIndex == 1 {
                           UIApplication.shared.openURL(NSURL.init(string: "tel://\(029-82245879)")! as URL)
                        }
                    })
                }
                
            }) { (error) in
            }
            
            return
        }
        
        // 字符串显示
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = textStr
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: 选择城市响应
    @IBAction func selectedCityBtnClick(_ sender: UIButton) {
        let addressViewController = AddressPickerDemo.init()
        let navVC = UINavigationController.init(rootViewController: addressViewController)
        addressViewController.addressDelegate = self
        self.present(navVC, animated: true, completion: nil)
    }
    
    
    // MARK: 天气按钮点击相应
    @IBAction func weatherBtnClick(_ sender: UIButton) {
        if APP_DELEGATE.locationAddress == nil {
            // 未定位成功显示默认城市
            self.isWeatherBtnClick = true
            APP_DELEGATE.currenctSelectedCity = DEFAULT_LOCATIONFAILED_CITY
            self.getWeatherData()
            MBProgressHUD.showMessage("", to: self.view)
        } else if APP_DELEGATE.locationWeather == nil {
            // 先获取天气数据
            self.isWeatherBtnClick = true
            self.getWeatherData()
            MBProgressHUD.showMessage("", to: self.view)
        } else if APP_DELEGATE.currentLivePm25 == nil || APP_DELEGATE.currentLivePm25 == 0 {
            // 先获取PM2.5值
            self.isWeatherBtnClick = true
            self.getCurrentWeatherPm25Data(isShowHub: true, isJumpVC: true)
        } else {
            // 跳转 weather显示界面
            let viewController = WeatherViewController.init(nibName: "WeatherViewController", bundle: nil)
            viewController.weatherDelegate = self
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: 用户头像点击响应
    func userIconBtnClick(_ sender: UIButton) {
        // 本地页面跳转
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: true)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.phoneNumber == nil || APP_DELEGATE.currentUserInfo?.phoneNumber == "" {
            // 临时用户
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "tabVC3") as! MineViewController
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
    
    // MARK: 实景墙点击响应
    @objc func senceWallBtnClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SenceWallView") as! SenceWallViewController
        viewController.currentSelectedCity = APP_DELEGATE.currenctSelectedCity ?? DEFAULT_LOCATIONFAILED_CITY
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 排行榜点击响应
    @objc func rankBtnClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RankView") as! RankViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 添加关注点击响应
    @objc func addAttentionBtnClick(_ sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddAttentionView") as! AddAttentionViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        // 设置导航栏
        self.setNavigationStyle()
        
        self.checkMessageReadStatus()
    }
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: view did Disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // MARK: view will Dsiappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
    
    

    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取实景列表数据
    func getSenceListData(selectedCity: String, buttonIndex: Int, pageCount: Int) {
        self.collectView?.es.resetNoMoreData()
        
        var regionCode = DEFAULT_LOCATIONFAILED_CODE
        if buttonIndex == 0 && selectedCity != "定位中..." {
            // 身边此刻
            let cityInfo = AddressPickerDemo.getCityRelativeInfo(with: selectedCity)
            if cityInfo != nil {
                regionCode = cityInfo!["regionCode"] as! String
            }
        }
        if buttonIndex == 1 {
            // 世界此刻
            regionCode = ""
        }

        if buttonIndex == 2 {
            // 我关注的用户的实景图片列表
        PhotoBusiness.shareIntance.responseWebGetMineAttentionUsersSenceList(pageIndex: pageCount, responseSuccess: { (resonseSuccess) in
                let pageResult = resonseSuccess as! PageResultModel<PhotoModel>
                if pageCount == 1 {
                    self.dataSource.removeAll()
                    
                    self.dataSource = pageResult.beanList!
                    self.collectView?.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
                } else {
                    self.dataSource = self.dataSource + pageResult.beanList!
                }
                
                // 判断是否到底
                if pageResult.pageCode == pageResult.totalPage {
                    self.collectView?.es.noticeNoMoreData()
                }
                myPrint(message: resonseSuccess)
                
                // 刷新数据
                self.collectView?.reloadData()
            }) {(error) in
            }
            
            return
        }
        
        
        // 获取实景列表
        PhotoBusiness.shareIntance.responseWebGetSenceList(pageIndex: pageCount, photoTypCode: "", regionCode: regionCode, minPm25: 0, maxPm25: 0, responseSuccess: { (resonseSuccess) in
            let pageResult = resonseSuccess as! PageResultModel<PhotoModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                
                self.dataSource = pageResult.beanList!
                self.collectView?.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode == pageResult.totalPage {
                self.collectView?.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            self.collectView?.reloadData()
        }) { (error) in
        }
        
    }
    
    // MARK: 获取主题列表数据
    func getSubjectListData() {
        PhotoBusiness.shareIntance.responseWebGetSubjectList(responseSuccess: { (responseSuccess) in
            self.scrollImagesDataSource = responseSuccess as! [SubjectModel]
            
            var imagesArray: [String] = []
            for subject in self.scrollImagesDataSource {
                imagesArray.append(WEBBASEURL_IAMGE + subject.coverImg!)
            }
            self.homeScrollImagesWithArray(subjectArray: imagesArray)
        }) { (error) in
        }
    }
    
    // 判断消息是否未读
    func checkMessageReadStatus() {
        if APP_DELEGATE.currentUserInfo == nil {
            self.messageBtnRedDotView?.isHidden = true
            return
        }
        
        MessageBusiness.shareIntance.responseWebGetMessagePage(messageTypeCode: nil, isReaded: false, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: 1, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<MessageModel>
            if (pageResult.beanList?.count)! > 0 {
                // 未读
                self.messageBtnRedDotView?.isHidden = false
            } else {
                self.messageBtnRedDotView?.isHidden = true
            }
            
        }) { (error) in
        }
        
    }
    
    
    // MARK: 获取天气数据
    func getWeatherData() {
        // weather
        let weatherSearchRequest = AMapWeatherSearchRequest.init()
        weatherSearchRequest.city = APP_DELEGATE.currenctSelectedCity
        weatherSearchRequest.type = .live  // 实时天气
        self.mapSearch.aMapWeatherSearch(weatherSearchRequest)
    }
    
    
    
    // 获取当前位置的PM2.5
    func getCurrentWeatherPm25Data(isShowHub: Bool, isJumpVC: Bool) {
        var paramters = ["longitude" : "\(UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))", "latitude": "\(UserDefaults.standard.double(forKey: LOCATION_LATITUDE))"]
        if APP_DELEGATE.currenctSelectedCity != APP_DELEGATE.locationAddress?.city {
            // 不是定位城市
            // 获取选择城市的信息（包含中心经纬度）
            let cityDict = AddressPickerDemo.getCityRelativeInfo(with: APP_DELEGATE.currenctSelectedCity)
            if cityDict != nil {
                paramters = ["longitude" : "\(cityDict!["longitude"] ?? DEFAULT_CITY_CENTER_LONGITUDE)", "latitude": "\(cityDict!["latitude"] ?? DEFAULT_CITY_CENTER_LATITUDE)"]
            } else {
                paramters = ["longitude" : DEFAULT_CITY_CENTER_LONGITUDE, "latitude": DEFAULT_CITY_CENTER_LATITUDE]
            }
        }
        
        if isShowHub {
            MBProgressHUD.showMessage("", to: self.view)
        }
        WebDataResponseInterface.shareInstance.SessionManagerWebDataALLParamters(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_StationHourDataGetNearbyPm25, parameters: paramters as NSDictionary, resquestType: .POST, outRequestTime: 5, responseProgress: {_ in}, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if objectSuccess == nil {
                // 图片美化和PM2.5校正
                var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
                if pm25Value < 5 {pm25Value = Int(NSString.randomString(with: "10"))!}
                APP_DELEGATE.currentLivePm25 = pm25Value
                if isJumpVC {
                    self.jumpToWeatherVC(pm25: pm25Value)
                }
                
            } else {
                var pm25Value = objectSuccess as! Int
                if pm25Value <= 5 { pm25Value = Int(NSString.randomString(with: "10"))!}
                APP_DELEGATE.currentLivePm25 = pm25Value
                if isJumpVC {
                    self.jumpToWeatherVC(pm25: pm25Value)
                }
                
            }
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            myPrint(message: "error:\(error)")
            // 获取空气质量失败
            // 图片美化和PM2.5校正
            var pm25Value = UserDefaults.standard.integer(forKey: PHOTO_PM_25)
            if pm25Value < 5 {pm25Value = Int(NSString.randomString(with: "10"))!}
            APP_DELEGATE.currentLivePm25 = pm25Value
            if isJumpVC {
                self.jumpToWeatherVC(pm25: pm25Value)
            }
        }
    }
    
    
    // MARK: 跳转到天气界面
    func jumpToWeatherVC(pm25: Int) {
        if self.isAutoShowWeatherAlert {
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                // 判断当前页面是否是首页
                let nav = APP_DELEGATE.jmTabBarViewController?.selectedViewController as! UINavigationController
                let currentVC = nav.visibleViewController
                if currentVC != nil && currentVC?.classForCoder != HomeViewController.classForCoder() {
                    return
                }
                
                let viewController = WeatherViewController.init(nibName: "WeatherViewController", bundle: nil)
                viewController.isAutoDismiss = true
                viewController.weatherDelegate = self
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overFullScreen
                self.present(viewController, animated: true, completion: nil)
            }
            
            self.isAutoShowWeatherAlert = false
        }
        
        
        if self.isWeatherBtnClick {
            let viewController = WeatherViewController.init(nibName: "WeatherViewController", bundle: nil)
            viewController.isAutoDismiss = false
            viewController.weatherDelegate = self
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
            self.present(viewController, animated: true, completion: nil)
            self.isWeatherBtnClick = false
        }
    }
    
    
    // MARK: 判断定位权限
    func checkLocationAuthority() {
        if CLLocationManager.authorizationStatus() == .denied {
            // 未开启定位权限
            let alertViewController = UIAlertController.init(title: "未开启定位权限", message: "为了获取更好的用户体验，请在（设置->隐私->定位服务->250你发布）开启定位权限", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction.init(title: "确定", style: .default, handler: { (alertAction) in
                // 跳转到定位设置
                UIApplication.shared.openURL(URL.init(string: UIApplication.openSettingsURLString)!)
            }))
            
            self.present(alertViewController, animated: true, completion: nil)
        } else {
            myPrint(message: "已开启定位权限")
        }
    }
    
    
    
    // MARK: - UIGestureRecognizerDelegate 代理方法的实现
    // MARK:
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }    
}


extension HomeViewController {
    func setViewUI() {
        // 初始化
        if SCREEN_WIDTH < 375.0 {
            self.selectedCityBtn.width = 100.0
        }
        // 等比计算广告View的高度（16：9）
        adverViewHeight = SCREEN_WIDTH * 9 / 16
        self.scrollImageView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: adverViewHeight))
        // set navigation Bar
        // set left bar Item
        let leftBarItem = UIBarButtonItem.init(image: UIImage.init(named: "home_qrcode.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarItem
        

        // set right Btn
        self.rightNavBtn = UIButton.init(frame: self.userIconContentView.bounds)
        self.rightNavBtn?.setImage(UIImage.init(named: "home_message.png"), for: .normal)
        self.userIconContentView.addSubview(self.rightNavBtn!)
        self.rightNavBtn?.addTarget(self, action: #selector(rightNavBtnClick(sender:)), for: .touchUpInside)


        // 设置红点
        self.messageBtnRedDotView = UIView.init(frame: CGRect.init(x: (self.rightNavBtn?.width)!/2 + 10, y: 0, width: 10, height: 10))
        self.messageBtnRedDotView?.layer.masksToBounds = true
        self.messageBtnRedDotView?.layer.cornerRadius = 5
        self.messageBtnRedDotView?.layer.borderColor = UIColor.white.cgColor
        self.messageBtnRedDotView?.layer.borderWidth = 2
        self.messageBtnRedDotView?.backgroundColor = UIColor.white
        self.userIconContentView.addSubview(self.messageBtnRedDotView!)
        self.messageBtnRedDotView?.isHidden = true
        
        
        // set navigation Bar
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.title = NSLocalizedString("sence", comment: "")
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        // 设置定位城市
        self.selectedCityBtn.setImage(#imageLiteral(resourceName: "home_location_icon"), for: .normal)
        self.selectedCityBtn.setTitle(NSLocalizedString("locating", comment: ""), for: .normal)
    }
    
    
    // MARK: 设置初始化功能
    func setInitFunction() {
        APP_DELEGATE.singleStartLocationOnce(locationSuccess: { (locationReGeocode, location) in
            // 定位成功
            APP_DELEGATE.locationAddress = locationReGeocode
            self.setLocationBtnShowText(cityName: locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY)
            
            // 获取网络数据
            self.getSenceListData(selectedCity: locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY, buttonIndex: 0, pageCount: self.page)
            
            // 获取天气数据
            APP_DELEGATE.currenctSelectedCity = locationReGeocode.city ?? DEFAULT_LOCATIONFAILED_CITY
            self.getWeatherData()
        }) { (error) in
            // 定位失败
            self.setLocationBtnShowText(cityName: DEFAULT_LOCATIONFAILED_CITY)
            
            // 获取天气数据
            APP_DELEGATE.currenctSelectedCity = DEFAULT_LOCATIONFAILED_CITY
            self.getWeatherData()
            
            // 获取网络数据
            self.getSenceListData(selectedCity: (self.selectedCityBtn.titleLabel?.text)!, buttonIndex: 0, pageCount: self.page)
            
            // 判断定位权限是否开启
            self.checkLocationAuthority()
        }
        
        // 验证用户登录是否过期，并获取用户信息
        // 获取本地用户数据
        let dataSourceDict = UserDefaults.standard.dictionary(forKey: DICT_USER_INFO)
        if dataSourceDict != nil {
            APP_DELEGATE.currentUserInfo = UserInfoModel.init(json: (dataSourceDict?.mapJSON())!)
            
            // 根据accessToken验证用户是否过期
            UserBusiness.shareIntance.responseWebAccessTokenGetUserInfo(responseSuccess: { (objectSuccess) in
                let userInfo = objectSuccess as? UserInfoModel
                APP_DELEGATE.currentUserInfo = userInfo

                // 判断每日第一次完成登录任务提醒
                if userInfo?.finishLoginTask != nil && (userInfo?.finishLoginTask)! {
                    APP_DELEGATE.showCarbonCoinCountTipWith(carbonCoinCount:10, awardReason: "每日登录", vc: self)
                }
                
                // 上传消息通知账户
                UMessage.addAlias((APP_DELEGATE.currentUserInfo?.id)!, type: UM_ALIAS_TYPE, response: { (object, error) in
                    myPrint(message: "addAliasError: \(String(describing: error))")
                })
                
                // 判断消息状态
                self.checkMessageReadStatus()
                
                // 上传应用数据统计
                OtherBusiness.shareIntance.responseWebPublishAppInCommonData(userId: APP_DELEGATE.currentUserInfo?.id, responseSuccess: { (objectSuccess) in
                }, responseFailed: { (error) in
                })
                
                // MARK: 获取碳币奖励规则列表
                OtherBusiness.shareIntance.responseWebGetTaskList(responseSuccess: { (objectSuccess) in
                    APP_DELEGATE.carbonRuleList = objectSuccess as! [TaskModel]
                }) { (error) in
                }
                
            }, responseFailed: { (error) in
            })
        }
        
        
        // MARK: 获取主题列表数据
        self.getSubjectListData()
        
        // 获取区划树
        OtherBusiness.shareIntance.responseWebGetRegionTreeList(responseSuccess: { (objectSuccess) in
            // 保存区划树到本地
            UserDefaults.standard.set(objectSuccess, forKey: "citysCode")
            UserDefaults.standard.synchronize()
        }) { (error) in
        }
        
        
        /// 注册接收消息通知
        // 接收用户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        // 接收图片信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptPhotoInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PhotoInfo), object: nil)
        // 接收用户在其它地方登录的消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserOtherLoginNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
        // 接收碳币任务更新的消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserCoinTaskUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_CoinTaskUpdate), object: nil)
        // 接收App消息全部已读通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserMessageAllReadUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_MessageAllRead), object: nil)
        // 接收系统推送消息响应通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserSystemPushMessageNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_SystemPushMessage), object: nil)
    }
    
    
    // MARK: 自检App Store 的软件更新
    func customCheckAppStoreUpdate() {
        // 检测更新
        let boudleId = String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier")!)
        HSUpdateApp.hs_update(withAPPID: APP_ID, withBundleId: boudleId) { (currentVersion, storeVersion, openUrl, isUpdate, updateContent) in
            if isUpdate {
                sleep(1);
                let viewController = DoUpdateViewController.init(nibName: "DoUpdateViewController", bundle: nil)
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overFullScreen
                viewController.storeVersion = storeVersion
                viewController.storeUpateNots = updateContent
                
                // 是否强制更新
                let firstcurrentBitVersion = currentVersion?.components(separatedBy: ".")
                let firstStoreBitVersion = storeVersion?.components(separatedBy: ".")
                if (firstcurrentBitVersion?.count)! > 0 && (firstStoreBitVersion?.count)! > 0 {
                    if firstStoreBitVersion![0] > firstcurrentBitVersion![0] {
                        viewController.isForceUpdate = true
                    }
                }
                
                self.present(viewController, animated: true, completion: nil)
            } else {
            }
        }
    }
    
    
    // MARK: 监测250平台的更新
    func customCheck250PublishUpdate() {
        // 检查软件更新
        MBProgressHUD.showMessage("")
        OtherBusiness.shareIntance.responseWebGetAppDetail(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            let appInfo = objectSuccess as! AppInfoModel
            //            appInfo.latestVersion = "28"
            //            appInfo.latestForceVersion = "27"
            let buildNumberStr = String(describing: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!)
            if buildNumberStr < appInfo.latestVersion!  {
                // 需要更新
                let viewController = DoUpdateViewController.init(nibName: "DoUpdateViewController", bundle: nil)
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overFullScreen
                viewController.storeVersion = appInfo.latestBuildVersion
                viewController.storeUpateNots = appInfo.latestUpdateDescription
                
                // 是否强制更新
                if appInfo.latestForceVersion != "" &&  buildNumberStr < appInfo.latestForceVersion! {
                    viewController.isForceUpdate = true
                } else {
                    // 设置初始化功能
                    self.setInitFunction()
                }
                
                self.present(viewController, animated: true, completion: nil)
                
            } else {
                // 设置初始化功能
                self.setInitFunction()
                
                // MARK: 显示新版本特性
                self.showNewVersionSpeciality()
            }
        }) { (error) in
//            MBProgressHUD.hide()
//            MBProgressHUD.showMessage("请接入网络（应用即将退出)...")
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
//                exit(0)
//            })
        }
    }
    
    
    // MARK: 显示新版本特性
    func showNewVersionSpeciality() {
        // 第一次安装最新版本提示新功能
//        if APP_DELEGATE.isNotFirstOpenApp == nil || !APP_DELEGATE.isNotFirstOpenApp! {
//            let viewController = NewFunctionTipViewController.init(nibName: "NewFunctionTipViewController", bundle: nil)
//            viewController.modalTransitionStyle = .crossDissolve
//            viewController.modalPresentationStyle = .overFullScreen
//            viewController.newFunctionDelegate = self
//            self.present(viewController, animated: true, completion: nil)
//        }
    }
}

