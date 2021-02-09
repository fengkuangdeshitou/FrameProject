//
//  CityAirQualityModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/6/7.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class CityAirQualityModel: BaseModel {
    /// pm25
    var pm25: Int?
    
    /// aqi
    var aqi: Int?
    
    /// city
    var city: String?
    
    required init(json: JSON) {
        super.init(json: json)
        
        pm25 = json["pm25"].intValue
        aqi = json["aqi"].intValue
        city = json["city"].stringValue
    }
}
