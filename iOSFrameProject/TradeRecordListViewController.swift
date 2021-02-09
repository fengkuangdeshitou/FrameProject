//
//  TradeRecordListViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class TradeRecordListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var merchant: MerchantModel?
    
    fileprivate var dataSource: [MerchantTradeRecordModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "交易流水"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set tableView
        self.tableView.tableFooterView = UIView.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "TradeRecordListTableViewCell", bundle: nil), forCellReuseIdentifier: TradeRecordListTableViewCell.CELL_ID)
        
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
        self.getTradeRecordList(pageCount: self.page)
    }
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getTradeRecordList(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getTradeRecordList(pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - UITableViewDelegate 代理方法的实现
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TradeRecordListTableViewCell.CELL_ID) as! TradeRecordListTableViewCell
        
        // 解析数据
        let tradeRecord = self.dataSource[indexPath.row]
        
        cell.showTitleLabel.text = tradeRecord.description
        
        // time
        let takeDate = Date.init(timeIntervalSince1970: TimeInterval((tradeRecord.createdTime)! / 1000))
        cell.showSubTitleLabel.text = NSDate.stringNormalRead(with: takeDate)
        if tradeRecord.changeAmount! > 0.0 {
            cell.showRightLabel.textColor = COLOR_HIGHT_LIGHT_SYSTEM
        } else {
            cell.showRightLabel.textColor = COLOR_DARK_GAY
        }
        cell.showRightLabel.text = String(format: "%.2f", tradeRecord.changeAmount!)
        
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let tradeRecord = self.dataSource[indexPath.row]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TradeRecordDetailView") as! TradeRecordDetailViewController
        viewController.tradeRecord = tradeRecord
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TradeRecordListTableViewCell.CELL_HEIGHT
    }
    
    // MARK: did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    // MARK: Will Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 判断是否普通用户
        if APP_DELEGATE.currentUserInfo != nil && APP_DELEGATE.currentUserInfo?.roleCode != RoleCodeType.roleMerchant.rawValue {
            self.navigationController?.popToRootViewController(animated: false)
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
    
    // MARK: 获取交易记录列表
    func getTradeRecordList(pageCount: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        MerchantBusiness.shareIntance.responseWebGetMerchantTradeRecordList(income: nil, startTime: nil, endTime: nil, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<MerchantTradeRecordModel>
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

}
