//
//  MessageSettingModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/6/1.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class MessageSettingModel: BaseModel {
    /**
     * 名称
     */
    var messageTypeCode: String?
    
    /**
     * 描述
     */
    var userId: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        messageTypeCode = json["messageTypeCode"].stringValue
        userId = json["userId"].stringValue
    }
}
