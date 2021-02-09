//
//  MineHomePageViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/22.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class MineHomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var userInfo: UserInfoModel?

    
    fileprivate var dataSenceSource: [PhotoModel] = []
    fileprivate var dataAttentionSource: [UserInfoModel] = []
    fileprivate var dataFansSource: [UserInfoModel] = []
    
    var currentIndex:Int?        // 当前选中的按钮  实景 关注 粉丝
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showUerBgImageView: UIImageView!
    
    @IBOutlet weak var showUserImageView: UIImageView!
    
    @IBOutlet weak var showUserNameLabel: UILabel!
    
    @IBOutlet weak var showDescriptionLabel: UILabel!
    
    // sence
    @IBOutlet weak var showSenceView: UIView!
    @IBOutlet weak var showSenceTitleLabel: UILabel!
    @IBOutlet weak var showSenceValueLabel: UILabel!
    
    // attention
    @IBOutlet weak var showAttentionView: UIView!
    @IBOutlet weak var showAttentionTitleLabel: UILabel!
    @IBOutlet weak var showAttentionValueLabel: UILabel!
    
    // fans
    @IBOutlet weak var showFansView: UIView!
    @IBOutlet weak var showFansTitleLabel: UILabel!
    @IBOutlet weak var showFansValueLabel: UILabel!
    
    @IBOutlet weak var separatorBlockView: UIView!
    
    private var isFirstInit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        if self.currentIndex == nil {
            self.currentIndex = 0
        }
        self.title = "个人主页"
        self.showUserImageView.isUserInteractionEnabled = false
        self.showUserImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(userIconImageViewClick(sender:))))
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        
        
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // set Table View
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "HomeTableViewCell", bundle: nil), forCellReuseIdentifier: HOME_CELL_ID)
        self.tableView.register(UINib.init(nibName: "PhotoUserTableViewCell", bundle: nil), forCellReuseIdentifier: PHOTO_USER_CELL_ID)
        self.setTableViewHeaderView()
        
        // 设置刷新
        //  上拉刷新 type 1
        var header: ESRefreshProtocol & ESRefreshAnimatorProtocol
        var footer: ESRefreshProtocol & ESRefreshAnimatorProtocol
        switch type {
        case .meituan:
            header = MTRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = MTRefreshFooterAnimator.init(frame: CGRect.zero)
        case .wechat:
            header = WCRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
        default:
            header = ESRefreshHeaderAnimator.init(frame: CGRect.zero)
            footer = ESRefreshFooterAnimator.init(frame: CGRect.zero)
            break
        }
        
        let _ = self.tableView.es.addPullToRefresh(animator: header) { [weak self] in
            self?.refresh()
        }
        let _ = self.tableView.es.addInfiniteScrolling(animator: footer) { [weak self] in
            self?.loadMore()
        }
        self.tableView.refreshIdentifier = String.init(describing: type)
        self.tableView.expiredTimeInterval = Double(REQUEST_TIMEOUT_VALUE)
        
        /// 注册接收消息通知
        // 接收用户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        
        self.updateUserInformation()
    }
    
    // MARK: 更新用户信息
    func updateUserInformation() {
        if self.userInfo == nil {
            MBProgressHUD.hide()
            MBProgressHUD.hide(for: self.view, animated: true)
            return
            
        }
        // 更新用户信息
        
        UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.userInfo?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.userInfo = objectSuccess as? UserInfoModel
            // 如果登录当前登录用户
            if APP_DELEGATE.currentUserInfo?.id == self.userInfo?.id {
                // 更新我的250界面信息
                // 发送更新用户信息的广播
                APP_DELEGATE.currentUserInfo = self.userInfo
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
            } else {
                self.setTableViewHeaderView()
            }
        }) { (error) in
            MBProgressHUD.hide()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    
    }
    
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserInfoUpdateNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        if userInfo == nil {
            // 刷新用户信息
            if self.userInfo?.id == APP_DELEGATE.currentUserInfo?.id {
                self.userInfo = APP_DELEGATE.currentUserInfo
            }
        }
        self.setTableViewHeaderView()
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.updateUserInformation()
        self.page = 1
        // 获取网络数据
        switch self.currentIndex! {
        case 0:
            self.getSenceListData(pageCount: self.page)
        case 1:
            self.getAttentionUserList(pageCount: self.page)
        default:
            self.getFansUserList(pageCount: self.page)
        }
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        switch self.currentIndex! {
        case 0:
            self.getSenceListData(pageCount: self.page)
        case 1:
            self.getAttentionUserList(pageCount: self.page)
        default:
            self.getFansUserList(pageCount: self.page)
        }
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    // MARK: set TableView HeaderView
    func setTableViewHeaderView() {
        if self.userInfo == nil {
            return;
        }
        
        let rightBarBtnItem: UIBarButtonItem?
        if self.userInfo?.id == APP_DELEGATE.currentUserInfo?.id {
            // 自己的主页
            rightBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "mine_homepage_edit"), style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
            self.navigationItem.rightBarButtonItem = rightBarBtnItem
        } else {
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.userInfo?.id)!, responseSuccess: { (objectSuccess) in
                self.userInfo = objectSuccess as? UserInfoModel
                if self.userInfo?.isAttention != nil && (self.userInfo?.isAttention)! {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "已关注", style: .plain, target: self, action: #selector(self.rightBarBtnItemClick(sender:)))
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(white: 1.0, alpha: 0.6)
                } else {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "关注", style: .plain, target: self, action: #selector(self.rightBarBtnItemClick(sender:)))
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(white: 1.0, alpha: 1.0)
                }
            }) { (error) in
            }
        }
        
        // 设置头像背景
        let effectView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        effectView.frame = self.showUerBgImageView.bounds
        effectView.width = SCREEN_WIDTH
        self.showUerBgImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.userInfo?.avatar)!), placeholderImage: #imageLiteral(resourceName: "applogo"))
        if self.userInfo?.avatar == "/old/UserPhotos/1.jpg" {
            self.showUerBgImageView.image = #imageLiteral(resourceName: "applogo")
        }
        
        UIView.removeSubviews(self.showUerBgImageView)
