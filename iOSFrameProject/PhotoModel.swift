//
//  HomeCellModel.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/18.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

/// 图片标签
let PHOTO_CODE_ARRAY = [["title" : "空气优", "code" : "001", "color": "0x84c93e"],
                        ["title" : "空气良", "code" : "002", "color": "0xf5d051"],
                        ["title" : "有点糟", "code" : "003", "color": "0xea5b23"],
                        ["title" : "太差了", "code" : "004", "color": "0x5a0e2c"],
                        ["title" : "爆表了", "code" : "005", "color": "0x270000"]]

class PhotoModel: BaseModel {
    
    /// description
    var description: String?
    
    /// dehazePhoto
    var dehazePhoto: String?
    
    /// thumbPhoto
    var thumbPhoto: String?
    
    /// pm25
    var pm25: Int? = 0
    
    /// latitude
    var latitude: Double?
    
    /// regionCode
    var regionCode: String?
    
    /// takeTime
    var takeTime: Double?
    
    /// user
    var user: UserInfoModel?
    
    /// isReport
    var isReport: Bool?
    
    /// longitude
    var longitude: Double?
    
    /// photoTypeCode
    var photoTypeCode: String?
    
    /// likeCount
    var likeCount: Int?
    
    /**
     * 评论数量
     */
    var commentCount: Int?
    
    /// isLike
    var isLike: Bool?
    
    /// originalPhoto
    var originalPhoto: String?
    
    /// address
    var address: String?
    
    /// userId
    var userId: String?
    
    var giftUserList: [UserInfoModel]?
    
    /// image Width
    var imageWidth: Float?
    
    /// image Height
    var imageHeight: Float?
    
    required init(json: JSON) {
        super.init(json: json)
        
        description = json["description"].stringValue
        dehazePhoto = json["dehazePhoto"].stringValue
        thumbPhoto = json["thumbPhoto"].stringValue
        pm25 = json["pm25"].intValue
        latitude = json["latitude"].doubleValue
        regionCode = json["regionCode"].stringValue
        takeTime = json["takeTime"].doubleValue
        user = UserInfoModel.init(json: json["user"])
        isReport = json["isReport"].boolValue
        longitude = json["longitude"].doubleValue
        likeCount = json["likeCount"].intValue
        commentCount = json["commentCount"].intValue
        isLike = json["isLike"].boolValue
        originalPhoto = json["originalPhoto"].stringValue
        address = json["address"].stringValue
        userId = json["userId"].stringValue
        giftUserList = json["giftUserList"].arrayValue.map({ (json) -> UserInfoModel in
            UserInfoModel(json: json)
        })
    }
    
    override init() {
        super.init()
    }
}
