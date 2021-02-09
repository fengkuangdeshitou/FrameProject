//
//  MerchantTradeRecordModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class MerchantTradeRecordModel: BaseModel {
    /**
     * 商户id
     */
    var merchantId: String?
    
    /**
     * 余额变更金额
     */
    var changeAmount: Double?
    
    /**
     * 变更后余额
     */
    var changedAmount: Double?
    
    /**
     * 业务id
     */
    var businessId: String?
    
    /**
     * 描述
     */
    var description: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        merchantId = json["merchantId"].stringValue
        changeAmount = json["changeAmount"].doubleValue
        changedAmount = json["changedAmount"].doubleValue
        businessId = json["businessId"].stringValue
        description = json["description"].stringValue
    }

}