//        tools.removeSubviews(self.showUerBgImageView)
        self.showUerBgImageView.addSubview(effectView)
        
        // 设置用户头像
        self.showUserImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.userInfo?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        self.showUserImageView.layer.masksToBounds = true
        self.showUserImageView.layer.cornerRadius = self.showUserImageView.height / 2
        
        // set user Name
        self.showUserNameLabel.text = self.userInfo?.nickname
        
        // 设置描述
        self.showDescriptionLabel.text = self.userInfo?.speak
        
        // 实景数
        self.showSenceValueLabel.text = "\(String(describing: (self.userInfo?.publishPhotoAmount ?? 0)!))"
        // 关注数
        self.showAttentionValueLabel.text = "\(String(describing: (self.userInfo?.attentionAmount ?? 0)!))"
        // 粉丝数
        self.showFansValueLabel.text = "\(String(describing: (self.userInfo?.followAmount ?? 0)!))"
        
        // 设置菜单栏选择响应事件
        self.setSelectButtonViewStyle(index: self.currentIndex!)
        self.showSenceView.isUserInteractionEnabled = true
        self.showSenceView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.setSelectButtonViewStyle(index: 0)
        }))
        
        self.showAttentionView.isUserInteractionEnabled = true
        self.showAttentionView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.setSelectButtonViewStyle(index: 1)
        }))
        
        self.showFansView.isUserInteractionEnabled = true
        self.showFansView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.setSelectButtonViewStyle(index: 2)
        }))
        
        // separator Block View
        self.separatorBlockView.layer.masksToBounds = true
        self.separatorBlockView.layer.cornerRadius = self.separatorBlockView.height / 2
    }
    
    // MARK: 设置选中的按钮View的样式
    func setSelectButtonViewStyle(index: Int)  {
        self.page = 1
        self.currentIndex = index
        switch index {
        case 0:
            self.showSenceTitleLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.showAttentionTitleLabel.textColor = COLOR_GAY
            self.showFansTitleLabel.textColor = COLOR_GAY
            
            self.showSenceValueLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.showAttentionValueLabel.textColor = COLOR_GAY
            self.showFansValueLabel.textColor = COLOR_GAY
            
            // 获取网络数据
            self.getSenceListData(pageCount: self.page)
        case 1:
            self.showSenceTitleLabel.textColor = COLOR_GAY
            self.showAttentionTitleLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.showFansTitleLabel.textColor = COLOR_GAY
            
            self.showSenceValueLabel.textColor = COLOR_GAY
            self.showAttentionValueLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            self.showFansValueLabel.textColor = COLOR_GAY
            
            // 获取网络数据
            self.getAttentionUserList(pageCount: self.page)
        default:
            self.showSenceTitleLabel.textColor = COLOR_GAY
            self.showAttentionTitleLabel.textColor = COLOR_GAY
            self.showFansTitleLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            
            self.showSenceValueLabel.textColor = COLOR_GAY
            self.showAttentionValueLabel.textColor = COLOR_GAY
            self.showFansValueLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
            
            // 获取网络数据
            self.getFansUserList(pageCount: self.page)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.separatorBlockView.center.x = (SCREEN_WIDTH / 3) * CGFloat(index) + (SCREEN_WIDTH / 3)/2
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Clic@objc @objc @objc k
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        
        if self.userInfo?.id == APP_DELEGATE.currentUserInfo?.id {
            // 用户编辑
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineInformationView") as! MineInformationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
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
            
            
            var isAttention = false
            if self.userInfo?.isAttention != nil {
                isAttention = (self.userInfo?.isAttention)!
            }
            // 关注
            MBProgressHUD.showMessage("")
            UserBusiness.shareIntance.responseWebUserAttention(userId: (self.userInfo?.id)!, isLike: !isAttention, responseSuccess: { (responseSuccess) in
                //
                MBProgressHUD.hide()
                self.userInfo?.isAttention = !(self.userInfo?.isAttention)!
                
                if (self.userInfo?.isAttention)! {
                    // 关注成功
                    self.navigationItem.rightBarButtonItem?.title = "已关注"
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(white: 1.0, alpha: 0.6)
                    MBProgressHUD.show("已关注", icon: nil, view: self.view)
                } else {
                    // 取消关注
                    self.navigationItem.rightBarButtonItem?.title = "关注"
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(white: 1.0, alpha: 1.0)
                    MBProgressHUD.show("取消关注", icon: nil, view: self.view)
                }
                
                // 更新publicUserInfo 信息
                UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.userInfo?.id)!, responseSuccess: { (objectSuccess) in
                    self.userInfo = objectSuccess as? UserInfoModel
                    
                    // 更新我的250界面信息
                    // 发送更新用户信息的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
                    
                }, responseFailed: { (error) in
                    
                })
            }, responseFailed: { (error) in
                MBProgressHUD.hide()
            })
        }
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.currentIndex! {
        case 0:
            if self.dataSenceSource.count % 2 == 0 {
                return self.dataSenceSource.count / 2
            }
            
            return self.dataSenceSource.count / 2 + 1
        case 1:
            return self.dataAttentionSource.count
        default:
            return self.dataFansSource.count
        }
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.currentIndex == 0 {
            // 实景
            let cell = self.tableView.dequeueReusableCell(withIdentifier: HOME_CELL_ID) as! HomeTableViewCell
            cell.selectionStyle = .none
            self.tableView.separatorStyle = .none
            
            // 重新计算索引
            let rightIndex = indexPath.row * 2 + 1
            let leftIndex = indexPath.row * 2
            
            // left View
            let leftSence = self.dataSenceSource[leftIndex]
            // image
            cell.leftImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE +  leftSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
            // PM2.5    字体样式
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: leftSence.pm25!), action: {})
            let strText = "PM2.5：<help><link><FontMax>\(String(describing: leftSence.pm25!))</FontMax></link></help>" as NSString?
            cell.leftPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            
            // 设置响应事件
            cell.leftCellView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer.init(target: self, action: #selector(customCellClick(gesture:)))
            gesture.accessibilityValue = String(leftIndex)
            cell.leftCellView.addGestureRecognizer(gesture)
            
            // Address
            cell.leftAddressLabel.text = AddressPickerDemo.getReadCityAddress(withAddressStr: leftSence.address, andCurrentCity: APP_DELEGATE.locationAddress?.city)
            // support
            cell.leftSupportBtn.setTitle(String(describing: leftSence.likeCount!), for: .normal)
            
            if rightIndex > self.dataSenceSource.count - 1 {
                // 没有右边的 cell
                cell.rightCellView.isHidden = true
            } else {
                cell.rightCellView.isHidden = false
                // right View
                let rightSence = self.dataSenceSource[rightIndex]
                // image
                cell.rightImageView.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE +  rightSence.thumbPhoto!), placeholderImage: DEFAULT_IMAGE())
                // PM2.5
                let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: rightSence.pm25!), action: {})
                let strText = "PM2.5：<help><link><FontMax>\(String(describing: rightSence.pm25!))</FontMax></link></help>" as NSString?
                cell.rightPM25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
                // Address
                cell.rightAddressLabel.text = AddressPickerDemo.getReadCityAddress(withAddressStr: rightSence.address, andCurrentCity: APP_DELEGATE.locationAddress?.city)
                // support
                cell.rightSupportBtn.setTitle(String(describing: rightSence.likeCount!), for: .normal)
                
                // 设置响应事件
                cell.rightCellView.isUserInteractionEnabled = true
                let gesture = UITapGestureRecognizer.init(target: self, action: #selector(customCellClick(gesture:)))
                gesture.accessibilityValue = String(rightIndex)
                cell.rightCellView.addGestureRecognizer(gesture)
            }
            
            
            return cell
        } else if self.currentIndex == 1 {
            // 关注
            let cell = self.tableView.dequeueReusableCell(withIdentifier: PHOTO_USER_CELL_ID) as! PhotoUserTableViewCell
            self.tableView.separatorStyle = .singleLine
            self.tableView.separatorColor = COLOR_SEPARATOR_LINE
            cell.accessoryType = .disclosureIndicator
            
            // 解析数据
            let userInfo = self.dataAttentionSource[indexPath.row]
            
            // 设置头像
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (userInfo.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
            
            // 设置名称 和 粉丝数
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_STANDARD_SIZE, minFont: 11.0, color: UIColor.lightGray, action: {})
            let strText = "\(userInfo.nickname ?? "")<help><link><FontMin>    粉丝数 \(String(describing: (userInfo.followAmount)!))</FontMin></link></help>" as NSString?
            cell.showTitleLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            
            // 设置描述
            cell.showDescripationLabel.text = userInfo.speak
            
            // 设置是否关注
            if userInfo.isAttention != nil && (userInfo.isAttention)! {
                cell.AttentionBtn.setTitleColor(COLOR_LIGHT_GAY, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_LIGHT_GAY.cgColor
                cell.AttentionBtn.setTitle("已关注", for: .normal)
            } else {
                cell.AttentionBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
                cell.AttentionBtn.setTitle("关注", for: .normal)
            }
            // 是否显示关注
            cell.AttentionBtn.isHidden = userInfo.id == APP_DELEGATE.currentUserInfo?.id
            
            // 设置响应方法
            cell.AttentionBtn.tag = indexPath.row
            cell.AttentionBtn.addTarget(self, action: #selector(userAttentionBtnClick(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            // 粉丝
            let cell = self.tableView.dequeueReusableCell(withIdentifier: PHOTO_USER_CELL_ID) as! PhotoUserTableViewCell
            
            cell.accessoryType = .disclosureIndicator
            self.tableView.separatorStyle = .singleLine
            self.tableView.separatorColor = COLOR_SEPARATOR_LINE
            
            // 解析数据
            let userInfo = self.dataFansSource[indexPath.row]
            
            // 设置头像
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (userInfo.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
            
            // 设置名称
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_STANDARD_SIZE, minFont: 11.0, color: UIColor.lightGray, action: {})
            let strText = "\(userInfo.nickname ?? "")<help><link><FontMin></FontMin></link></help>" as NSString?
            cell.showTitleLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            
            // 设置描述
            cell.showDescripationLabel.text = userInfo.speak
            
            // 设置是否关注
            if userInfo.isAttention != nil && (userInfo.isAttention)! {
                cell.AttentionBtn.setTitleColor(COLOR_LIGHT_GAY, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_LIGHT_GAY.cgColor
                cell.AttentionBtn.setTitle("已关注", for: .normal)
            } else {
                cell.AttentionBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
                cell.AttentionBtn.setTitle("关注", for: .normal)
            }
            // 是否显示关注
            cell.AttentionBtn.isHidden = userInfo.id == APP_DELEGATE.currentUserInfo?.id
            
            // 设置响应方法
            cell.AttentionBtn.tag = indexPath.row
            cell.AttentionBtn.addTarget(self, action: #selector(userAttentionBtnClick(sender:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    // MARK: custom cell Clic@objc @objc k
    @objc func customCellClick(gesture: UIGestureRecognizer) {
        let cellIndex = Int(gesture.accessibilityValue!)
        let senceData = self.dataSenceSource[cellIndex!]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowPhotoView") as! ShowPhotoViewController
        viewController.senceData = senceData
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.currentIndex == 0 {
            return
        }
        
        // 跳转到个人主页
        let userInfo: UserInfoModel?
        if self.currentIndex == 1 {
            //
            userInfo = self.dataAttentionSource[indexPath.row]
        } else {
            userInfo = self.dataFansSource[indexPath.row]
        }
        
        // 判断栈中是否含有 MineHomePageViewController 控制器
        let allViewControllerArray = self.navigationController?.viewControllers
        var mineHomeVCCount = 0
        var mineVc: MineHomePageViewController?
        for item  in allViewControllerArray! {
            if item.classForCoder == MineHomePageViewController.classForCoder() {
                mineHomeVCCount = mineHomeVCCount + 1
                if mineHomeVCCount == 1 {
                    mineVc = item as? MineHomePageViewController
                }
            }
        }
        if mineHomeVCCount == 2 {
            mineVc?.userInfo = userInfo
            mineVc?.setTableViewHeaderView()
            self.navigationController?.popToViewController(mineVc!, animated: true)
            return
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
        viewController.userInfo =  userInfo
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.currentIndex == 0 {
            return  HOME_CELL_HEIGHT
        }
        
        return CGFloat(PHOTO_USER_CELL_HEIGHT)
    }
    
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    
    // MARK:  设置导航栏样式
    func setNavigationStyle() {
        //        self.automaticallyAdjustsScrollViewInsets = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE),NSAttributedString.Key.foregroundColor:UIColor.white]
//        self.navigationControlNSAttributedString.Key.fonttitleTextAttributes = [NSFontAttributeName : UIFont.systemNSAttributedString.Key.foregroundColorFONT_SIZE,), NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    
    // MARK: 用户头像点击响应
    @objc func userIconImageViewClick(sender: UIGestureRecognizer) {
        let modelOne = LWImageBrowserModel.init(placeholder: #imageLiteral(resourceName: "defaultUserImage"), thumbnailURL: URL.init(string: WEBBASEURL_IAMGE + (self.userInfo?.avatar)!), hdurl: URL.init(string: WEBBASEURL_IAMGE + (self.userInfo?.avatar)!), containerView: self.tableView.tableHeaderView, positionInContainer: self.showUserImageView.frame, index: 0)
        
        let browser = LWImageBrowser.init(imageBrowserModels: [modelOne!], currentIndex: 0)
        
        browser?.show()
    }
    
    
    // MARK: 关注按钮点击响应@objc 方法
    @objc func userAttentionBtnClick(sender: UIButton) {
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
        
        
        var userInfo: UserInfoModel?
        if self.currentIndex == 1 {
            // 我关注的用户
            userInfo = self.dataAttentionSource[sender.tag]
        } else if self.currentIndex == 2 {
            // 粉丝
            userInfo = self.dataFansSource[sender.tag]
        }
        
        if userInfo?.isAttention == nil { userInfo?.isAttention = false }
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserAttention(userId: (userInfo?.id)!, isLike: !(userInfo?.isAttention)!, responseSuccess: { (responseSuccess) in
            //
            userInfo?.isAttention = !(userInfo?.isAttention)!
            
            if (userInfo?.isAttention)! {
                // 关注成功
                MBProgressHUD.show("已关注", icon: nil, view: self.view)
            } else {
                // 取消关注
                MBProgressHUD.show("取消关注", icon: nil, view: self.view)
            }
            
            
            // 更新publicUserInfo 信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.userInfo?.id)!, responseSuccess: { (objectSuccess) in
                self.userInfo = objectSuccess as? UserInfoModel
                self.tableView.reloadData()
                
                MBProgressHUD.hide()
                // 更新我的250界面信息
                // 发送更新用户信息的广播
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
            }, responseFailed: { (error) in
                MBProgressHUD.hide()
            })
        }) { (error) in
        }
    }
    
    
    // view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.setNavigationStyle()
    }
    
    // view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取指定用户的实景列表数据
    func getSenceListData(pageCount: Int) {
        self.tableView.es.resetNoMoreData()
        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebGetUserTakeSenceList(pageIndex: pageCount, userId: (self.userInfo?.id)!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<PhotoModel>
            if pageCount == 1 {
                self.dataSenceSource.removeAll()
                
                self.dataSenceSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataSenceSource = self.dataSenceSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode! >= pageResult.totalPage! {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 获取我的关注的用户的信息列表
    func getAttentionUserList(pageCount: Int) {
        self.tableView.es.resetNoMoreData()
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetUserAtteionUserList(pageIndex: pageCount, userId: (self.userInfo?.id)!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<UserInfoModel>
            if pageCount == 1 {
                self.dataAttentionSource.removeAll()
                self.dataAttentionSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataAttentionSource = self.dataAttentionSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode! >= pageResult.totalPage! {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: 获取我的粉丝的用户的信息列表
    func getFansUserList(pageCount: Int) {
        self.tableView.es.resetNoMoreData()
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetUserFollowUserList(pageIndex: pageCount, userId: (self.userInfo?.id)!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<UserInfoModel>
            if pageCount == 1 {
                self.dataFansSource.removeAll()
                self.dataFansSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataFansSource = self.dataFansSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode! >= pageResult.totalPage! {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            // 刷新
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


extension MineHomePageViewController {
    func setViewUI() {
        //
    }
}
