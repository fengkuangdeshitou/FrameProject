//
//  BaseModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/26.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class BaseModel: JSONMappable {

    
    /// id
    var id: String?
    
    /// updatedTime
    var updatedTime: Int64?
    
    /// createdTime
    var createdTime: Int64?
    
    /// status
    var status: Int?
    
    required init(json: JSON) {
        id = json["id"].stringValue
        updatedTime = json["updatedTime"].int64Value
        createdTime = json["createdTime"].int64Value
        status = json["status"].intValue
    }
    
    init() {
    }
}
