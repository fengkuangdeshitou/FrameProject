//
//  ShowPhotoViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class ShowPhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentBackDelegate, XC_touchTextviewDelegate, ShareThirdViewDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var senceData: PhotoModel?
    fileprivate var publicUserInfo: UserInfoModel?
    fileprivate var suportUsersArray: Array<PhotoLike> = []
    fileprivate var photoCommentArray: Array<PhotoLike> = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showDealImageView: UIImageView!
    
    @IBOutlet weak var showFlagLabel: UILabel!
    
    @IBOutlet weak var showOriginImageView: UIImageView!
    
    @IBOutlet weak var showPm25Label: UILabel!
    
    @IBOutlet weak var showAddressLabel: UIView!
    
    @IBOutlet weak var showSupportCountBtn: UIButton!
    
    @IBOutlet weak var showTakePhoteTimeLabel: UILabel!
    
    @IBOutlet weak var showDescriptionLabel: UILabel!
    
    @IBOutlet weak var showBottomLineView: UIView!
    
    @IBOutlet weak var showDealImageVIewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var showDealImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoInfoViewTopContraint: NSLayoutConstraint!
    
    
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var giveLikeButton: UIButton!
    
    @IBOutlet var commentsButton: UIButton!
    
    fileprivate var shareDealImage: UIImage?
    
    
    
    
    var commentBackView: CommentBackView?
    
    fileprivate lazy var showDescriptionAtUserLabel: XC_touchTextview = {
        let label = XC_touchTextview.init(frame: self.showDescriptionLabel.frame)
        label.cilckHightColor = UIColor.lightGray
        label.textColor = COLOR_DARK_GAY
        label.cilckdelegate = self
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = ""
        self.senceData?.originalPhoto = ""
        self.setViewUI()
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "•••", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // set Table View
//        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)  // 取消导航栏对View的影响
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
            
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: -NAVIGATION_AND_STATUS_HEIGHT, left: 0, bottom: 0, right: 0)
            self.tableView.contentInset = UIEdgeInsets(top: -NAVIGATION_AND_STATUS_HEIGHT, left: 0, bottom: 0, right: 0)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "PhotoUserTableViewCell", bundle: nil), forCellReuseIdentifier: PHOTO_USER_CELL_ID)
        self.tableView.register(UINib.init(nibName: "GiveLikeTableViewCell", bundle: nil), forCellReuseIdentifier: GIVE_LIKE_CELL_ID)
        self.tableView.register(UINib.init(nibName: "SupportUserTableViewCell", bundle: nil), forCellReuseIdentifier: SUPPORT_USER_CELL_ID)
        self.tableView.register(PhotoHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: PHOTO_HEADER_VIEW_ID)
        
        // 设置刷新
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        
        // 适配iphone x顶部的间距
        if SCREEN_HEIGHT == 812.0 {
            self.showDealImageVIewTopConstraint.constant = -25.0
            self.showDealImageViewHeightConstraint.constant += 25.0
        }
        
        // 请求网络数据
        self.getWebImageDetail()
        
        // 获取图片点赞列表
        self.getWebPhotoSupportUserList(pageIndex: 1)
        
        // 获取照片评论列表
        getWebResponseSuccessList(pageIndex: page)
        
        /// 注册接收消息通知
        // 接收用户信息更新消息通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserInfoUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserInfo), object: nil)
        
        // 创建评论输入窗口
        commentBackView = CommentBackView.init(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
        commentBackView?.commentBackDelegate = self
        commentBackView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    @objc func longPressToDo(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizer.State.began {
            
            let point: CGPoint = gesture.location(in: tableView)
            let indexPath: NSIndexPath = tableView.indexPathForRow(at: point)! as NSIndexPath
            
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
            
            var buttons = [
                [
                    "title": "回复",
                    "handler": "reply",],
                [
                    "title": "复制",
                    "handler": "copy",],
            ]
            
            // 权限判断
            if self.publicUserInfo?.id == APP_DELEGATE.currentUserInfo?.id {
                buttons.append([
                    "title": "删除",
                    "handler": "delete",
                    "type": "danger"
                    ])
            } else {
                let commentUser = self.photoCommentArray[indexPath.row].user
                if commentUser?.id == APP_DELEGATE.currentUserInfo?.id {
                    buttons.append([
                        "title": "删除",
                        "handler": "delete",
                        "type": "danger"
                        ])
                }
            }
            
            let cancelBtn = [
                "title": "取消",
                ]
            
            let mmActionSheet = MMActionSheet.init(title: nil, buttons: buttons, duration: nil, cancelBtn: cancelBtn)
            mmActionSheet.callBack = { (handler) ->() in
                if handler == "cancel" {
                    return
                }
                
                switch handler {
                case "reply":
                    // 回复
                    self.commentBackView?.joinOrganization(view: self.view, commentBackView: self.commentBackView!, photoId: (self.senceData?.id)!, replyUserId: (self.photoCommentArray[indexPath.row].user?.id)!)
                    self.commentBackView?.setInputPrompt(str: "回复" + (self.photoCommentArray[indexPath.row].user?.nickname)! + "：")
                case "copy":
                    // 复制
                    let paste = UIPasteboard.general
                    paste.string = AddressPickerDemo.stringReplaceEncode(with: self.photoCommentArray[indexPath.row].content)
                case "delete":
                    // 删除
                self.getWebPhotoCommentDelete(pageIndex: indexPath.row)
                default:
                    myPrint(message: "cancel")
                }
            }
            mmActionSheet.present()
        }
    }
    
    // 评论提交结果
    func evaluationResults(results: Bool) {
        
        if results {
            
            page = 1
            getWebResponseSuccessList(pageIndex: page)
        }
    }
    
    // 分享
    @IBAction func share(_ sender: UIButton) {
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
        
        // 分享
        // 跳转 Share显示界面
        let viewController = ShareThirdViewController.init(nibName: "ShareThirdViewController", bundle: nil)
        viewController.customDelegate = self
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    // MARK: - ShareThirdViewDelegate
    // MARK: 平台分享
    func shareThirdViewPublish(platformType: UMSocialPlatformType) {
        self.shareWebPageToPlatformType(platformType: platformType)
    }
    
    
    // 点赞
    @IBAction func giveLike(_ sender: UIButton) {
        
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
        
        if !thumbUpStateJudgment() {
            
            return
        }
        thumbUpHttp()
    }
    
    // 评论
    @IBAction func comments(_ sender: UIButton) {
        
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
        
        commentBackView?.joinOrganization(view: self.view, commentBackView: commentBackView!, photoId: (self.senceData?.id)!, replyUserId: "")
        commentBackView?.setInputPrompt(str: "说美景，品生活")
    }
    
    // MARK: 用户信息更新消息通知响应
    @objc func acceptUserInfoUpdateNotification(notification: Notification) {
        let userInfo = notification.object as? UserInfoModel
        if userInfo == nil {
            // 刷新用户信息
            if self.publicUserInfo?.id == APP_DELEGATE.currentUserInfo?.id {
                self.publicUserInfo = APP_DELEGATE.currentUserInfo
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 请求网络数据
        self.getWebImageDetail()
        
        // 获取图片点赞列表
        self.getWebPhotoSupportUserList(pageIndex: self.page)
        
        // 获取照片评论列表
        getWebResponseSuccessList(pageIndex: page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        
        // 获取照片评论列表
        getWebResponseSuccessList(pageIndex: page)
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: rightBarBtnItem Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // ["title": "分享","handler": "share",],
        let buttons = [
            
            [
                "title": "举报",
                "handler": "report",
                "type": "danger"
            ]
        ]
        let cancelBtn = [
            "title": "取消",
            ]
        
        let mmActionSheet = MMActionSheet.init(title: nil, buttons: buttons, duration: nil, cancelBtn: cancelBtn)
        mmActionSheet.callBack = { (handler) ->() in
            if handler == "cancel" {
                return
            }
            
            // 本地页面跳转
            if APP_DELEGATE.currentUserInfo == nil {
                APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
                return
            }
            
            // 判断临时用户升级
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
                return
            }
            
            switch handler {
            case "share":
                // 分享
                // 跳转 Share显示界面
                let viewController = ShareThirdViewController.init(nibName: "ShareThirdViewController", bundle: nil)
                viewController.customDelegate = self
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overFullScreen
                self.present(viewController, animated: true, completion: nil)
            case "report":
                // 举报
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ReportPhotoView") as! ReportPhotoViewController
                viewController.reportPhotoId = self.senceData?.id
                self.navigationController?.pushViewController(viewController, animated: true)
            default:
                myPrint(message: "cancel")
            }
        }
        mmActionSheet.present()
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0  {
            if (self.publicUserInfo != nil) {
                return 1
            }
            return 0
        }else if section == 1  {
            if suportUsersArray.count != 0 {
                return 1
            }
            return 0
        }
        return photoCommentArray.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // photo User
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: PHOTO_USER_CELL_ID) as! PhotoUserTableViewCell
            cell.accessoryType = .disclosureIndicator
            
            // 设置头像
            cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.publicUserInfo?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
            
            // 设置名称 和 粉丝数
            let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_STANDARD_SIZE, minFont: 11.0, color: UIColor.lightGray, action: {})
            let strText = "\(self.publicUserInfo?.nickname ?? "")<help><link><FontMin>    粉丝数 \(String(describing: (self.publicUserInfo?.followAmount)!))</FontMin></link></help>" as NSString?
            cell.showTitleLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
            
            // 设置描述
            cell.showDescripationLabel.text = (self.publicUserInfo?.speak)!
            
            // 设置是否关注
            if self.publicUserInfo?.isAttention != nil && (self.publicUserInfo?.isAttention)! {
                cell.AttentionBtn.setTitleColor(COLOR_LIGHT_GAY, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_LIGHT_GAY.cgColor
                cell.AttentionBtn.setTitle("已关注", for: .normal)
            } else {
                cell.AttentionBtn.setTitleColor(COLOR_HIGHT_LIGHT_SYSTEM, for: .normal)
                cell.AttentionBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
                cell.AttentionBtn.setTitle("关注", for: .normal)
            }
            // 是否显示关注
            cell.AttentionBtn.isHidden = self.publicUserInfo?.id == APP_DELEGATE.currentUserInfo?.id
            
            // 设置响应方法
            cell.AttentionBtn.tag = -1
            cell.AttentionBtn.addTarget(self, action: #selector(userAttentionBtnClick(sender:)), for: .touchUpInside)
            
            return cell
        }else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: GIVE_LIKE_CELL_ID) as! GiveLikeTableViewCell
            cell.accessoryType = .disclosureIndicator
            
            let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
            let greats: NSAttributedString = NSAttributedString(string: "点赞", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
            let numbers: NSAttributedString = NSAttributedString(string: "(" + String(suportUsersArray.count) + ")", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.7215686275, green: 0.7215686275, blue: 0.7215686275, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 11.0)])
            attributedStrM.append(greats)
            attributedStrM.append(numbers)
            cell.greatNumberLabel.attributedText = attributedStrM
            cell.greatNumberLayoutConstraint.constant = 42+CGFloat((numbers.length-2)*8)
            
            let bol: Bool = suportUsersArray.count > 7
            var x = 0
            for i in 0..<suportUsersArray.count {
                
                let picView: UIImageView = UIImageView.init()
                picView.frame = CGRect(x: x, y: (PHOTO_HEADER_VIEW_HEIGHT-30)/2, width: 30, height: 30)
                picView.layer.masksToBounds = true
                picView.layer.cornerRadius = picView.frame.height / 2
                
                if bol && i == 7 {
                    
                    picView.image = #imageLiteral(resourceName: "photo_detail_suportmore.png")
                    cell.listSomePraiseView.addSubview(picView)
                    break
                }
            
                picView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (suportUsersArray[i].user?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
                cell.listSomePraiseView.addSubview(picView)
                
                x = x + Int(picView.frame.width) + 5
            }
            
            return cell
        }
        
        // Support Users
        let supportCell = tableView.dequeueReusableCell(withIdentifier: SUPPORT_USER_CELL_ID) as! SupportUserTableViewCell
        
        let photoUserInfo = self.photoCommentArray[indexPath.row]
        
        // 设置头像
        supportCell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (photoUserInfo.user?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        
        // 设置名称
        supportCell.showTitleLabel.text = photoUserInfo.user?.nickname
        
        // 设置评论时间
        let takedate = Date.init(timeIntervalSince1970: TimeInterval(photoUserInfo.createdTime! / 1000))
        supportCell.showDetailLabel.text = NSDate.stringNormalRead(with: takedate)
        
        var contentStr = ""
        if photoUserInfo.replyUserId != "" && photoUserInfo.replyUser != nil {
            contentStr = "回复" + (photoUserInfo.replyUser?.nickname)! + "：" + AddressPickerDemo.stringReplaceEncode(with: photoUserInfo.content)
            
            let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
            let strA: NSAttributedString = NSAttributedString(string: "回复", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
            let strB: NSAttributedString = NSAttributedString(string: (photoUserInfo.replyUser?.nickname)!, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
            let strC: NSAttributedString = NSAttributedString(string: "：" + AddressPickerDemo.stringReplaceEncode(with: photoUserInfo.content), attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)])
            attributedStrM.append(strA)
            attributedStrM.append(strB)
            attributedStrM.append(strC)
            supportCell.showReplyLabel.attributedText = attributedStrM
        }else {
            contentStr = AddressPickerDemo.stringReplaceEncode(with: photoUserInfo.content)
            supportCell.showReplyLabel.text = contentStr
        }
        
        let cgRect: CGRect = self.labelSize(text: contentStr)
        supportCell.showReplyLayoutConstraint.constant = cgRect.size.height + 5
        
        // 评论添加长按手势
        let longPressGr: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressToDo))
        longPressGr.minimumPressDuration = 1.0
        supportCell.addGestureRecognizer(longPressGr)
        
        return supportCell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转到个人主页
        let userInfo: UserInfoModel?
        if indexPath.section == 0 {
            //
            userInfo = self.publicUserInfo
            
            // 判断栈中是否含有 MineHomePageViewController 控制器
            let allViewControllerArray = self.navigationController?.viewControllers
            for item  in allViewControllerArray! {
                if item.classForCoder == MineHomePageViewController.classForCoder() {
                    let mineVc = item as! MineHomePageViewController
                    mineVc.userInfo = userInfo
                    mineVc.setTableViewHeaderView()
                    self.navigationController?.popToViewController(mineVc, animated: true)
                    return
                }
            }
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
            viewController.userInfo = userInfo
            self.navigationController?.pushViewController(viewController, animated: true)
        }else if indexPath.section == 1 {
            
            self.performSegue(withIdentifier: "Segue_ThumbUp", sender: nil)
        } else if indexPath.section == 2 {
            // 是否登录
            if APP_DELEGATE.currentUserInfo == nil {
                APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
                return
            }
            
            // 判断临时用户升级
            if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
                APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
                return
            }
            
            // 回复
            self.commentBackView?.joinOrganization(view: self.view, commentBackView: self.commentBackView!, photoId: (self.senceData?.id)!, replyUserId: (self.photoCommentArray[indexPath.row].user?.id)!)
            self.commentBackView?.setInputPrompt(str: "回复" + (self.photoCommentArray[indexPath.row].user?.nickname)! + "：")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Segue_ThumbUp" {
            
            let thumbUp: ThumbUpViewController = segue.destination as! ThumbUpViewController
            thumbUp.senceData = self.senceData
        }
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(PHOTO_USER_CELL_HEIGHT)
        }else if indexPath.section == 1 {
            return CELL_NORMAL_HEIGHT
        }
        
        let cgRect: CGRect?
        
        if self.photoCommentArray[indexPath.row].replyUserId != "" && self.photoCommentArray[indexPath.row].replyUser != nil {
            
            cgRect = self.labelSize(text: "回复" + (self.photoCommentArray[indexPath.row].replyUser?.nickname)! + "：" + AddressPickerDemo.stringReplaceEncode(with: self.photoCommentArray[indexPath.row].content))
        }else {
            cgRect = self.labelSize(text:  AddressPickerDemo.stringReplaceEncode(with: self.photoCommentArray[indexPath.row].content))
        }
        
        return CGFloat(cgRect!.size.height + 50)
    }
    
    // MARK: section Header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PHOTO_HEADER_VIEW_ID)
            
            return headerView
        }
        
        return nil
    }
    
    
    // MARK: section Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return CGFloat(PHOTO_HEADER_VIEW_HEIGHT)
        }else if section == 1 {
            
            return 0.1
        }
        
        return 5.0
    }
    
    // MARK: section Footer Height 
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 5.0
        }
        return 0.1
    }
    
    // MARK: scroll did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let alphaValue = (scrollView.contentOffset.y - NAVIGATION_AND_STATUS_HEIGHT) / 300.0
        if alphaValue > 0 {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color: UIColorRGBA_Selft(r: 252, g: 81, b: 81, a: alphaValue)), for: .default)
        } else {
            if SCREEN_HEIGHT == 812.0 {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navBg2"), for: .default)
            } else {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navBg"), for: .default)
            }
        }
    }
    
    
    // MARK:  - XC_touchTextviewDelegate
    // MARK:
    func cilckOption(_ cilckString: String!) {
        let userNameStr = cilckString as NSString
        let username = userNameStr.substring(from: 1)
        for user in (self.senceData?.giftUserList)! {
            if user.nickname == username {
                // 跳转个人主页
                // 判断栈中是否含有 MineHomePageViewController 控制器
                let allViewControllerArray = self.navigationController?.viewControllers
                for item  in allViewControllerArray! {
                    if item.classForCoder == MineHomePageViewController.classForCoder() {
                        let mineVc = item as! MineHomePageViewController
                        mineVc.userInfo = user
                        mineVc.setTableViewHeaderView()
                        self.navigationController?.popToViewController(mineVc, animated: true)
                        return
                    }
                }
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
                viewController.userInfo =  user
                self.navigationController?.pushViewController(viewController, animated: true)
                
            }
        }
    }
    
    
    // MARK: 关注按钮点击响应方法
    @objc func userAttentionBtnClick(sender: UIButton) {
        // 是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserAttention(userId: (self.publicUserInfo?.id)!, isLike: !(self.publicUserInfo?.isAttention ?? false)!, responseSuccess: { (responseSuccess) in
            //
            self.publicUserInfo?.isAttention = !(self.publicUserInfo?.isAttention)!
            
            if (self.publicUserInfo?.isAttention)! {
                // 关注成功
                MBProgressHUD.show("已关注", icon: nil, view: self.view)
            } else {
                // 取消关注
                MBProgressHUD.show("取消关注", icon: nil, view: self.view)
            }
            
            // 更新publicUserInfo 信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (self.publicUserInfo?.id)!, responseSuccess: { (objectSuccess) in
                self.publicUserInfo = objectSuccess as? UserInfoModel
                self.tableView.reloadData()
                MBProgressHUD.hide()
            }) {(erro) in
                MBProgressHUD.hide()
            }
        }) { (error) in
            
        }
    
    }
    
    // 图片点击浏览
    func showImageDetail(index: Int) {
        let modelOne = LWImageBrowserModel.init(placeholder: nil, thumbnailURL: URL.init(string: WEBBASEURL_IAMGE + (self.senceData?.dehazePhoto)!), hdurl: URL.init(string: WEBBASEURL_IAMGE + (self.senceData?.dehazePhoto)!), containerView: self.tableView.tableHeaderView, positionInContainer: self.showDealImageView.frame, index: 0)
        
        let modelTwo = LWImageBrowserModel.init(placeholder: nil, thumbnailURL: URL.init(string: WEBBASEURL_IAMGE + (self.senceData?.originalPhoto)!), hdurl: URL.init(string: WEBBASEURL_IAMGE + (self.senceData?.originalPhoto)!), containerView: self.tableView.tableHeaderView, positionInContainer: self.showOriginImageView.frame, index: 1)
        
        let browser = LWImageBrowser.init(imageBrowserModels: [modelOne!, modelTwo!], currentIndex: index)
        browser?.show()
    }
    
    // MARK: 图片点赞响应
    @IBAction func showSupportCountBtnClick(_ sender: JQEmitterButton) {
        
        if !thumbUpStateJudgment() {
            
            return
        }
        
        sender.showPaoPaoAnimation()    // 显示泡泡动画
        thumbUpHttp()
    }
    
    // 点赞前状态判断
    func thumbUpStateJudgment() -> Bool {
        
        // 本地页面跳转
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return false
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleTemp.rawValue {
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return false
        }
        
        if self.senceData?.isLike != nil && (self.senceData?.isLike)! {
            MBProgressHUD.show("已点过赞", icon: nil, view: self.view)
            return false
        }
        
        return true
    }
    
    // 跟服务端连接点在操作
    func thumbUpHttp() {
        
        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebPhotoSupport(photoId: (self.senceData?.id)!, isLike: true, responseSuccess: { (objectSuccess) in
            //            let photoLike = objectSuccess as! PhotoLike
            // 点赞成功
            MBProgressHUD.hide(for: self.view, animated: true)
            // 重新获取图片详情
            self.getWebImageDetail()
            
            // 重新获取点赞用户列表
            self.getWebPhotoSupportUserList(pageIndex: 1)
            
            // 更新本地碳币数
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_CoinTaskUpdate), object: CoinTaskUpdateType.updateCoinCount.rawValue)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.tintColor = UIColor.white
        myPrint(message: "width:\(SCREEN_WIDTH) heigth:\(SCREEN_HEIGHT)")
        if SCREEN_HEIGHT == 812.0 {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navBg2"), for: .default)
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "navBg"), for: .default)
        }
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    // MARK: view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        self.scrollViewDidScroll(self.tableView)
        
    }
    
    // MARK: view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: 友盟分享type
    func shareWebPageToPlatformType(platformType: UMSocialPlatformType) {
        
        //创建分享消息对象
        let messageObject = UMSocialMessageObject.init()
        
        //分享消息对象设置分享内容对象
        let shareObject = UMShareImageObject.init()
        
        // 获取到分享图片
//        let shareImageView = UIImageView.init()
        if self.shareDealImage == nil {
            MBProgressHUD.show("图片加载中...", icon: nil, view: self.view)
        } else {
            shareObject.shareImage = ShowPhotoViewController.setSharCardView(publishUser: self.publicUserInfo!, senceData: self.senceData!, image: self.shareDealImage!)
            messageObject.shareObject = shareObject
            
            //调用分享接口
            UMSocialManager.default()
            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self) { (data, error) in
                if (error != nil) {
                    MBProgressHUD.show("分享取消", icon: nil, view: self.view)
                } else {
                    MBProgressHUD.show("已分享", icon: nil, view: self.view)
                    
                }
            }
            
            // 更新分享图片任务记录
            OtherBusiness.shareIntance.responseWebShareTaskNotify(taskShareCode: TaskCodeType.sharePhoto, responseSuccess: { (objectSuccess) in
                // 更新本地碳币数
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_CoinTaskUpdate), object: CoinTaskUpdateType.updateCoinCount.rawValue)
            }, responseFailed: { (error) in
            })
        }
        
    }
    
    
    // MARK: 获取分享cardView
    static func setSharCardView(publishUser: UserInfoModel, senceData: PhotoModel, image: UIImage) -> UIImage {
        // 设置分享页面
        let shareView = ShareCardView.shareInstance()
        shareView?.showImage = image
        shareView?.showPM25 = senceData.pm25
        let takeDate = Date.init(timeIntervalSince1970: (senceData.takeTime)! / 1000)
        shareView?.showTimeStr = "拍摄于 " + NSDate.string(from: takeDate, andFormatterString: "yyyy/MM/dd")
        //        shareView?.showTimeStr = "拍摄于 " + tools.string(from: takeDate, andFormatterString: "yyyy/MM/dd")
        shareView?.showAddress = senceData.address
        shareView?.showUserName = publishUser.nickname
        shareView?.loadInitData()
        let topImage = UIImage.init(view: shareView?.showCardView)
        //        let topImage = tools.image(with: shareView?.showCardView)
        
        // bottomImage
        let bottomImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 375.0, height: 74.0))
        bottomImageView.image = UIImage.init(named: "share_appflag.jpg")
        bottomImageView.contentMode = .scaleAspectFit
        bottomImageView.backgroundColor = UIColor.white
        let bottomImage = UIImage.init(view: bottomImageView)
        //        let bottomImage = tools.image(with: bottomImageView)
        
        return self.combineSX(topImage: topImage!, bottomImage: bottomImage!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //**************  网络数据请求 **********************//
    // 获取图片详情
    func getWebImageDetail() {
        // 获取图片详情
        PhotoBusiness.shareIntance.responseWebGetPhotoDetail(photoId: (senceData?.id)!, responseSuccess: { (objectSuccess) in
            self.senceData = objectSuccess as? PhotoModel
            
            // 刷新数据
            // 请求拍摄者信息
            self.publicUserInfo = self.senceData?.user
            self.setViewUI()
            self.tableView.reloadData()
            
            // 发送更新用户信息的广播
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PhotoInfo), object: self.senceData)
        }) { (error) in
        }
        
    }
    
    // 获取点赞用户的列表
    func getWebPhotoSupportUserList(pageIndex: Int) {
//        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetPhotoSupportUsersList(pageIndex: pageIndex, photoId: (self.senceData?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<PhotoLike>
            if pageIndex == 1 {
                self.suportUsersArray.removeAll()
                self.suportUsersArray = pageResult.beanList!
            } else {
                self.suportUsersArray = self.suportUsersArray + pageResult.beanList!
            }
            
            myPrint(message: objectSuccess)
            self.tableView.reloadData()
            
            // 判断是否到底
            if pageResult.pageCode! >= pageResult.totalPage! {
                self.tableView.es.noticeNoMoreData()
            }
            
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // 获取照片评论的列表
    func getWebResponseSuccessList(pageIndex: Int) {
//        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebGetResponseSuccessList(pageIndex: pageIndex, photoId: (self.senceData?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<PhotoLike>
            if pageIndex == 1 {
                self.photoCommentArray.removeAll()
                self.photoCommentArray = pageResult.beanList!
            } else {
                self.photoCommentArray = self.photoCommentArray + pageResult.beanList!
            }
            myPrint(message: objectSuccess)
            self.tableView.reloadData()
            
            // 判断是否到底
            if pageResult.pageCode! >= pageResult.totalPage! {
                self.tableView.es.noticeNoMoreData()
            }
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // 删除照片一条评论
    func getWebPhotoCommentDelete(pageIndex: Int) {
        //        MBProgressHUD.showMessage("", to: self.view)
        PhotoBusiness.shareIntance.responseWebPhotoCommentDelete(photoId: photoCommentArray[pageIndex].id!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            myPrint(message: objectSuccess)
            MBProgressHUD.show("删除成功", icon: nil, view: self.view)
            self.page = 1
            self.getWebResponseSuccessList(pageIndex: self.page)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     计算label的宽度和高度
     :param: text       label的text的值
     :returns: 返回计算后label的CGRece
     */
    func labelSize(text: String) -> CGRect{
        
        let attributes = [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14.0)] // 设置字体大小
        
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let rect: CGRect = text.boundingRect(with: CGSize.init(width: SCREEN_WIDTH-74, height: 999.9), options: option, attributes: attributes, context: nil) // 获取字符串的frame
        
        return rect
    }
}

extension ShowPhotoViewController {
    func setViewUI() {
    /*    // 设置 标签 根据类型判断
        for dict in PHOTO_CODE_ARRAY {
            if dict["code"] == self.senceData?.photoTypeCode! {
                self.showFlagLabel.text = dict["title"]
 
                // 将16进制字符串转成Int
                let hexString = dict["color"]
                var result:UInt32 = 0
                Scanner(string: hexString!).scanHexInt32(&result)//result = 43
                self.showFlagLabel.backgroundColor = UIColorFromRGB(rgbValue: Int(result))
                
                // 动态试着Label宽度
                let labelWidth = tools.getLabelWidth(with: self.showFlagLabel)
                self.showFlagLabel.width = labelWidth + 20
                
            }
        } */
        
        // 设置 标签 根据PM2.5判断 (self.senceData?.pm25)!
        let labeltextDict = ShowPhotoViewController.airQualityChangeToString(pm25: (self.senceData?.pm25)!)
        // 将16进制字符串转成Int
        let hexString = labeltextDict["color"]
        var result:UInt32 = 0
        Scanner(string: hexString!).scanHexInt32(&result)//result = 43
        self.showFlagLabel.backgroundColor = UIColorFromRGB(rgbValue: Int(result))
        self.showFlagLabel.text = labeltextDict["title"]
        
        // 动态试着Label宽度
        let labelWidth = UILabel.getLabelWidth(with: self.showFlagLabel)
//        let labelWidth = tools.getLabelWidth(with: self.showFlagLabel)
        self.showFlagLabel.width = labelWidth + 20
        
        
        self.showFlagLabel.layer.masksToBounds = true
        self.showFlagLabel.layer.cornerRadius = 4
        
        // set deal Image
        self.showDealImageView.clipsToBounds = true
        self.showDealImageView.contentMode = .scaleAspectFill
        
        self.setDescriptionAndAtUserLabelHeight(imageHeight: 405)
        // 设置默认缩略图
        //self.showDealImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (self.senceData?.thumbPhoto)!), placeholderImage: DEFAULT_IMAGE())
        
        // 更新大图显示
        self.showDealImageView.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE + (self.senceData?.dehazePhoto!)!), completed:{ (image, error, cacheType, url) in
            if (image != nil) {
                self.showDealImageView.image = image
                self.shareDealImage = image

                let imageHeight = SCREEN_WIDTH / ((image?.size.width)! / (image?.size.height)!)
                self.showDealImageViewHeightConstraint.constant = imageHeight
                self.photoInfoViewTopContraint.constant = imageHeight - 169
                if SCREEN_HEIGHT >= 812.0 {
                    self.photoInfoViewTopContraint.constant = imageHeight - 194
                }


                // 设置文字高度
                self.setDescriptionAndAtUserLabelHeight(imageHeight: imageHeight)
            } else {
               self.showDealImageView.image = DEFAULT_IMAGE()
            }
        })
        
        self.showDealImageView.isUserInteractionEnabled = true
        self.showDealImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.showImageDetail(index: 0)
        }))
        
        
        // set origin image
