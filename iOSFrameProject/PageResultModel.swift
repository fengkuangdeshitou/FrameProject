//
//  PageResultModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class PageResultModel<T: JSONMappable>: JSONMappable {
    
    
    /// 总条数
    var totalRecord: Int?
    
    /// 总页数
    var totalPage: Int?
    
    /// 当前页面
    var pageCode: Int?
    
    /// 每页条数
    var pageSize: Int?
    
    /// 数据列表
    var beanList: [T]?
    
    required init(json: JSON) {
        totalRecord = json["totalRecord"].intValue
        totalPage = json["totalPage"].intValue
        pageCode = json["pageCode"].intValue
        pageSize = json["pageSize"].intValue
        
        beanList = json["beanList"].arrayValue.map({ (json) -> T in
            T(json: json)
        })
    }

}
