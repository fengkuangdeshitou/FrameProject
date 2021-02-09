//
//  TaskModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/1.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

/// 碳币奖励编码类型
///
/// - takePhoto: 发布照片
/// - supportPhoto: 点赞照片
/// - sharePhoto: 分享照片
/// - shareYearReport: 分享年报
/// - everydayLogin: 每日登录
/// - convertCoupon: 兑换优惠券
enum carbonCodeType: String {
    case takePhoto = "001"
    case supportPhoto = "002"
    case sharePhoto = "003"
    case shareYearReport = "004"
    case everydayLogin = "005"
    case convertCoupon = "006"
}


class TaskModel: BaseModel {
    /**
     * 任务编码
     */
    var code: String?
    
    /**
     * 任务名称
     */
    var name: String?
    
    /**
     * 限制次数
     */
    var limitCount: Int?
    
    /**
     * 每次奖励碳币个数
     */
    var coinCount: Int?
    
    /**
     * 完成次数
     */
    var finishCount: Int?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        code = json["code"].stringValue
        name = json["name"].stringValue
        limitCount = json["limitCount"].intValue
        coinCount = json["coinCount"].intValue
        finishCount = json["finishCount"].intValue
    }
}