//        self.showOriginImageView.clipsToBounds = true             // 会截取阴影显示
        self.showOriginImageView.contentMode = .scaleAspectFill
        self.showOriginImageView.sd_setImage(with: URL.init(string:WEBBASEURL_IAMGE + (self.senceData?.originalPhoto!)!), placeholderImage: DEFAULT_IMAGE())
        self.showOriginImageView.layer.shadowOffset = CGSize(width: 0, height: 0);//偏移距离
        self.showOriginImageView.layer.shadowOpacity = 0.8;//不透明度
        self.showOriginImageView.layer.shadowRadius = 6;//半径
        self.showOriginImageView.isUserInteractionEnabled = true
        self.showOriginImageView.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            self.showImageDetail(index: 1)
        }))
        
        // 设置 PM2.5
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_BIG_SIZE, minFont: 9.0, color: colorPm25WithValue(pm25Value: (senceData?.pm25)!), action: {})
        var strText = "PM2.5：<help><link><FontMax>\(String(describing: (senceData?.pm25)!))</FontMax></link></help> μg/m³" as NSString?
        if APP_DELEGATE.isCheckApp {
            strText = "最近站点PM2.5：<help><link><FontMax>\(String(describing: (senceData?.pm25)!))</FontMax></link></help> μg/m³" as NSString?
        }
        self.showPm25Label.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 设置拍摄地址
        UIView.removeSubviews(self.showAddressLabel)
        let rollLabel = YFRollingLabel.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 27 - 13, height: 17), textArray: [self.senceData?.address == "" ? "未获取到地址信息" : (self.senceData?.address)!], font: UIFont.systemFont(ofSize: FONT_STANDARD_SIZE), textColor: UIColor.white)
        rollLabel?.speed = 1;
        rollLabel?.orientation = .left
        rollLabel?.internalWidth = self.showAddressLabel.width / 3
        rollLabel?.textAlignment = .left
        rollLabel?.labelClickBlock = { (index: Int) -> () in
            myPrint(message: "addressLabel click index = \(index)")
        }
        self.showAddressLabel.addSubview(rollLabel!)

        
        shareButton.setLeftAndRightTextWith(#imageLiteral(resourceName: "photo_detail_share.png"), withTitle: "分享", for: UIControl.State.normal, withTextFont: 15, andAlignment: UIControl.ContentHorizontalAlignment.center)
        commentsButton.setLeftAndRightTextWith(#imageLiteral(resourceName: "photo_detail_comment.png"), withTitle: "评论", for: UIControl.State.normal, withTextFont: 15, andAlignment: UIControl.ContentHorizontalAlignment.center)
        
        // 设置点赞数
        self.showSupportCountBtn.setTitle(String(describing: (self.senceData?.likeCount)!), for: .normal)
        if self.senceData?.isLike != nil && (self.senceData?.isLike)! {
            self.showSupportCountBtn.setImage(UIImage.init(named: "home_support_selected"), for: .normal)
            giveLikeButton.setLeftAndRightTextWith(#imageLiteral(resourceName: "photo_detail_support_sel.png"), withTitle: String(describing: (self.senceData?.likeCount)!), for: UIControl.State.normal, withTextFont: 15, andAlignment: UIControl.ContentHorizontalAlignment.center)
            giveLikeButton.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.7)
            giveLikeButton.setTitleColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.7), for: UIControl.State.normal)
        } else {
            self.showSupportCountBtn.setImage(UIImage.init(named: "home_support_cell"), for: .normal)
            giveLikeButton.setLeftAndRightTextWith(#imageLiteral(resourceName: "photo_detail_support_nor.png"), withTitle: "点赞", for: UIControl.State.normal, withTextFont: 15, andAlignment: UIControl.ContentHorizontalAlignment.center)
        }
        
        // 设置拍摄时间
        let takeDate = Date.init(timeIntervalSince1970: (self.senceData?.takeTime)! / 1000)
        self.showTakePhoteTimeLabel.text = "拍摄于 " + NSDate.stringNormalRead(with: takeDate)
    }
    
    
    // MARK: 设置文字描述和点赞用户的高度
    func setDescriptionAndAtUserLabelHeight(imageHeight: CGFloat) {
        let initViewHeight = (imageHeight+35)
        // 设置文字描述和@用户
        self.tableView.tableHeaderView?.addSubview(self.showDescriptionAtUserLabel)
        self.showDescriptionAtUserLabel.width = SCREEN_WIDTH - 2 * 37
        self.showDescriptionLabel.isHidden = true
        self.showDescriptionLabel.width = self.showDescriptionAtUserLabel.width
        if self.senceData?.description?.lengthOfBytes(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) == 0 {
            // 没有描述
            self.tableView.tableHeaderView?.height = initViewHeight
            self.showDescriptionAtUserLabel.isHidden = true
        } else {
            self.showDescriptionAtUserLabel.isHidden = false
            // 对图片描述进行解码
            var descriStr = AddressPickerDemo.stringReplaceEncode(with: self.senceData?.description)
            self.showDescriptionLabel.text = descriStr
            
            var descriStr2 = NSString.init(string: descriStr!)
            for user in (self.senceData?.giftUserList)! {
                descriStr2 = descriStr2.replacingOccurrences(of: "@\(user.id!) ", with: "@\(user.nickname!) ") as NSString
            }
            descriStr = descriStr2 as String
            
            self.showDescriptionAtUserLabel.attributedText = XCWordChangeTool.attributedText(withText: descriStr, andLineSpacing: 6.0)
            
            let textHeight = UILabel.getSpaceLabelHeight(self.showDescriptionAtUserLabel.text, with: self.showDescriptionAtUserLabel.font, withWidth: self.showDescriptionAtUserLabel.width, andLineSpaceing: 6.0)
            self.showDescriptionAtUserLabel.height = textHeight
            self.tableView.tableHeaderView?.height = initViewHeight + textHeight + 5
        }
        // 设置y值
        self.showDescriptionAtUserLabel.y = initViewHeight
        
        
        // 设置分割线位置
        self.showBottomLineView.y = (self.tableView.tableHeaderView?.height)! - 0.5
        self.showBottomLineView.width = SCREEN_WIDTH
        
        self.tableView.tableHeaderView?.layoutSubviews()
        self.tableView.reloadData()
    }
    
    
    // MARK: 图片拼接
    static func combineSX(topImage: UIImage, bottomImage: UIImage) -> UIImage {
        let size = CGSize(width: topImage.size.width , height: topImage.size.height + bottomImage.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        topImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: topImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: topImage.size.height, width: size.width, height: bottomImage.size.height))
        
        let togetherImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return togetherImage!
    }
    
    
    // 空气质量显示文字等级显示
    static func airQualityChangeToString(pm25: Int) -> [String : String] {
        let defaultColorStr = "0x999999"
        if pm25 < 50 {
            return ["title" : "空气很棒", "color" : PHOTO_CODE_ARRAY[0]["color"] ?? defaultColorStr]
        } else if pm25 < 100 {
            return ["title" : "空气不错", "color" : PHOTO_CODE_ARRAY[1]["color"] ?? defaultColorStr];
        } else if pm25 < 200 {
            return ["title" : "空气有点糟糕", "color" : PHOTO_CODE_ARRAY[2]["color"] ?? defaultColorStr];
        } else if pm25 < 500 {
            return ["title" : "空气太差了", "color" : PHOTO_CODE_ARRAY[3]["color"] ?? defaultColorStr]
        } else {
            return ["title" : "空气爆表了", "color" : PHOTO_CODE_ARRAY[4]["color"] ?? defaultColorStr];
        }
    }
    
}

