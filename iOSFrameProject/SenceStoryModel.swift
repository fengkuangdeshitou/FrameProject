//
//  SenceStoryModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class SenceStoryModel: BaseModel {
    /**
     * 名称
     */
    var name: String?
    
    /**
     * 描述
     */
    var description: String?
    
    /**
     * 排序
     */
    var sort: Int?
    
    /**
     * 图片列表
     */
    var photoList: [PhotoModel]?
    
    required init(json: JSON) {
        super.init(json: json)
        
        name = json["name"].stringValue
        description = json["description"].stringValue
        sort = json["sort"].intValue
        photoList = json["photoList"].arrayValue.map({ (json) -> PhotoModel in
            PhotoModel(json: json)
        })
    }

}
