//
//  CityHourDataModel.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/10/12.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class CityHourDataModel: BaseModel {
    
    /// regionCode
    var regionCode: String?
    
    /// cityName
    var cityName: String?
    
    /// monitorTime
    var monitorTime: Double?
    
    /// pm25
    var pm25: Int?
    
    /// pm10
    var pm10: Int?
    
    required init(json: JSON) {
        super.init(json: json)
        
        regionCode = json["regionCode"].stringValue
        cityName = json["cityName"].stringValue
        monitorTime = json["monitorTime"].doubleValue
        pm25 = json["pm25"].intValue
        pm10 = json["pm10"].intValue
    }
}
