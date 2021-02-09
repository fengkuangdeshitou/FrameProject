//
//  MineAttentionViewController.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/27.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit

class MineAttentionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    fileprivate var dataSource: [UserInfoModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "我关注的人"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
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
        
        // 获取网络数据
        self.getMineAttentionUsersListData(pageCount: self.page)
    }
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getMineAttentionUsersListData(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getMineAttentionUsersListData(pageCount: self.page)
        
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
        if userInfo.isAttention == nil {
            cell.AttentionBtn.isHidden = true
        }
        
        // 设置响应方法
        cell.AttentionBtn.tag = indexPath.row
        cell.AttentionBtn.addTarget(self, action: #selector(userAttentionBtnClick(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    // cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let userInfo = self.dataSource[indexPath.row]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
        viewController.userInfo = userInfo
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(PHOTO_USER_CELL_HEIGHT)
    }
    
    // MARK: header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: footer  Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // MARK: 关注按钮点击响应方法
    @objc func userAttentionBtnClick(sender: UIButton) {
        let userInfo = self.dataSource[sender.tag]
        MBProgressHUD.showMessage("")
        UserBusiness.shareIntance.responseWebUserAttention(userId: (userInfo.id)!, isLike: !(userInfo.isAttention)!, responseSuccess: { (responseSuccess) in
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
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
    
    ///  **********  网络数据请求   **************** ///
    // MARK: 获取我关注的用户列表
    func getMineAttentionUsersListData(pageCount: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetUserAtteionUserList(pageIndex: pageCount, userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = resonseSuccess as! PageResultModel<UserInfoModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                
                self.dataSource = pageResult.beanList!
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.beanList?.count == 0 {
                self.page -= 1
                if self.page < 1 { self.page = 1 }
                self.tableView.es.noticeNoMoreData()
            }
            if self.page == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }

}
