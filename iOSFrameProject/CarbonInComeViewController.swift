//
//  CarbonInComeViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/24.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CarbonInComeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var showCarbonRuleLabel: UILabel!
    
    @IBOutlet weak var showCarbonImageView: UIImageView!
    
    @IBOutlet weak var remaindCarbonCountLabel: UILabel!
    
    @IBOutlet weak var howGetCarbonBtn: UIButton!
    
    @IBOutlet weak var carbonRechargeBtn: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var dataSource: [CoinChangeLogModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        self.title = "碳币明细"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // setViewUI
        self.setViewUI()
        
        // setTableViewHeaderView
        self.setTableViewHeaderView()
        
        // set TableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorColor = COLOR_SEPARATOR_LINE
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
        
        // 获取网络数据
        self.getIncomAndPayOutLogList(pageCount: self.page)
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
        // 获取网络数据
        self.getIncomAndPayOutLogList(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getIncomAndPayOutLogList(pageCount: self.page)
        
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
        
        // 设置残币图标
        self.showCarbonImageView.image = #imageLiteral(resourceName: "mine_carbon_big")
        
        // 设置碳币余额
        let textStyleDict2 = PRICE_ANDFONT_ANDCOLOR(maxFont: NAVIGATION_TITLE_FONT_SIZE, minFont: FONT_SMART_SIZE, color: COLOR_CARBON_COIN, action: {})
        let strText2 = "余额：<help><link><FontMax>\(String(describing: (APP_DELEGATE.currentUserInfo?.coinAmount)!))</FontMax></link></help> 枚碳币" as NSString?
        self.remaindCarbonCountLabel.attributedText = strText2?.attributedString(withStyleBook: textStyleDict2 as! [AnyHashable : Any])
        
    }
    
    
    // MARK: - UITableViewDelegate
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CarbonIncomeCell.carbonIncomeCellId) as! CarbonIncomeCell
        cell.selectionStyle = .none
        
        // 解析数据
        let coinLog = self.dataSource[indexPath.row]
        
        
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
        cell.showRightLabel.text = "+\(coinLog.changeCount!)"
        
        return cell
    }
    
    // MARK: cell Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(CarbonIncomeCell.carbonIncomeCellHeight)
    }
    
    // MARK: section Title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "碳币收入明细"
    }
    
    // MARK: header view Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    // MARK: footer view height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    // MARK: 碳币充值点击响应
    @IBAction func carbonRechargeBtnClick(_ sender: UIButton) {

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
    
    
    // MARK: 获取收支记录列表
    func getIncomAndPayOutLogList(pageCount: Int) {
        self.tableView.es.resetNoMoreData()
        MBProgressHUD.showMessage("", to: self.view)
        OtherBusiness.shareIntance.responseWebGetCoinChangeLogList(incomeType: CoinChangeLogIncomeType.all, startTime: "1970-01-01 00:00:00", endTime: NSDate.string(from: Date.init(), andFormatterString: DATE_STANDARD_FORMATTER), pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<CoinChangeLogModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                self.dataSource = pageResult.beanList!
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


extension CarbonInComeViewController {
    func setViewUI() {
        // 设置点击事件
        self.showCarbonRuleLabel.isUserInteractionEnabled = true
        self.showCarbonRuleLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            // 协议点击
            let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
            webViewController.isAdaptNavigationHeight = true
            webViewController.pageUrlStr = WEBBASEURL + "/static/about/coin.html"
            self.navigationController?.pushViewController(webViewController, animated: true)
        }))
        
        // 设置 如何获取碳币按钮
        self.howGetCarbonBtn.layer.masksToBounds = true
        self.howGetCarbonBtn.layer.cornerRadius = CORNER_SMART
        self.howGetCarbonBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.howGetCarbonBtn.layer.borderWidth = BORDER_WIDTH
        self.howGetCarbonBtn.addTarget(self, action: #selector(howGetCarbonBtn(sender:)), for: .touchUpInside)
    }
    
    
    @objc func howGetCarbonBtn(sender: UIButton) {
        // 如何获取碳币
        let webViewController = self.storyboard?.instantiateViewController(withIdentifier: "WKWebPageView") as! WKWebPageViewController
        webViewController.isAdaptNavigationHeight = true
        webViewController.pageUrlStr = WEBBASEURL + "/static/about/task.html"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}
