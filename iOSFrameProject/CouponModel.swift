//
//  CouponModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

// 优惠券类型
public enum CouponTypeCode: String {
    case moneyCoupon = "001"         // 直减券
    case discountCoupon = "002"     // 折扣券
}


// 优惠券状态
public enum CouponStatusType: String {
    case all = "0"           // 全部
    case unuse = "1"         // 未使用-可用
    case outOfDate = "2"     // 未使用-过期
    case used = "3"          // 已使用
}

class CouponModel: BaseModel {
    /**
     * 商户id
     */
    var merchantId: String?
    
    /**
     * 优惠券组id
     */
    var couponGroupId: String?
    
    /**
     * 编码
     */
    var code: String?
    
    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 用户对象
     */
    var user: UserInfoModel?
    
    /**
     * 兑换时间
     */
    var buyTime: Int64?
    
    /**
     * 使用时间
     */
    var usageTime: Int?
    
    /**
     * 名称
     */
    var name: String?
    
    /**
     * 描述
     */
    var description: String?
    
    /**
     * 优惠券类型编码
     */
    var couponTypeCode: String?
    
    /**
     * 开始时间
     */
    var startTime: Int64?
    
    /**
     * 结束时间
     */
    var endTime: Int64?
    
    /**
     * 最低订单金额
     */
    var limitAmount: Double?
    
    /**
     * 碳币价格
     */
    var coinPrice: Int?
    
    /**
     * 折扣比例/直减金额
     */
    var discount: Double?
    
    /**
     * 是否达到满减金额可用
     */
    var isReachedLimetAmountUse: Bool = false
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        merchantId = json["merchantId"].stringValue
        couponGroupId = json["couponGroupId"].stringValue
        code = json["code"].stringValue
        userId = json["userId"].stringValue
        user = UserInfoModel.init(json: json["user"])
        buyTime = json["buyTime"].int64Value
        usageTime = json["usageTime"].intValue
        description = json["description"].stringValue
        couponTypeCode = json["couponTypeCode"].stringValue
        startTime = json["startTime"].int64Value
        endTime = json["endTime"].int64Value
        limitAmount = json["limitAmount"].doubleValue
        coinPrice = json["coinPrice"].intValue
        discount = json["discount"].doubleValue
    }
}
