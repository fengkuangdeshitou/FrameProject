//
//  CarbonTaskViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/24.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CarbonTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1

    @IBOutlet weak var userIconImageView: UIImageView!
    
    @IBOutlet weak var beatOtherUserLabel: UILabel!
    
    @IBOutlet weak var carbonImageView: UIImageView!
    
    @IBOutlet weak var showCarbonCoinLabel: UILabel!
    
    @IBOutlet weak var getCarbonBtn: UIButton!
    
    @IBOutlet weak var carbonTaskMenuBtn: UIButton!
    
    @IBOutlet weak var incomeMenuBtn: UIButton!
    
    @IBOutlet weak var menuBottomTypeView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSource: [TaskModel] = []
    var incomeDataSource: [CoinChangeLogModel] = []
    
    fileprivate var todayGetCoin: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "我的碳币"
        self.carbonTaskMenuBtn.isSelected = true
        self.menuBottomTypeView.width = SCREEN_WIDTH / 2
        self.view.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        self.getCarbonBtn.layer.masksToBounds = true
        self.getCarbonBtn.layer.cornerRadius = self.getCarbonBtn.height / 2
        self.getCarbonBtn.layer.borderColor = COLOR_HIGHT_LIGHT_SYSTEM.cgColor
        self.getCarbonBtn.layer.borderWidth = BORDER_WIDTH
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        self.setTableViewHeaderView()
        
        // set TableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "CarbonTaskCellTableViewCell", bundle: nil), forCellReuseIdentifier: CarbonTaskCellTableViewCell.carbonTaskCellId)
        self.tableView.register(UINib.init(nibName: "CarbonIncomeCell", bundle: nil), forCellReuseIdentifier: CarbonIncomeCell.carbonIncomeCellId)
        
        
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
        
        
        // 获取碳币任务规则列表
        self.getCoinTaskRuleList()
        
        let isShowCoinTask = UserDefaults.standard.bool(forKey: DICT_IS_SHOW_COIN_TASK)
        if !isShowCoinTask  {
            UserDefaults.standard.set(true, forKey: DICT_IS_SHOW_COIN_TASK)
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_CoinTaskUpdate), object: CoinTaskUpdateType.homeVC.rawValue)
        }
    }
    
    // MARK: left Bar Btn Item Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: right Bar Btn Item Click
    func rightBarBtnItemClick(sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        if self.carbonTaskMenuBtn.isSelected {
            // 碳币任务
            self.getCoinTaskRuleList()
        } else {
            // 获取网络数据
            self.getIncomAndPayOutLogList(pageCount: self.page)
        }
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        if self.carbonTaskMenuBtn.isSelected {
            // 碳币任务
            self.getCoinTaskRuleList()
        } else {
            // 获取网络数据
            self.getIncomAndPayOutLogList(pageCount: self.page)
        }
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    
    // MARK: setTableViewHeaderView
    func setTableViewHeaderView() {
        if APP_DELEGATE.currentUserInfo == nil {
            APP_DELEGATE.jumpToLoginViewContollerWithContoller(vc: self, tipMess: nil, isShowCancal: nil)
            
            return
        }
        // 设置用户头像
        self.userIconImageView.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE +  (APP_DELEGATE.currentUserInfo?.avatar)!), placeholderImage: #imageLiteral(resourceName: "defaultUserImage"))
        self.userIconImageView.isHidden = true
        
        // 设置打败用户
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: FONT_SMART_SIZE, minFont: 10.0, color: COLOR_HIGHT_LIGHT_SYSTEM, action: {})
        let strText = "打败了全国<help><link><FontMax>98%</FontMax></link></help>用户" as NSString?
        self.beatOtherUserLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        self.beatOtherUserLabel.isHidden = true
        
        
        // 设置碳币余额
        self.carbonImageView.image = #imageLiteral(resourceName: "mine_carbon_big")
        let textStyleDict2 = PRICE_ANDFONT_ANDCOLOR(maxFont: 23.0, minFont: FONT_SMART_SIZE, color: COLOR_CARBON_COIN, action: {})
        let strText2 = "<help><link><FontMax>\(String(describing: (APP_DELEGATE.currentUserInfo?.coinAmount)!))</FontMax></link></help> 枚" as NSString?
        self.showCarbonCoinLabel.attributedText = strText2?.attributedString(withStyleBook: textStyleDict2 as! [AnyHashable : Any])
    }
    
    
    // MARK: - UItableView Delegate
    // MARK: section count
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.carbonTaskMenuBtn.isSelected {
            // 碳币任务
            return self.dataSource.count
        }
       return self.incomeDataSource.count
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.carbonTaskMenuBtn.isSelected {
            // 碳币任务
            let cell = tableView.dequeueReusableCell(withIdentifier: CarbonTaskCellTableViewCell.carbonTaskCellId) as! CarbonTaskCellTableViewCell
            cell.selectionStyle = .none
            
            // 解析数据
            let taskInfo = self.dataSource[indexPath.row]
            
            // 设置进度
            cell.setProgress(complete: (taskInfo.finishCount)!, total: (taskInfo.limitCount)!)
            
            // 设置图标
            switch taskInfo.code {
            case carbonCodeType.takePhoto.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_publih")
            case carbonCodeType.supportPhoto.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_support")
            case carbonCodeType.sharePhoto.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_share")
            case carbonCodeType.shareYearReport.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_share_report")
            case carbonCodeType.everydayLogin.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_sign")
            case carbonCodeType.convertCoupon.rawValue?:
                cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_change2x.png")
            default:
                cell.showImageView.image = nil
            }
            
            
            // set title
            cell.showTitleLabel.text = taskInfo.name
            
            // set subtitle
            cell.showSubTitleLabel.text = "奖励：\(taskInfo.coinCount!)枚碳币"
            
            
            return cell
        }
        
        
        // 收入明细
        let cell = tableView.dequeueReusableCell(withIdentifier: CarbonIncomeCell.carbonIncomeCellId) as! CarbonIncomeCell
        cell.selectionStyle = .none
        
        // 解析数据
        let coinLog = self.incomeDataSource[indexPath.row]
        
        
        // 设置图标
        switch coinLog.changeTypeCode {
        case carbonCodeType.takePhoto.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_publih")
        case carbonCodeType.supportPhoto.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_support")
        case carbonCodeType.sharePhoto.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_share")
        case carbonCodeType.shareYearReport.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_share_report")
        case carbonCodeType.everydayLogin.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_sign")
        case carbonCodeType.convertCoupon.rawValue?:
            cell.showImageView.image = #imageLiteral(resourceName: "carbon_task_change.png")
        default:
            cell.showImageView.image = nil
        }
        
        // 设置名称
        cell.showTitleLabel.text = coinLog.description
        
        // 设置时间
        let takeDate = Date.init(timeIntervalSince1970: TimeInterval((coinLog.createdTime)! / 1000))
        
        cell.showDetailLabel.text = NSDate.stringNormalRead(with: takeDate)
        //        cell.showDetailLabel.text = tools.stringNormalRead(with: takeDate)
        
        // 设置奖励碳币数
        if coinLog.changeCount! < 0 {
            cell.showRightLabel.text = "\(coinLog.changeCount!)"
        } else {
            cell.showRightLabel.text = "+\(coinLog.changeCount!)"
        }
        
        
        return cell
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.carbonTaskMenuBtn.isSelected {
            // 碳币任务
            return CGFloat(CarbonTaskCellTableViewCell.carbonTaskCellHeight)
        }
        return CGFloat(CarbonIncomeCell.carbonIncomeCellHeight)
    }
    
    
    // MARK: 如何获取碳币点击
    @IBAction func getCarbonBtnClick(_ sender: UIButton) {
        // 如何获取碳币
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/task.html"
        webViewController.isShowWebPageTrack = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: 碳币使用规则协议点击
    @IBAction func useCarbonAgreementBtnClick(_ sender: UIButton) {
        // 协议点击
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/coin.html"
        webViewController.isShowWebPageTrack = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: 碳币任务点击
    @IBAction func carbonTaskBtnClick(_ sender: UIButton) {
        sender.isSelected = true
        self.incomeMenuBtn.isSelected = false
        UIView.animate(withDuration: 0.25) {
            self.menuBottomTypeView.x = 0
        }
        
        // 获取碳币任务列表
        self.getCoinTaskRuleList()
    }
    
    // MARK: 收支明细点击
    @IBAction func incomeDetailBtnClick(_ sender: UIButton) {
        sender.isSelected = true
        self.carbonTaskMenuBtn.isSelected = false
        UIView.animate(withDuration: 0.25) {
            self.menuBottomTypeView.x = SCREEN_WIDTH / 2
        }
        
        // 获取收支明细列表
        self.getIncomAndPayOutLogList(pageCount: self.page)
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
    
    // MARK: 获取碳币任务规则列表
    func getCoinTaskRuleList() {
        MBProgressHUD.showMessage("", to: self.view)
        OtherBusiness.shareIntance.responseWebGetTaskList(responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.dataSource = objectSuccess as! [TaskModel]
            
            // 统计今日获取的碳币数
            var allCoinCount = 0    // 总可以获取的碳币数
            var doneCoinCount = 0   // 已获取的碳币数
            for taskInfo in self.dataSource {
                taskInfo.coinCount =  taskInfo.coinCount == nil ? 0 : taskInfo.coinCount
                taskInfo.limitCount =  taskInfo.limitCount == nil ? 0 : taskInfo.limitCount
                taskInfo.finishCount =  taskInfo.finishCount == nil ? 0 : taskInfo.finishCount
                
                
                allCoinCount += taskInfo.coinCount! * taskInfo.limitCount!
                doneCoinCount += taskInfo.coinCount! * taskInfo.finishCount!
            }
            self.todayGetCoin = doneCoinCount
            self.setTableViewHeaderView()
            
            // 碳币任务已完成消息通知
            if allCoinCount == doneCoinCount {
                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATE_CoinTaskUpdate), object: CoinTaskUpdateType.mineVC.rawValue)
            }
            self.tableView.es.noticeNoMoreData()
            self.tableView.reloadData()
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    
    
    // MARK: 获取收支记录列表
    func getIncomAndPayOutLogList(pageCount: Int) {
        self.tableView.es.resetNoMoreData()
        MBProgressHUD.showMessage("", to: self.view)
        OtherBusiness.shareIntance.responseWebGetCoinChangeLogList(incomeType: CoinChangeLogIncomeType.all, startTime: "1970-01-01 00:00:00", endTime: NSDate.string(from: Date.init(), andFormatterString: DATE_STANDARD_FORMATTER), pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<CoinChangeLogModel>
            if pageCount == 1 {
                self.incomeDataSource.removeAll()
                self.incomeDataSource = pageResult.beanList!
            } else {
                self.incomeDataSource = self.incomeDataSource + pageResult.beanList!
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
