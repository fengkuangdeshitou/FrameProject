//
//  CouponListMViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class CouponListMViewController: UIViewController, STSegmentViewDelegate, UITableViewDelegate, UITableViewDataSource {

    public var type: ESRefreshExampleType = .defaulttype
    public var page = 1
    
    var couponGroup : CouponGroupModel?
    
    var menuButtonIndex: Int?
    
    fileprivate var couponArray: [CouponModel] = []
    fileprivate var dataSource: [CouponModel] = []
    
    @IBOutlet weak var menuTopView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var segmentView: STSegmentView?
    
    fileprivate var couponStatus = CouponStatusType.all    // 优惠券状态
    
    @IBOutlet weak var menuTopViewTopContraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.title = "优惠券"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // segmentView
        self.segmentView = STSegmentView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: CELL_NORMAL_HEIGHT - 1))
        
        // 获取 photo code title
        let titleArray: [String] = ["全部", "未领取", "已领取"]
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
        self.menuTopView.addSubview(self.segmentView!)
        if self.menuButtonIndex == 1 {
            self.menuTopViewTopContraint.constant = -CELL_NORMAL_HEIGHT
        }
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init()
        self.tableView.register(UINib.init(nibName: "CouponTableViewCell", bundle: nil), forCellReuseIdentifier: CouponTableViewCell.CELL_ID)
        self.tableView.register(CouponFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: CouponFooterView.FOOTER_ID)
        self.tableView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        
        // 设置刷新 -- 下拉刷新
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        // 获取网络数据
        self.setUpdateDataSource()
    }
    
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.setUpdateDataSource()
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.setUpdateDataSource()
        
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
    
    // MARK: row count in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CouponTableViewCell.CELL_ID) as! CouponTableViewCell
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = BG_COLOR_TABLE_OR_COLLECTION
        // 解析数据
        let coupon = self.dataSource[indexPath.section]
        
        // 优惠券类型
        if self.couponGroup?.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            cell.couponBgTypeView.backgroundColor = SmallCouponView.DISCOUNT_BG_COLOR
        } else {
            cell.couponBgTypeView.backgroundColor = SmallCouponView.MONEY_BG_COLOR
        }
        
        
        // 优惠金额或优惠折扣
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 23.0, minFont: 10.0, color: UIColor.white, action: {})
        var strText: NSString?
        if self.couponGroup?.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            let discount = NSString.removeFloatAllZero((String(format: "%.1f", (self.couponGroup?.discount)! * 10) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>折" as NSString
        } else {
            let discount = NSString.removeFloatAllZero((String(format: "%.2f", (self.couponGroup?.discount)!) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>元" as NSString
        }
        cell.showDiscountOrMoneyLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        
        // 有效期
        let startDate = Date.init(timeIntervalSince1970: TimeInterval((self.couponGroup?.startTime)! / 1000))
        let endDate = Date.init(timeIntervalSince1970: TimeInterval((self.couponGroup?.endTime)! / 1000))
        cell.valideTimeLabel.text = "有效期 \(NSDate.string(from: startDate, andFormatterString: "yyyy.MM.dd")!)-\(NSDate.string(from: endDate, andFormatterString: "yyyy.MM.dd")!)"
        
        // 使用条件
        cell.showUseFullMoneyLabel.text = "满\(NSString.removeFloatAllZero((String(format: "%.2f", (self.couponGroup?.limitAmount)!) as NSString) as String?)!)元可使用"
        
        // 价值碳币数
        cell.showCarbonLabel.text = "(\((self.couponGroup?.coinPrice)!)碳币可兑换)"
        
        // 右边按钮
        if coupon.userId == "" {
            cell.couponGroupUseLabel.text = "未领取"
            cell.couponGroupUseLabel.alpha = 1.0
        } else {
            cell.couponGroupUseLabel.text = "已领取"
            cell.couponGroupUseLabel.alpha = 1.0
        }
        
        // 已过期
        let endTimeValue = coupon.endTime! / 1000
        let currentTimeValue = Int(Date.init().timeIntervalSince1970)
        if endTimeValue < currentTimeValue  {
            cell.couponGroupUseLabel.text = "已失效"
            cell.couponGroupUseLabel.alpha = 0.5
        }
        
        
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    // MARK: footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        // 解析数据
        let coupon = self.dataSource[section]

        if coupon.userId != "" {
            return CouponFooterView.FOOTER_HEIGHT
        }
        
        return 0.1
    }
    
    // MARK: footer View
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // 解析数据
        let coupon = self.dataSource[section]
        if coupon.userId == "" {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CouponFooterView.FOOTER_ID)
        
        return footerView
    }
    
    // MARK: willDisplayFooterView
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        // 解析数据
        let coupon = self.dataSource[section]
        if coupon.userId == "" {
            return
        }
        
        let footerView = view as! CouponFooterView
        
        footerView.showImageView?.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (coupon.user?.avatar)!), placeholderImage: DEFAULT_USER_ICON)
        
        footerView.showTitleLabel?.text = coupon.user?.nickname
    }
    
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CouponTableViewCell.CELL_HEIGHT
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
        switch index {
        case 0:
            self.couponStatus = CouponStatusType.all
        case 1:
            self.couponStatus = CouponStatusType.unuse
        case 2:
            self.couponStatus = CouponStatusType.used
        default:
            self.couponStatus = CouponStatusType.outOfDate
        }
        
        self.setUpdateDataSource()
    }
    
    // MARK: 设置更新数据源
    func setUpdateDataSource() {
        if self.couponStatus == CouponStatusType.all {
            // 全部
            self.getCouponGroupCouponList(pageIndex: self.page, status: nil)
        } else if self.couponStatus == CouponStatusType.unuse {
            // 未使用
            self.getCouponGroupCouponList(pageIndex: self.page, status: 0)
        } else if self.couponStatus == CouponStatusType.used {
            // 已领取
            self.getCouponGroupCouponList(pageIndex: self.page, status: 1)
        } else if self.couponStatus == CouponStatusType.used {
            // 已过期
            self.getCouponGroupCouponList(pageIndex: self.page, status: nil)
        }
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
    
    // MARK: 获取组下的优惠券
    func getCouponGroupCouponList(pageIndex: Int, status: Int?) {
        MBProgressHUD.showMessage("", to: self.view)
        
        CouponBusiness.shareIntance.responseWebGetCouponGroupCouponList(couponGroupId: (self.couponGroup?.id)!, status: status, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageIndex, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<CouponModel>
            if pageIndex == 1 {
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
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
