//
//  CoinChangeLogModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/1.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class CoinChangeLogModel: BaseModel {
    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 碳币变更类型编码
     */
    var changeTypeCode: String?
    
    /**
     * 碳币变更数量
     */
    var changeCount: Int?
    
    /**
     * 碳币变更后余额
     */
    var changedAmount: Int?
    
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
        
        userId = json["userId"].stringValue
        changeTypeCode = json["changeTypeCode"].stringValue
        changeCount = json["changeCount"].intValue
        changedAmount = json["changedAmount"].intValue
        businessId = json["businessId"].stringValue
        description = json["description"].stringValue
    }
}
