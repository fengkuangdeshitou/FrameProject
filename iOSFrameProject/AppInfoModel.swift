//
//  AppInfoModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/1/31.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class AppInfoModel: BaseModel {
    ///
    var userId: String?
    
    /// app name
    var name: String?
    
    /// 最新的build号（例如：26）
    var latestVersion: String?
    
    /// 最新版本号（例如：3.0.3）
    var latestBuildVersion: String?
    
    /// 强制版本的build号
    var latestForceVersion: String?
    
    /// 更新描述
    var latestUpdateDescription: String?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        name = json["name"].stringValue
        latestVersion = json["latestVersion"].stringValue
        latestBuildVersion = json["latestBuildVersion"].stringValue
        latestForceVersion = json["latestForceVersion"].stringValue
        latestUpdateDescription = json["latestUpdateDescription"].stringValue
    }
}
