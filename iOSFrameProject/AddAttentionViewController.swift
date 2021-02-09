//
//  AddAttentionViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/19.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class AddAttentionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searBar: UISearchBar!
    
    
    fileprivate var dataSource: [UserInfoModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "添加关注"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set search Bar
        self.searBar.delegate = self
        self.searBar.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.searBar.placeholder = "搜索想要关注的人"
        
        // set tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "PhotoUserTableViewCell", bundle: nil), forCellReuseIdentifier: PHOTO_USER_CELL_ID)
        
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
    }
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getUserList(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getUserList(pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableView 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 设置默认空内容显示
        if self.dataSource.count == 0 {
            let tableviewBGEmptyImageView = UIImageView.init(image: #imageLiteral(resourceName: "data_empty"))
            tableviewBGEmptyImageView.contentMode = .scaleAspectFit
            self.tableView.backgroundView = tableviewBGEmptyImageView
        } else {
            self.tableView.backgroundView = nil
        }
        
        return self.dataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: PHOTO_USER_CELL_ID) as! PhotoUserTableViewCell
        cell.accessoryType = .disclosureIndicator
        
        // 解析数据
        let userInfo = self.dataSource[indexPath.row]
        
        // 设置头像
        cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + userInfo.avatar!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        
        // 设置名称 和 粉丝数
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_STANDARD_SIZE, minFont: 11.0, color: UIColor.lightGray, action: {})
        let userName = userInfo.nickname! as NSString
//        if (userInfo.nickname?.characters.count)! > WORDCOUNT_USERNAME/2 {
//            userName = userName.substring(to: WORDCOUNT_USERNAME/2) as NSString
//        }
        let strText = "\(userName)<help><link><FontMin></FontMin></link></help>" as NSString?
        cell.showTitleLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 设置描述
//        cell.showDescripationLabel.text = userInfo.speak
        cell.showDescripationLabel.text = "粉丝数 \(String(describing: (userInfo.followAmount)!))"
        
        // 设置是否关注
        if userInfo.isAttention != nil && userInfo.isAttention! {
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
        
        // 设置关注的响应
        cell.AttentionBtn.tag = indexPath.row
        cell.AttentionBtn.addTarget(self, action: #selector(userAttentionBtnClick(sender:)), for: .touchUpInside)
        
        
        return cell
    }
    
    // cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let userInfo = self.dataSource[indexPath.row]
        // 跳转到个人主页
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
        viewController.userInfo =  userInfo
        self.navigationController?.pushViewController(viewController, animated: true)
       
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(PHOTO_USER_CELL_HEIGHT)
    }
    
    // MARK: scroll will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    // MARK: 关注按钮点击响应方法
    @objc func userAttentionBtnClick(sender: UIButton) {
        // 判断是否登录
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            return
        }
        
        // 判断临时用户升级
        if APP_DELEGATE.currentUserInfo?.phoneNumber == nil || APP_DELEGATE.currentUserInfo?.phoneNumber == "" {
            // 临时用户
            APP_DELEGATE.jumpToUserUpdateViewContoller(vc: self)
            return
        }
        
        
        let userInfo = self.dataSource[sender.tag]
        userInfo.isAttention  = userInfo.isAttention == nil ? false : userInfo.isAttention
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserAttention(userId: userInfo.id!, isLike: !userInfo.isAttention!, responseSuccess: { (responseSuccess) in
            //
            userInfo.isAttention = !(userInfo.isAttention)!
            
            if (userInfo.isAttention)! {
                // 关注成功
                MBProgressHUD.show("已关注", icon: nil, view: self.view)
            } else {
                // 取消关注
                MBProgressHUD.show("取消关注", icon: nil, view: self.view)
            }
            
            // 更新publicUserInfo 信息
            UserBusiness.shareIntance.responseWebGetUserInfo(userId: (userInfo.id)!, responseSuccess: { (objectSuccess) in
                let userInfoTemp = objectSuccess as? UserInfoModel
                userInfo.followAmount = userInfoTemp?.followAmount
                self.tableView.reloadData()
                MBProgressHUD.hide()
            }, responseFailed: { (error) in
                MBProgressHUD.hide()
            })
        }) { (error) in
        }
    }
    
    
    // MARK: - UISearchBarDelegate 代理方法的实现
    // MARK: 键盘右下角的搜索按钮点击响应
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        myPrint(message: "搜索")
        // 判断搜索是否为空
        if self.searBar.text == "" {
            MBProgressHUD.show("请输入关注人名称", icon: nil, view: self.view)
            return
        }
        
        self.page = 1
        self.getUserList(pageCount: self.page)
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
    
    // MARK: 网络数据请求
    func getUserList(pageCount: Int) {
        if self.searBar.text == "" {
            return
        }
        self.view.endEditing(true)
        
        // 根据昵称搜索关注用户的相关列表
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetUserNameSearchUsersList(pageIndex: pageCount, nickName: self.searBar.text!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = resonseSuccess as! PageResultModel<UserInfoModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
                self.dataSource = pageResult.beanList!
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode == pageResult.totalPage {
                self.tableView?.es.noticeNoMoreData()
            }
            myPrint(message: resonseSuccess)
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
