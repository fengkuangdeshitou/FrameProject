//
//  VisualSenceDataModel.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import Foundation
import SwiftyJSONMappable
import SwiftyJSON

class VisualSenceDataModel: BaseModel {
    
    /// totalRecord
    var totalRecord: Int?
    
    /// totalPage
    var totalPage: Int?
    
    /// pageCode
    var pageCode: Int?
    
    /// pageSize
    var pageSize: Int?
    
    /// beanList
    var beanList: [VisualSencebeanListModel]?
    
    required init(json: JSON) {
        super.init(json: json)
        
        totalRecord = json["totalRecord"].intValue
        totalPage = json["totalPage"].intValue
        pageCode = json["pageCode"].intValue
        pageSize = json["pageSize"].intValue
        beanList = json["beanList"].arrayValue.map({ (json) -> VisualSencebeanListModel in
            VisualSencebeanListModel(json: json)
        })
    }
}
