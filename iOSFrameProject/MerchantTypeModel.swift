//
//  MerchantTypeModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/6/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class MerchantTypeModel: BaseModel {
    /// code
    var code: String?
    
    /// name
    var name: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        code = json["code"].stringValue
        name = json["name"].stringValue
    }
}
