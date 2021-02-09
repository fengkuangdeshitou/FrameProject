//
//  MessageBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class MessageBusiness: NSObject {
    // 单例
    static let shareIntance: MessageBusiness = {
        let message = MessageBusiness()
        
        return message
    }()
}


extension MessageBusiness {
    /****************** 消息相关 接口    **************************/
    
    /// 获取消息分页
    ///
    /// - Parameters:
    ///   - messageTypeCode: 消息类型 nil=不筛选
    ///   - isReaded: 是否已读
    ///   - pageSize: 页容量
    ///   - pageCode: 当前页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMessagePage(messageTypeCode: MessageTypeCode?, isReaded: Bool?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: ["pageSize" : String(pageSize),
                                                               "pageCode" : String(pageCode)])
        if messageTypeCode != nil {
            parameters.setValue(messageTypeCode?.rawValue, forKey: "messageTypeCode")
        }
        if isReaded != nil {
            parameters.setValue(isReaded!, forKey: "isRead")
        }
        
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_MessagePage, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<MessageModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 标记已读
    ///
    /// - Parameters:
    ///   - messageId: 消息id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebMessageRead(messageId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : messageId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_MessageRead, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            responseSuccess(responseObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 全部标记已读
    ///
    /// - Parameters:
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebMessageReadAll(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_MessageReadAll, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            responseSuccess(responseObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /// 设置消息
    ///
    /// - Parameters:
    ///   - messageTypeCode: 消息的类型
    ///   - isOpen: 消息是否打开
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebPushMessageSetting(messageTypeCode: String, isOpen: Bool, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["messageTypeCode" : messageTypeCode,
                          "status" : isOpen == true ? "1" : "0"]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PushMessageSetting, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let objectModel = MessageSettingModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(objectModel as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取消息设置
    ///
    /// - Parameters:
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebPushMessageGetSetting(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PushMessageGetSetting, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [MessageSettingModel] = []
            for dataDict in dataSourceArray {
                let senceInfo = MessageSettingModel.init(json: JSON.init(dataDict as Any))
                dataSourceModelArray.append(senceInfo)
            }
            
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
