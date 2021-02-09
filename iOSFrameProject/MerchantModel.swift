//
//  MerchantModel.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/23.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

class MerchantModel: BaseModel {

    /**
     * 用户id
     */
    var userId: String?
    
    /**
     * 名称
     */
    var name: String?
    
    /**
     * 真实名称
     */
    var trueName: String?
    
    /**
     * 描述
     */
    var description: String?
    
    /**
     * 介绍
     */
    var introduction: String?
    
    /**
     * 联系方式
     */
    var contact: String?
    
    /**
     * logo
     */
    var logo: String?
    
    /**
     * 城市编码
     */
    var regionCode: String?
    
    /**
     * 地点
     */
    var address: String?
    
    /**
     * 纬度
     */
    var latitude: Double?
    
    /**
     * 经度
     */
    var longitude: Double?
    
    /**
     * 支付宝二维码代码
     */
    var aliQrcode: String?
    
    /**
     * 微信二维码代码
     */
    var wxQrcode: String?
    
    /**
     * 支付宝收款账户
     */
    var aliAccount: String?
    
    /**
     * 微信收款账户
     */
    var wxAccount: String?
    
    /**
     * 余额
     */
    var amount: Double?
    
    required init(json: JSON) {
        super.init(json: json)
        
        userId = json["userId"].stringValue
        name = json["name"].stringValue
        trueName = json["trueName"].stringValue
        description = json["description"].stringValue
        introduction = json["introduction"].stringValue
        contact = json["contact"].stringValue
        logo = json["logo"].stringValue
        regionCode = json["regionCode"].stringValue
        address = json["address"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        aliQrcode = json["aliQrcode"].stringValue
        wxQrcode = json["wxQrcode"].stringValue
        aliAccount = json["aliAccount"].stringValue
        wxAccount = json["wxAccount"].stringValue
        amount = json["amount"].doubleValue
    }
    
    override init() {
        super.init()
    }
}
