//
//  FeedBackModel.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/11.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class FeedBackModel: BaseModel {
    
    /// userId
    var userId: String?
    
    /// contact
    var contact: String?
    
    /// content
    var content: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        contact = json["contact"].stringValue
        content = json["content"].stringValue
    }
}
