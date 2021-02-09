//
//  VisualSenceModel.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import Foundation
import SwiftyJSONMappable
import SwiftyJSON

class VisualSenceModel: BaseModel {
    
    /// msg
    var msg: String?
    
    /// data
    var data: VisualSenceDataModel?
    
    required init(json: JSON) {
        super.init(json: json)
        
        msg = json["msg"].stringValue
        data = VisualSenceDataModel.init(json: json["data"])
    }
}
