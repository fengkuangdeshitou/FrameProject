//
//  VisualSencebeanListModel.swift
//  iOSFrameProject
//
//  Created by MI on 2018/4/27.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import Foundation
import SwiftyJSONMappable
import SwiftyJSON

class VisualSencebeanListModel: BaseModel {
    
    /// name
    var name: String?
    
    /// description
    var description: String?
    
    /// sort
    var sort: Int?
    
    /// photoList
    var photoList: PhotoLike?
    
    required init(json: JSON) {
        super.init(json: json)
        
        name = json["name"].stringValue
        description = json["description"].stringValue
        sort = json["sort"].intValue
        photoList = PhotoLike.init(json: json["photoList"])
    }
}
