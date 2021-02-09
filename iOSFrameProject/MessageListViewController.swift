//
//  MessageListViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/12.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MessageListViewController: UIViewController, STSegmentViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    fileprivate var dataSource: [MessageModel] = []

    @IBOutlet weak var menuTopView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var segmentView: STSegmentView?
    
    var messageTypeCode: MessageTypeCode? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "消息"
        
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        let rightBarBtnItem = UIBarButtonItem.init(title: "全部已读", style: .plain, target: self, action: #selector(rightBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationItem.rightBarButtonItem = rightBarBtnItem
        
        
        // 获取 photo code title
        var titleArray: [String] = ["全部", "关注", "点赞", "评论", "@我"]
        if APP_DELEGATE.currentUserInfo?.roleCode == RoleCodeType.roleMerchant.rawValue {
            // 是商家
            titleArray.append("到账")
            titleArray.append("提现")
        }
        titleArray.append("其它")
        
        // segmentView
        let segmentViewWidth = 50 * titleArray.count
        self.segmentView = STSegmentView.init(frame: CGRect(x: 0, y: 0, width: segmentViewWidth, height: Int(self.menuTopView.height)))
        self.segmentView?.titleArray = titleArray;
        self.segmentView?.titleSpacing = 5;
        self.segmentView?.labelFont = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE);
        self.segmentView?.bottomLabelTextColor = COLOR_GAY;
        self.segmentView?.topLabelTextColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.selectedBackgroundColor = UIColor.clear;
        //        self.segmentView?.selectedBgViewCornerRadius = 20;
        self.segmentView?.sliderHeight = 5;
        self.segmentView?.sliderColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.sliderTopMargin = 0;
        self.segmentView?.backgroundColor = UIColor.clear
        self.segmentView?.duration = 0.3;
        self.segmentView?.delegate = self
        
        // scroll View
        let scrollTopMenuView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT - 1))
        scrollTopMenuView.addSubview(self.segmentView!)
        scrollTopMenuView.contentSize = CGSize(width: CGFloat(segmentViewWidth), height: STATUS_BAR_HEIGHT)
        scrollTopMenuView.showsVerticalScrollIndicator = false
        scrollTopMenuView.showsHorizontalScrollIndicator = false
        self.menuTopView.addSubview(scrollTopMenuView)
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init()
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        self.tableView.register(UINib.init(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: MessageTableViewCell.CELL_ID)
        
        // 设置刷新
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        // 获取网络数据
        self.getMessageList(messageTypeCode: self.messageTypeCode, pageCount: self.page)
    }
    
    
    // MARK: 刷新
    public func refresh() {
        self.page = 1
        // 获取网络数据
        self.getMessageList(messageTypeCode: self.messageTypeCode, pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getMessageList(messageTypeCode: self.messageTypeCode, pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    @objc func rightBarBtnItemClick(sender: UIBarButtonItem) {
        // 全部已读
        self.markHaveReadedAllMessage()
    
        UserDefaults.standard.set(true, forKey: DICT_IS_MESSAGE_ALL_READED)
        UserDefaults.standard.synchronize()
        // 发送全部消息已读通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_MessageAllRead), object: nil)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.CELL_ID) as! MessageTableViewCell
        cell.selectionStyle = .none
        
        // 解析数据
        let message = self.dataSource[indexPath.row]
        
        // time
        let takeDate = Date.init(timeIntervalSince1970: TimeInterval(message.createdTime! / 1000))
        cell.showTimeLabel.text = NSDate.stringNormalRead(with: takeDate)
        
        // title
        if message.readed != nil && message.readed! {
            // 已读
            cell.showTitleBtn.setRightAndleftTextWith(#imageLiteral(resourceName: "message_read.png"), withTitle: message.title!, for: .normal, andImageFontValue: Float(FONT_STANDARD_SIZE), andTitleFontValue: Float(FONT_STANDARD_SIZE), andTextAlignment: .left)
        } else {
            // 未读
            cell.showTitleBtn.setRightAndleftTextWith(#imageLiteral(resourceName: "message_unread.png"), withTitle: message.title!, for: .normal, andImageFontValue: Float(FONT_STANDARD_SIZE), andTitleFontValue: Float(FONT_STANDARD_SIZE), andTextAlignment: .left)
        }
        
        // detail
        cell.showDetailLabel.text = message.content
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 解析数据
        let message = self.dataSource[indexPath.row]
        self.markHaveReadedMessage(message: message)
        
        switch message.messageTypeCode! {
        case MessageTypeCode.getMoney.rawValue, MessageTypeCode.withdraw.rawValue:
            myPrint(message: "到账提醒, 提现提醒")
            MBProgressHUD.showMessage("")
        MerchantBusiness.shareIntance.responseWebGetMerchantTradeRecordDetail(tradeId: message.link!, responseSuccess: { (objectSuccess) in
                MBProgressHUD.hide()
                // 跳转到商户中心，交易记录详情
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TradeRecordDetailView") as! TradeRecordDetailViewController
                viewController.tradeRecord = objectSuccess as? MerchantTradeRecordModel
                self.navigationController?.pushViewController(viewController, animated: true)
            }) { (error) in
            }
            
        case MessageTypeCode.sendPhoto.rawValue, MessageTypeCode.comment.rawValue, MessageTypeCode.support.rawValue:
            myPrint(message: "@送照片消息, 评论照片, 照片点赞")
            MBProgressHUD.showMessage("")
            PhotoBusiness.shareIntance.responseWebGetPhotoDetail(photoId: message.link!, responseSuccess: { (objectSuccess) in
                MBProgressHUD.hide()
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowPhotoView") as! ShowPhotoViewController
                viewController.senceData = objectSuccess as? PhotoModel
                self.navigationController?.pushViewController(viewController, animated: true)
            }) { (error) in
            }
            
        case MessageTypeCode.attention.rawValue:
            myPrint(message: "用户关注")
            MBProgressHUD.showMessage("")
            // 获取用户信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: message.link!, responseSuccess: { (objectSuccess) in
                MBProgressHUD.hide()
                // 跳转用户首页
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
                viewController.userInfo = objectSuccess as? UserInfoModel
                self.navigationController?.pushViewController(viewController, animated: true)
            }) { (error) in
            }
        default:
            myPrint(message: "其它")
            // 通用消息显示
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageDetailView") as! MessageDetailViewController
            viewController.message = message
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MessageTableViewCell.CELL_HEIGHT
    }
    
    
    
    // MARK: - STSegmentViewDelegate
    // MARK: button click
    func buttonClick(_ index: Int) {
        self.tableView.scrollsToTop = true
        
//        ["全部", "关注", "点赞", "评论", "@我", "到账", "提现", "其它"]
        let titleName = self.segmentView?.titleArray[index] as! String
        self.page = 1
        self.messageTypeCode = nil
        switch titleName {
        case "全部":
            self.messageTypeCode = nil
        case "关注":
            self.messageTypeCode = MessageTypeCode.attention
        case "点赞":
            self.messageTypeCode = MessageTypeCode.support
        case "评论":
            self.messageTypeCode = MessageTypeCode.comment
        case "@我":
            self.messageTypeCode = MessageTypeCode.sendPhoto
        case "到账":
            self.messageTypeCode = MessageTypeCode.getMoney
        case "提现":
            self.messageTypeCode = MessageTypeCode.withdraw
        default:
            self.messageTypeCode = MessageTypeCode.other
        }
        self.getMessageList(messageTypeCode: self.messageTypeCode, pageCount: self.page)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : COLOR_DARK_GAY]
        self.navigationController?.navigationBar.tintColor = COLOR_GAY
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    
    // MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    
    // MARK: did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var isAllReaded = true
        for message in self.dataSource {
            if message.readed != nil && !message.readed! {
                isAllReaded = false
                break
            }
        }
        UserDefaults.standard.set(isAllReaded, forKey: DICT_IS_MESSAGE_ALL_READED)
        UserDefaults.standard.synchronize()
        // 发送全部消息已读通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_MessageAllRead), object: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: 获取消息列表
    func getMessageList(messageTypeCode: MessageTypeCode?, pageCount: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        MessageBusiness.shareIntance.responseWebGetMessagePage(messageTypeCode: messageTypeCode, isReaded: nil, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<MessageModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                
                self.dataSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: objectSuccess)
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    // MARK: 标记已读消息
    func markHaveReadedMessage(message: MessageModel) {
        MessageBusiness.shareIntance.responseWebMessageRead(messageId: message.id!, responseSuccess: { (objectSuccess) in
            if !message.readed! {
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
            message.readed = true
            self.tableView.reloadData()
        }) { (error) in
        }
    }
    
    // MARK: 标记全部已读消息
    func markHaveReadedAllMessage() {
        MBProgressHUD.showMessage("", to: nil)
        MessageBusiness.shareIntance.responseWebMessageReadAll(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide()
            MBProgressHUD.show("全部消息已读", icon: nil, view: self.view)
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            self.page = 1
            self.getMessageList(messageTypeCode: self.messageTypeCode, pageCount: self.page)
        }) { (error) in
        }
    }
}
