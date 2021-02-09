//
//  MineCouponListViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MineCouponListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, STSegmentViewDelegate {
    public var page = 1
    
    fileprivate var dataSource: [CouponModel] = []
    
    
    @IBOutlet weak var topMenuView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var segmentView: STSegmentView?
    
    fileprivate var selectCouponStatus = CouponStatusType.unuse
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "我的优惠券"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        
        // segmentView
        self.automaticallyAdjustsScrollViewInsets = true
        self.segmentView = STSegmentView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT - 0.5))
        // 获取 photo code title
        let titleArray: [String] = ["可使用", "已过期"]
        self.segmentView?.titleArray = titleArray;
        self.segmentView?.titleSpacing = 5;
        self.segmentView?.labelFont = UIFont.systemFont(ofSize: FONT_STANDARD_SIZE);
        self.segmentView?.bottomLabelTextColor = COLOR_GAY;
        self.segmentView?.topLabelTextColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.selectedBackgroundColor = UIColor.clear;
        //        self.segmentView?.selectedBgViewCornerRadius = 20;
        self.segmentView?.sliderHeight = 3;
        self.segmentView?.sliderColor = COLOR_HIGHT_LIGHT_SYSTEM;
        self.segmentView?.sliderTopMargin = 5;
        self.segmentView?.backgroundColor = UIColor.clear
        self.segmentView?.duration = 0.3;
        self.segmentView?.delegate = self
        self.view.addSubview(self.segmentView!)
        
        
        // set tableview
        self.tableView.tableFooterView = UIView.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        self.tableView.register(UINib.init(nibName: "CouponTableViewCell", bundle: nil), forCellReuseIdentifier: CouponTableViewCell.CELL_ID)
        self.tableView.register(CouphonCellHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: CouphonCellHeaderView.HEAD_ID)
        
        // 设置刷新
        ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        // 获取网络数据
        self.getCouponList(pageCount: self.page)
        
        
        // 接收支付状态消息响应通知
        NotificationCenter.default.addObserver(self, selector: #selector(acceptUserPayStatusUpdateNotification(notification:)), name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_PayStatus), object: nil)
    }
    
    
    // MARK: 支付状态的消息通知响应
    @objc func acceptUserPayStatusUpdateNotification(notification: Notification) {
        let isPaySuccess = notification.object as! Bool
        
        if isPaySuccess {
            self.refresh()
        }
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getCouponList(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getCouponList(pageCount: self.page)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CouponTableViewCell.CELL_ID) as! CouponTableViewCell
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        // 解析数据
        let coupon = self.dataSource[indexPath.row]
        
        // 价值碳币数
        cell.showCarbonLabel.isHidden = true
        
        
        // 优惠券类型
        if coupon.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            cell.couponBgTypeView.backgroundColor = SmallCouponView.DISCOUNT_BG_COLOR
        } else {
            cell.couponBgTypeView.backgroundColor = SmallCouponView.MONEY_BG_COLOR
        }
        
        
        // 优惠金额或优惠折扣
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 23.0, minFont: 10.0, color: UIColor.white, action: {})
        var strText: NSString?
        if coupon.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            let discount = NSString.removeFloatAllZero((String(format: "%.1f", coupon.discount! * 10) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>折" as NSString
        } else {
            let discount = NSString.removeFloatAllZero((String(format: "%.2f", coupon.discount!) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>元" as NSString
        }
        cell.showDiscountOrMoneyLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 有效期
        let startDate = Date.init(timeIntervalSince1970: TimeInterval((coupon.startTime)! / 1000))
        let endDate = Date.init(timeIntervalSince1970: TimeInterval((coupon.endTime)! / 1000))
        cell.valideTimeLabel.text = "有效期 \(NSDate.string(from: startDate, andFormatterString: "yyyy.MM.dd")!)-\(NSDate.string(from: endDate, andFormatterString: "yyyy.MM.dd")!)"
        
        // 使用条件
        cell.showUseFullMoneyLabel.text = "满\(NSString.removeFloatAllZero((String(format: "%.2f", coupon.limitAmount!) as NSString) as String?)!)元可使用"

        
        // 右边按钮
        if self.selectCouponStatus == CouponStatusType.unuse {
            let startDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.startTime! / 1000))
            let endDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.endTime! / 1000))
            let startDateStr = NSDate.string(from: startDate, andFormatterString: "yyyy-MM-dd")
            let endDateStr = NSDate.string(from: endDate, andFormatterString: "yyyy-MM-dd")
            let currentDateStr = NSDate.string(from: Date.init(), andFormatterString: "yyyy-MM-dd")
            
            if startDateStr?.compare(currentDateStr!).rawValue != 1 && endDateStr?.compare(currentDateStr!).rawValue != -1 {
                cell.couponGroupUseLabel.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
                cell.couponGroupUseLabel.text = "去使用"
                cell.couponGroupUseLabel.isUserInteractionEnabled = true
            } else {
                // 未满足优惠券支付条件
                cell.couponGroupUseLabel.backgroundColor = UIColor.lightGray
                cell.couponGroupUseLabel.text = "去使用"
                cell.couponGroupUseLabel.isUserInteractionEnabled = false
            }
            
        } else {
            cell.couponGroupUseLabel.text = "已过期"
            cell.couponGroupUseLabel.backgroundColor = UIColor.lightGray
            cell.couponGroupUseLabel.isUserInteractionEnabled = false
        }
        cell.couponGroupUseLabel.layer.masksToBounds = true
        cell.couponGroupUseLabel.layer.cornerRadius = cell.couponGroupUseLabel.height / 2
        cell.couponGroupUseLabel.textColor = UIColor.white
        cell.couponGroupUseLabel.addGestureRecognizer(UITapGestureRecognizer.init(actionBlock: { (gesture) in
            // 跳转支付界面
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as! PayViewController
            let merchant = MerchantModel.init()
            merchant.id = coupon.merchantId
            viewController.merchant = merchant
            viewController.selectedCoupon = coupon
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CouponTableViewCell.CELL_HEIGHT
    }
    
//    // MARK: header View
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CouphonCellHeaderView.HEAD_ID) as! CouphonCellHeaderView
//
//        return headerView
//    }
//
//    // MARK: willDisplayHeaderView
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let headerView = view as! CouphonCellHeaderView
//
//        headerView.showImageView?.sd_setImage(with: URL.init(string: "http://img02.tooopen.com/images/20160617/tooopen_sy_165424347593.jpg"), placeholderImage: DEFAULT_IMAGE())
//
//        headerView.showTitleButton?.setRightAndleftTextWith(UIImage.init(named: "nav_back_reverse"), withTitle: "小样理发店", for: .normal, andImageFontValue: Float(FONT_STANDARD_SIZE), andTitleFontValue: Float(FONT_STANDARD_SIZE), andTextAlignment: .left)
//    }
    
    // MARK: header height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
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
        
    }
    
    
    
    // MARK: - STSegmentViewDelegate
    // MARK: button click
    func buttonClick(_ index: Int) {
        self.page = 1
        
        if index == 0 {
            self.selectCouponStatus = CouponStatusType.unuse
        } else {
            self.selectCouponStatus = CouponStatusType.outOfDate
        }
        self.getCouponList(pageCount: self.page)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 析构方法
    deinit {
        // 移除通知
        NotificationCenter.default.removeObserver(self)
    }  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: 获取优惠券列表
    func getCouponList(pageCount: Int)  {
        MBProgressHUD.showMessage("", to: self.view)
        
        CouponBusiness.shareIntance.responseWebGetMyCouponList(merchantId: nil, status: self.selectCouponStatus.rawValue, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<CouponModel>
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
            }
            if self.page == pageResult.totalPage {
                self.tableView.es.noticeNoMoreData()
            }
            myPrint(message: objectSuccess)
            // 刷新
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
