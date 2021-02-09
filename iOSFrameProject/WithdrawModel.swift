//
//  WithdrawModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class WithdrawModel: BaseModel {
    /**
     * 流水号
     */
    var serialNumber: String?
    
    /**
     * 商户id
     */
    var merchantId: String?
    
    /**
     * 支付方式
     */
    var payType: String?
    
    /**
     * 账户名称
     */
    var accountName: String?
    
    /**
     * 提现金额
     */
    var amount: Double?
    
    /**
     * 到账时间
     */
    var finishTime: Int64?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        serialNumber = json["serialNumber"].stringValue
        merchantId = json["merchantId"].stringValue
        payType = json["payType"].stringValue
        accountName = json["accountName"].stringValue
        amount = json["amount"].doubleValue
        finishTime = json["finishTime"].int64Value
    }
}

