//
//  CouponGroupModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/4.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class CouponGroupModel: BaseModel {
    /**
     * 商户id
     */
    var merchantId: String?
    
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
     * 总量
     */
    var total: Int?
    
    /**
     * 剩余量
     */
    var remain: Int?
    
    /**
     * 剩余量
     */
    var couponList: [CouponModel]?
    
    required init(json: JSON) {
        super.init(json: json)
        
        merchantId = json["merchantId"].stringValue
        name = json["name"].stringValue
        description = json["description"].stringValue
        couponTypeCode = json["couponTypeCode"].stringValue
        startTime = json["startTime"].int64Value
        endTime = json["endTime"].int64Value
        limitAmount = json["limitAmount"].doubleValue
        coinPrice = json["coinPrice"].intValue
        discount = json["discount"].doubleValue
        total = json["total"].intValue
        remain = json["remain"].intValue
        couponList = json["couponList"].arrayValue.map({ (json) -> CouponModel in
            CouponModel(json: json)
        })
    }
}
