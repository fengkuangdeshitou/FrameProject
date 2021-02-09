//
//  MessageModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

// 详细类型
public enum MessageTypeCode: String {
    case getMoney = "001"   // 到账提醒
    case withdraw = "002"   // 提现提醒
    case sendPhoto = "003"  // @送照片消息
    case comment = "004"    // 评论照片
    case support = "005"    // 照片点赞
    case attention = "006"  // 用户关注
    case other = "007"      // 其它
    case loginExpire = "008"    // 登录过期
}

class MessageModel: BaseModel {
    /**
     * 用户id
     */
    var targetUserId: String?
    
    /**
     * 发送用户id
     */
    var sendUserId: String?
    
    /**
     * 消息类型编码
     */
    var messageTypeCode: String? 
    
    /**
     * 标题
     */
    var title: String?
    
    /**
     * 内容
     */
    var content: String?
    
    /**
     * 链接
     */
    var link: String?
    
    /**
     * 已读
     */
    var readed: Bool?
    
    /**
     * 完成时间
     */
    var readTime: Int64?
    
    
    required init(json: JSON) {
        super.init(json: json)
        
        targetUserId = json["targetUserId"].stringValue
        sendUserId = json["sendUserId"].stringValue
        messageTypeCode = json["messageTypeCode"].stringValue
        title = json["title"].stringValue
        content = json["content"].stringValue
        link = json["link"].stringValue
        readed = json["readed"].boolValue
        readTime = json["readTime"].int64Value
    }
}
