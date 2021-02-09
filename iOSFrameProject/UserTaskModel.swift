//
//  UserTaskModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/1.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON


class UserTaskModel: BaseModel {
    
    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 任务编码
     */
    var taskCode: String?
    
    /**
     * 完成时间
     */
    var finishTime: Double?
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        taskCode = json["taskCode"].stringValue
        finishTime = json["finishTime"].doubleValue
    }
}
