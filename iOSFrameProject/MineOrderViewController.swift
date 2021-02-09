//
//  MineOrderViewController.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class MineOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var page = 1
    
    var userInfo: UserInfoModel?
    
    fileprivate var dataSource: [PaymentModel] = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "我的订单"
        // 设置导航栏
        let leftBarBtnItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "nav_back"), style: .plain, target: self, action: #selector(leftBarBtnItemClick(sender:)))
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // 设置刷新
    ESPullAddScrollViewForReflesh.shareIntance.addScrollViewRefleshOrMoreData(scrollView: self.tableView, refleshType: ESRefreshExampleType.defaulttype, reflesh: self.refresh, moreData: self.loadMore)
        
        // 获取网络数据
        self.getMineOrderList(pageCount: self.page)
        
    }
    
    
    // MARK: 刷新
    private func refresh() {
        self.page = 1
        // 获取网络数据
        self.getMineOrderList(pageCount: self.page)
        
        // 停止刷新
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopPullToRefresh(ignoreDate: true, ignoreFooter: true)
        }
    }
    
    // MARK: 加载更多
    private func loadMore() {
        self.page += 1
        // 获取网络数据
        self.getMineOrderList(pageCount: self.page)
        
        // 停止加载更多
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.es.stopLoadingMore()
        }
    }
    
    
    // MARK: leftBarBtnItem Click
    @objc func leftBarBtnItemClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ e: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 210
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let initIdentifier = "Cell"
        let cell: MineOrderTableCell = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as! MineOrderTableCell
        
//        cell.shopPicImage
//        cell.orderStatusLabel
//        cell.moneyThatLabel
//        cell.favorableConditionsLabel
        
        // 解析数据
        let payment = self.dataSource[indexPath.row]
        
        
        // showImage
        cell.shopPicImage.sd_setImage(with: URL.init(string: WEBBASEURL_IAMGE + (payment.merchant?.logo)!), placeholderImage: DEFAULT_IMAGE())
        
        // show Price
        let attributedStrM : NSMutableAttributedString = NSMutableAttributedString()
        let symbol: NSAttributedString = NSAttributedString(string: "￥", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 10.0)])
        let payMoneyStr = NSString.removeFloatAllZero((String(format: "%.2f", payment.actualAmount!) as NSString) as String?)!
        let price: NSAttributedString = NSAttributedString(string: payMoneyStr, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.7), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 30.0)])
        let unit: NSAttributedString = NSAttributedString(string: "元", attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 1), NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 12.0)])
        attributedStrM.append(symbol)
        attributedStrM.append(price)
        attributedStrM.append(unit)
        
        // merchant Name
        cell.moneyNumberLabel.attributedText = attributedStrM
        cell.shopNameButton.setRightAndleftTextWith(UIImage.init(named: "nav_back_reverse.png"), withTitle: (payment.merchant?.name)!, for: UIControl.State.normal, andImageFontValue: 5, andTitleFontValue: 16, andTextAlignment: UIControl.ContentHorizontalAlignment.left)
        
        cell.shopNameButton.tag = indexPath.row
        cell.shopNameButton.addTarget(self, action: #selector(onShopNameClick), for: UIControl.Event.touchUpInside)
        
        // coupon
        if payment.coupon != nil {
            let discount = NSString.removeFloatAllZero((String(format: "%.2f", (payment.deductionAmount)!) as NSString) as String?)!
            cell.favorableConditionsLabel.text = "已优惠\(discount)元"
            
//            if payment.coupon?.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
//                let discount = NSString.removeFloatAllZero((String(format: "%.2f", (payment.coupon?.discount)! * (payment.deductionAmount)!) as NSString) as String?)!
//                cell.favorableConditionsLabel.text = "已优惠\(discount)折"
//            } else {
//                let discount = NSString.removeFloatAllZero((String(format: "%.2f", (payment.coupon?.discount)!) as NSString) as String?)!
//                cell.favorableConditionsLabel.text = "已优惠\(discount)元"
//            }
        } else {
            cell.favorableConditionsLabel.text = "已优惠0元"
        }
        
        
        cell.onceAgainBuyButton.tag = indexPath.row
        cell.onceAgainBuyButton.addTarget(self, action: #selector(onOnceAgainBuyClick), for: UIControl.Event.touchUpInside)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none // 点击不变色
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailsView") as! OrderDetailsViewController
        viewController.payment = self.dataSource[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 点击店名
    @objc func onShopNameClick(sender: UIButton) {
        // 解析数据
        let payment = self.dataSource[sender.tag]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MerchantDetialView") as! MerchantDetialViewController
        viewController.merchant = payment.merchant
        viewController.userLocation = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: LOCATION_LATITUDE), longitude: UserDefaults.standard.double(forKey: LOCATION_LONGTITUDE))
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 点击再次购买
    @objc func onOnceAgainBuyClick(sender: UIButton) {
        // 解析数据
        let payment = self.dataSource[sender.tag]
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PayView") as! PayViewController
        viewController.merchant = payment.merchant
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: 获取订单列表
    func getMineOrderList(pageCount: Int) {
        MBProgressHUD.showMessage("", to: self.view)
        PaymentBusiness.shareIntance.responseWebGetPaymentMyOrderList(startTime: nil, endTime: nil, pageSize: Int(DEFAULT_IMAGE_CELL_PAGESIZE)!, pageCode: pageCount, responseSuccess: { (objectSuccess) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let pageResult = objectSuccess as! PageResultModel<PaymentModel>
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
            self.tableView.reloadData()
        }) { (error) in
        }
    }
}
