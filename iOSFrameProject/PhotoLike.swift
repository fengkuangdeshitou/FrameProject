//
//  PhotoLike.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/10.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON


class PhotoLike: BaseModel {
    
    /// userId
    var userId: String?
    
    /// photoId
    var photoId: String?
    
    /// content
    var content: String?
    
    /// replyUserId
    var replyUserId: String?
    
    /// user
    var user: UserInfoModel?
    
    /// replyUser
    var replyUser: UserInfoModel?
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        photoId = json["photoId"].stringValue
        content = json["content"].stringValue
        replyUserId = json["replyUserId"].stringValue
        user = UserInfoModel.init(json: json["user"])
        replyUser = UserInfoModel.init(json: json["replyUser"])
    }
}
