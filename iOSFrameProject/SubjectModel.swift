//
//  SubjectModel.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/18.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON


/// 主题类型
///
/// - normal: 普通主题
/// - yearReport: 年报主题
/// - merchantRegister: 商家入驻
public enum SubjectTypeCode: String {
    case normal = "001"
    case yearReport = "002"
    case merchantRegister = "003"
}

class SubjectModel: BaseModel {
    
    /// coverImg
    var coverImg: String?
    
    /// url
    var url: String?
    
    /// subjectTypeCode
    var subjectTypeCode: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        coverImg = json["coverImg"].stringValue
        url = json["url"].stringValue
        subjectTypeCode = json["subjectTypeCode"].stringValue
    }
}
