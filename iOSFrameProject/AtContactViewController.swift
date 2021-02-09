//
//  AtContactViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol AtContactViewDelegate: NSObjectProtocol {
    
    
    /// 选中用户
    ///
    /// - Parameters:
    ///   - vc: VC
    ///   - selectUser: user
    func atContactView(vc:AtContactViewController, selectUser: UserInfoModel)
}


class AtContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    weak var atContactDelegate: AtContactViewDelegate?
    
    fileprivate lazy var tableView: UITableView = {
        let tableViewTemp = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-NAVIGATION_AND_STATUS_HEIGHT), style: UITableView.Style.plain)
        tableViewTemp.delegate = self
        tableViewTemp.dataSource = self
        tableViewTemp.tableFooterView = UIView.init()
        
        tableViewTemp.register(UINib.init(nibName: "AtContactTableViewCell", bundle: nil), forCellReuseIdentifier: AtContactTableViewCell.CELL_ID)
        
        return tableViewTemp
    }()
    
    var displayController: UISearchController?
    
    var recentContactArray: [UserInfoModel] = []            // 最近联系人
    var contactArray: [UserInfoModel] = []                  // 250用户列表
    var resultArray: [UserInfoModel] = []                   // 搜索结果
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "联系人"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
        // 设置导航栏
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: NAVIGATION_TITLE_FONT_SIZE), NSAttributedString.Key.foregroundColor : COLOR_DARK_GAY]
        self.navigationController?.navigationBar.tintColor = COLOR_GAY
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        let leftBarBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        // 获取最近联系人数据
        self.showRecentContactArray()
        
        // 设置searchController
        self.initSearchController()
        
        // 设置tableView
        self.view.addSubview(self.tableView)
        self.view.sendSubviewToBack(self.tableView)
        // 去除sectionIndex 和 searchBar 的冲突
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        
        // 设置searchBar
        let headerView = UIView.init(frame: (self.displayController?.searchBar.frame)!)
        headerView.addSubview((self.displayController?.searchBar)!)
        self.displayController?.searchBar.tintColor = COLOR_HIGHT_LIGHT_SYSTEM
        self.tableView.tableHeaderView = headerView
        
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
        
        // 获取用户列表
        self.getUserList(pageCount: self.page, searchText: self.displayController?.searchBar.text)
        
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getUserList(pageCount: self.page, searchText: self.displayController?.searchBar.text)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getUserList(pageCount: self.page, searchText: self.displayController?.searchBar.text)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    func initSearchController() {
        self.displayController = UISearchController.init(searchResultsController: nil)
        self.displayController?.delegate = self
        self.displayController?.searchBar.placeholder = "输入用户昵称"
        self.displayController?.searchBar.delegate = self
        self.displayController?.searchResultsUpdater = self
        
        self.definesPresentationContext = true
        
        // 是否添加半透明覆盖层
        self.displayController?.dimsBackgroundDuringPresentation = false
        
        // 是否隐藏导航栏
        self.displayController?.hidesNavigationBarDuringPresentation = true
    }
    
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UISearchResultsUpdating
    // MARK:
    func updateSearchResults(for searchController: UISearchController) {
        // 实时搜索
        resultArray.removeAll()
        self.tableView.reloadData()
    }
    
    
    // MARK: - UISearchBarDelegate
    // MARK: searchBarShouldBeginEditing
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    
    // MARK: searchBarSearchButtonClicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.page = 1
        self.getUserList(pageCount: self.page, searchText: searchBar.text)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        if !(self.displayController?.isActive)! {
            return 2
        }
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(self.displayController?.isActive)! {
            if section > 0 {
                return contactArray.count
            } else {
                return recentContactArray.count
            }
        }
        
        return resultArray.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AtContactTableViewCell.CELL_ID) as! AtContactTableViewCell
        
        // 解析数据
        var userInfo: UserInfoModel? =  nil
        if !(self.displayController?.isActive)! {
            if indexPath.section == 0 {
                // 最近联系人
                userInfo = recentContactArray[indexPath.row]
            } else {
                // 250你发布用户列表
                userInfo = contactArray[indexPath.row]
            }
        } else {
            // 搜索后的用户列表
            userInfo = resultArray[indexPath.row]
        }
        
        
        cell.showImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (userInfo?.avatar)!), placeholderImage: UIImage.init(named: "defaultUserImage"))
        cell.showTitleLabel.text = userInfo?.nickname
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        var userInfo: UserInfoModel? =  nil
        if !(self.displayController?.isActive)! {
            if indexPath.section == 0 {
                // 最近联系人
                userInfo = recentContactArray[indexPath.row]
            } else {
                // 250你发布用户列表
                userInfo = contactArray[indexPath.row]
            }
        } else {
            // 搜索后的用户列表
            userInfo = resultArray[indexPath.row]
        }
        
        self.saveRecentContactArray(userInfo: userInfo!)
        
        if !(self.displayController?.isActive)! {
            self.dismiss(animated: true, completion: {
                self.atContactDelegate?.atContactView(vc: self, selectUser: userInfo!)
            })
        } else {
            self.displayController?.dismiss(animated: false) {
                self.dismiss(animated: true, completion: {
                    self.atContactDelegate?.atContactView(vc: self, selectUser: userInfo!)
                })
            }
        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AtContactTableViewCell.CELL_HEIGHT
    }
    
    // MARK: header View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !(self.displayController?.isActive)! {
            let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 28.0))
            headerView.backgroundColor = UIColorRGBA_Selft(r: 235.0, g: 235.0, b: 235.0, a: 1.0)
            let label = UILabel.init(frame: CGRect(x: 15.0, y: 0, width: SCREEN_WIDTH - 15*2, height: 28.0))
            label.textColor = COLOR_LIGHT_GAY
            label.font = UIFont.systemFont(ofSize: FONT_SMART_SIZE)
            headerView.addSubview(label)
            if section == 0 {
                label.text = "最近联系人"
            } else {
                label.text = "250你发布用户"
            }
            
            return headerView
        } else {
            return nil
        }
    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !(self.displayController?.isActive)! {
            return 28.0
        } else {
            return 0.1
        }
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
        self.displayController?.searchBar.resignFirstResponder()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK：判断用户是否存在数组中
    func checkUserIsExistArray(array: [UserInfoModel], user: UserInfoModel) -> Bool {
        for checkUser in array {
            if checkUser.id == user.id {
                return true
            }
        }
        
        return false
    }
    
    
    func showRecentContactArray() {
        let dataArray = UserDefaults.standard.array(forKey: DICT_USER_RECENT)
        if dataArray != nil {
            for dict1 in dataArray! {
                let object = dict1 as AnyObject?
                let userInfo = UserInfoModel.init(json: JSON.init(object as Any))
                self.recentContactArray.append(userInfo)
            }
        }
    }
    
    
    func saveRecentContactArray(userInfo: UserInfoModel) {
        var recentArrayTemp = self.recentContactArray
        if self.recentContactArray.count < 5 && !self.checkUserIsExistArray(array: self.recentContactArray, user: userInfo) {
            // 不存在
            recentArrayTemp.append(userInfo)
        } else {
            if !self.checkUserIsExistArray(array: self.recentContactArray, user: userInfo) {
                recentArrayTemp.removeLast()
            } else {
                // 删除旧值
                let arrayTemp = recentArrayTemp
                for (index, item) in arrayTemp.enumerated() {
                    if userInfo.id == item.id {
                        recentArrayTemp.remove(at: index)
                    }
                }
            }
            // 添加新值到首位
            recentArrayTemp.insert(userInfo, at: 0)
        }
        
        var userDictArray:[[String: Any]] = []
        for user in recentArrayTemp {
            // 模型转字典
            let userDict = user.mapJSON().dictionaryObject
            if userDict != nil {
                userDictArray.append(userDict!)
            }
        }
        
        // 更新最新联系人信息
        if userDictArray.count > 0 {
            UserDefaults.standard.set(userDictArray, forKey: DICT_USER_RECENT)
            UserDefaults.standard.synchronize()
        }
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
    func getUserList(pageCount: Int, searchText: String?) {
        var searchTextTemp = searchText
        if !(self.displayController?.isActive)! {
            if searchTextTemp == nil {
                searchTextTemp = ""
            }
        } else {
            if searchTextTemp == nil || searchTextTemp == "" {
                return
            }
        }
        
        self.view.endEditing(true)
        // 根据昵称搜索关注用户的相关列表
        MBProgressHUD.showMessage("", to: self.view)
        UserBusiness.shareIntance.responseWebGetUserNameSearchUsersList(pageIndex: pageCount, nickName: searchTextTemp!, responseSuccess: { (resonseSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            let pageResult = resonseSuccess as! PageResultModel<UserInfoModel>
            if pageCount == 1 {
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
                if !(self.displayController?.isActive)! {
                    self.contactArray.removeAll()
                    self.contactArray = pageResult.beanList!
                } else {
                    self.resultArray.removeAll()
                    self.resultArray = pageResult.beanList!
                }
            } else {
                if !(self.displayController?.isActive)! {
                    self.contactArray = self.contactArray + pageResult.beanList!
                } else {
                    self.resultArray = self.resultArray + pageResult.beanList!
                }
            }
            
            // 判断是否到底
            if pageResult.beanList?.count == 0 {
                self.page -= 1
                if self.page < 1 { self.page = 1 }
            }
            if self.page == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
