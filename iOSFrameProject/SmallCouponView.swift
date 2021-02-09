//
//  SmallCouponView.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit

class SmallCouponView: UIView {
    
    // 打折券背景颜色
    static let DISCOUNT_BG_COLOR = UIColorFromRGB(rgbValue: 0xf7941d)
    
    // 价格券背景颜色
    static let MONEY_BG_COLOR = UIColorFromRGB(rgbValue: 0x7accc8)

    @IBOutlet weak var showDiscountLabel: UILabel!
    
    @IBOutlet weak var showValidityLabel: UILabel!
    
    @IBOutlet weak var useConditionLabel: UILabel!
    
    @IBOutlet weak var costCarbonLabel: UILabel!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // 设置数据
    func loadInitData(couponGroup: CouponGroupModel) {
        // 优惠券类型
        if couponGroup.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            self.backgroundColor = SmallCouponView.DISCOUNT_BG_COLOR
        } else {
            self.backgroundColor = SmallCouponView.MONEY_BG_COLOR
        }
        
        
        // 优惠金额或优惠折扣
        let textStyleDict = PRICE_ANDFONT_ANDCOLOR(maxFont: 18.0, minFont: 10.0, color: UIColor.white, action: {})
        var strText: NSString?
        if couponGroup.couponTypeCode == CouponTypeCode.discountCoupon.rawValue {
            let discount = NSString.removeFloatAllZero((String(format: "%.1f", couponGroup.discount! * 10) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>折" as NSString
        } else {
            let discount = NSString.removeFloatAllZero((String(format: "%.2f", couponGroup.discount!) as NSString) as String?)!
            strText = "<help><link><FontMax>\(discount)</FontMax></link></help>元" as NSString
        }
        self.showDiscountLabel.attributedText = strText?.attributedString(withStyleBook: textStyleDict as! [AnyHashable : Any])
        self.showDiscountLabel.adjustsFontSizeToFitWidth = true
        
        // 有效期
        let startDate = Date.init(timeIntervalSince1970: TimeInterval((couponGroup.startTime)! / 1000))
        let endDate = Date.init(timeIntervalSince1970: TimeInterval((couponGroup.endTime)! / 1000))
        self.showValidityLabel.text = "有效期 \(NSDate.string(from: startDate, andFormatterString: "yyyy.MM.dd")!)-\(NSDate.string(from: endDate, andFormatterString: "yyyy.MM.dd")!)"
        
        // 使用条件
        self.useConditionLabel.text = "满\(NSString.removeFloatAllZero((String(format: "%.2f", couponGroup.limitAmount!) as NSString) as String?)!)元可使用"
        
        // 价值碳币数
        self.costCarbonLabel.text = "\(couponGroup.coinPrice!)碳币\n可兑换"
        
    }

}
