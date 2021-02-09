//
//  NotificationMessageModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/28.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class NotificationMessageModel: NSObject {

    
    /// 消息类型
    var messageType: String?
    
    /// 消息Title
    var title: String?
    
    /// 消息SubTitle
    var subTitle: String?
    
    /// 消息Body
    var body: String?
    
}
