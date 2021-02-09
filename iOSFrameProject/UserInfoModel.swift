//
//  UserInfoModel.swift
//  ECOCityProject
//
//  Created by jointsky on 2017/9/21.
//  Copyright © 2017年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSONMappable
import SwiftyJSON

// 用户类型
public enum RoleCodeType: String {
    case roleAdmin = "role_admin"   // 管理员
    case roleTemp = "role_temp"     // 临时用户
    case roleUser = "role_user"     // 正式用户
    case roleMerchant = "role_merchant"     // 商家用户
}

class UserInfoModel:BaseModel {
    
    /// deviceId
    var deviceId: String?
    
    /// username
    var username: String?
    
    /// nickname
    var nickname: String?
    
    /// phoneNumber
    var phoneNumber: String?
    
    /// mail
    var mail: String?
    
    /// avatar
    var avatar: String?
    
    /// speak
    var speak: String?
    
    /// attentionAmount
    var attentionAmount: Int?
    
    /// followAmount
    var followAmount: Int?
    
    /// publishPhotoAmount
    var publishPhotoAmount: Int?
    
    /// coinAmount(碳币)
    var coinAmount: Int?
    
    /**
     * 角色编码
     */
    var roleCode: String?
    
    /// isAttention
    var isAttention: Bool?
    
    /// finishLoginTask 是否是刚完成登录任务
    var finishLoginTask: Bool?
    
    
    /// 商户信息
    var merchant: MerchantModel?
    
    required init(json: JSON) {
        super.init(json: json)
        
        deviceId = json["deviceId"].stringValue
        username = json["username"].stringValue
        nickname = json["nickname"].stringValue
        phoneNumber = json["phoneNumber"].stringValue
        mail = json["mail"].stringValue
        avatar = json["avatar"].stringValue
        speak = json["speak"].stringValue
        attentionAmount = json["attentionAmount"].intValue
        followAmount = json["followAmount"].intValue
        publishPhotoAmount = json["publishPhotoAmount"].intValue
        coinAmount = json["coinAmount"].intValue
        roleCode = json["roleCode"].stringValue
        isAttention = json["isAttention"].boolValue
        finishLoginTask = json["finishLoginTask"].boolValue
        merchant = MerchantModel.init(json: json["merchant"])
    }
    
    // 模型转字典
    func modelToDict() -> NSDictionary {
        let dict = NSMutableDictionary.init()
        
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.username!, forKey: "username")
        dict.setValue(self.nickname!, forKey: "nickname")
        dict.setValue(self.phoneNumber!, forKey: "phoneNumber")
        dict.setValue(self.mail!, forKey: "mail")
        dict.setValue(self.avatar!, forKey: "avatar")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        dict.setValue(self.deviceId!, forKey: "deviceId")
        
        return dict
    }
}
