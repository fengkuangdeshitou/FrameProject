//
//  SelectCouponViewController.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/21.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

protocol SelectCouponViewDelegate: NSObjectProtocol {
    
    /// 选中的优惠券回调方法
    ///
    /// - Parameter coupon: 优惠券对象
    func SelectCouponViewSuccess(coupon: CouponModel)
}

class SelectCouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var page = 1
    
    weak var customDelegate: SelectCouponViewDelegate?
    
    var payAllMoney: Double?
    var merchant: MerchantModel?
    var selectCoupon: CouponModel?
    
    fileprivate var dataSource: [CouponModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 初始化
        self.payAllMoney = self.payAllMoney == nil ? 0 : self.payAllMoney
        self.title = "选择优惠券"
        
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back.png"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        // set tableview
        self.tableView.tableFooterView = UIView.init()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.white
        
        // 设置刷新
        ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        // 获取网络数据
        self.getCouponList(pageCount: self.page)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCouponTableViewCell.CELL_ID) as! SelectCouponTableViewCell
        cell.selectionStyle = .none
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
        
        // 右边选择
        if self.payAllMoney! < coupon.limitAmount! {
            // 未满足优惠券支付条件
            cell.showSelectLabel.backgroundColor = UIColor.lightGray
        } else {
            let startDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.startTime! / 1000))
            let endDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.endTime! / 1000))
            let startDateStr = NSDate.string(from: startDate, andFormatterString: "yyyy-MM-dd")
            let endDateStr = NSDate.string(from: endDate, andFormatterString: "yyyy-MM-dd")
            let currentDateStr = NSDate.string(from: Date.init(), andFormatterString: "yyyy-MM-dd")
            
            if startDateStr?.compare(currentDateStr!).rawValue != 1 && endDateStr?.compare(currentDateStr!).rawValue != -1 {
                cell.showSelectLabel.backgroundColor = COLOR_HIGHT_LIGHT_SYSTEM
            } else {
                // 未满足优惠券支付条件
                cell.showSelectLabel.backgroundColor = UIColor.lightGray
            }
        }
        
//        if coupon.id == self.selectCoupon?.id {
//            // 选中
//            cell.showSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_selected.png")
//        } else {
//            cell.showSelectImageView.image = #imageLiteral(resourceName: "merchant_pay_unselect.png")
//        }
        
        return cell
    }
    
    // MARK: cell click
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 解析数据
        let coupon = self.dataSource[indexPath.row]
        
        if self.payAllMoney! < coupon.limitAmount! {
            // 未满足优惠券支付条件
            return
        } else {
            let startDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.startTime! / 1000))
            let endDate = Date.init(timeIntervalSince1970: TimeInterval(coupon.endTime! / 1000))
            let startDateStr = NSDate.string(from: startDate, andFormatterString: "yyyy-MM-dd")
            let endDateStr = NSDate.string(from: endDate, andFormatterString: "yyyy-MM-dd")
            let currentDateStr = NSDate.string(from: Date.init(), andFormatterString: "yyyy-MM-dd")
            
            if startDateStr?.compare(currentDateStr!).rawValue != 1 && endDateStr?.compare(currentDateStr!).rawValue != -1 {
                self.customDelegate?.SelectCouponViewSuccess(coupon: coupon)
                self.navigationController?.popViewController(animated: true)
            } else {
               return
            }
        }
    }
    
    // MARK: cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CouponTableViewCell.CELL_HEIGHT
    }

    
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
    
    // MARK: 获取优惠券列表
    func getCouponList(pageCount: Int)  {
        MBProgressHUD.showMessage("", to: self.view)
        if self.merchant == nil {
            return
        }
        
        CouponBusiness.shareIntance.responseWebGetMyCouponList(merchantId: self.merchant?.id, status: CouponStatusType.unuse.rawValue, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<CouponModel>
            if pageCount == 1 {
                self.dataSource.removeAll()
                self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
                self.dataSource = pageResult.beanList!
            } else {
                self.dataSource = self.dataSource + pageResult.beanList!
            }
            
            // 判断是否到底
            if pageResult.pageCode == pageResult.totalPage {
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
