//
//  ObjectResultModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class WebResultModel<T: JSONMappable>: JSONMappable {

    /// 消息提示语
    var msg: String?
    
    /// 状态 code
    var status: String?
    
    
    /// 数据json块
    var data: T?
    
    required init(json: JSON) {
        msg = json["msg"].stringValue
        status = json["status"].stringValue
        
        data = T(json: json["data"])
    }
}
