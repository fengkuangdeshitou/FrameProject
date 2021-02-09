//
//  PaymentModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

// 支付方式类型
public enum PayType: String {
    case weiXinPay = "wx"   // 微信
    case alipay = "ali"     // 支付宝
}

// 订单状态
public enum PaymentStatusType: String {
    case waitPay = "1"   // 待支付
    case done = "2"      // 已完成
}

class PaymentModel: BaseModel {
    /**
     * 流水号
     */
    var serialNumber: String?
    
    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 商户id
     */
    var merchantId: String?
    
    /**
     * 总金额
     */
    var amount: Double?
    
    /**
     * 抵扣金额
     */
    var deductionAmount: Double?
    
    /**
     * 实际付款金额
     */
    var actualAmount: Double?
    
    /**
     * 优惠券id
     */
    var couponId: String?
    
    /**
     * 支付方式
     */
    var payType: String?
    
    /**
     * 第三方流水号
     */
    var thirdPartySerialNumber: String?
    
    /**
     * 到账时间
     */
    var finishTime: Int64?
    
    /**
     * 用户
     */
    var user: UserInfoModel?
    
    /**
     * 商户
     */
    var merchant: MerchantModel?
    
    /**
     * 优惠券
     */
    var coupon: CouponModel?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        serialNumber = json["serialNumber"].stringValue
        userId = json["userId"].stringValue
        merchantId = json["merchantId"].stringValue
        amount = json["amount"].doubleValue
        deductionAmount = json["deductionAmount"].doubleValue
        actualAmount = json["actualAmount"].doubleValue
        couponId = json["couponId"].stringValue
        payType = json["payType"].stringValue
        thirdPartySerialNumber = json["thirdPartySerialNumber"].stringValue
        finishTime = json["finishTime"].int64Value
        user = UserInfoModel.init(json: json["user"])
        merchant = MerchantModel.init(json: json["merchant"])
        coupon = CouponModel.init(json: json["coupon"])
    }
}
