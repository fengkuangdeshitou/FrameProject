//
//  CommonModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class CommonModel: NSObject {
    /// id
    var id: String?
    
    /// 标题
    var title: String?
    
    /// 详细标题
    var detailTitle: String?
    
    /// 图片地址
    var imagePathStr: String?
    
    /// 是否有下一个显示
    var isNext: String?
    
    /// value 1
    var textValue: String?
    
    /// value 2
    var textValue2: String?
}
