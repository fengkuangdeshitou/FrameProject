//
//  ThumbUpViewController.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class ThumbUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var senceData: PhotoModel?
    fileprivate var suportUsersArray: Array<PhotoLike> = []
    
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.title = "点赞过的人"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        tableView.tableFooterView = UIView.init()
        
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
        
        tableView.refreshIdentifier = String.init(describing: type)
        tableView.expiredTimeInterval = Double(REQUEST_TIMEOUT_VALUE)
        
        // 获取图片点赞列表
        getWebPhotoSupportUserList(page: self.page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationStyle()
    }
    
    // MARK:  设置导航栏样式
    func setNavigationStyle() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = COLOR_HIGHT_LIGHT_SYSTEM
    }
    
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return suportUsersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let initIdentifier = "Cell"
        let cell: ThumbUpTableViewCell = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as! ThumbUpTableViewCell
        
        cell.picView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (suportUsersArray[indexPath.row].user?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))

        // 设置名称
        cell.nameLabel.text = suportUsersArray[indexPath.row].user?.nickname
        
        // 设置粉丝数
        cell.numberLabel.text = "粉丝数 \(String(describing: (suportUsersArray[indexPath.row].user?.followAmount)!))"
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none // 点击不变色
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let allViewControllerArray = self.navigationController?.viewControllers
        for item  in allViewControllerArray! {
            if item.classForCoder == MineHomePageViewController.classForCoder() {
                let mineVc = item as! MineHomePageViewController
                mineVc.userInfo = suportUsersArray[indexPath.row].user
                mineVc.setTableViewHeaderView()
                self.navigationController?.popToViewController(mineVc, animated: true)
                return
            }
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MineHomePageView") as! MineHomePageViewController
        viewController.userInfo = suportUsersArray[indexPath.row].user
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取图片点赞列表
        getWebPhotoSupportUserList(page: self.page)
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取图片点赞列表
        getWebPhotoSupportUserList(page: self.page)
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    // 获取点赞用户的列表
    func getWebPhotoSupportUserList(page: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetPhotoSupportUsersList(pageIndex: page, photoId: (self.senceData?.id)!, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = objectSuccess as! PageResultModel<PhotoLike>
            if page == 1 {
                self.suportUsersArray.removeAll()
                self.suportUsersArray = pageResult.beanList!
            } else {
                self.suportUsersArray = self.suportUsersArray + pageResult.beanList!
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
}
