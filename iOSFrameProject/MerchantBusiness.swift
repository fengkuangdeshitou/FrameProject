//
//  MerchantBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/25.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class MerchantBusiness: NSObject {
    // 单例
    static let shareIntance: MerchantBusiness = {
        let merchantBusiness = MerchantBusiness()
        
        return merchantBusiness
    }()
}


extension MerchantBusiness {
    /****************** 商家相关 接口    **************************/
    
    
    /// 获取搜索商家列表接口
    ///
    /// - Parameters:
    ///   - regionCode: 城市编码，（nil 表示不限制）
    ///   - name: 商家名称， （nil 表示不限制）
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantSearchList(regionCode: String?, name: String?, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameter = NSMutableDictionary.init()
        if regionCode != nil {
            parameter.setValue(regionCode, forKey: "regionCode")
        }
        if name != nil {
            parameter.setValue(name, forKey: "name")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantList, parameters: parameter, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [MerchantModel] = []
            for dataDict in dataSourceArray {
                let senceInfo = MerchantModel.init(json: JSON.init(dataDict as Any))
                dataSourceModelArray.append(senceInfo)
            }
            
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /// 获取商家详情接口
    ///
    /// - Parameters:
    ///   - merchantId: 商家id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantDetail(merchantId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : merchantId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantDetail, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            if responseObject != nil {
                let merchant = MerchantModel.init(json: JSON.init(responseObject as Any))
                responseSuccess(merchant as AnyObject)
            } else {
                responseFailed(NSError.init())
                MBProgressHUD.show("未获取到商家详情", icon: nil, view: nil)
            }
            
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 二维码字符串获取商家详情
    ///
    /// - Parameters:
    ///   - qrCodeStr: 二维码字符串
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantDetailByQR(qrCodeStr: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["code" : qrCodeStr]
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantDetailByQR, parameters: parameters as NSDictionary, resquestType: .POST, outRequestTime: REQUEST_TIMEOUT_VALUE, AESCPwd: WebDataResponseInterface.shareInstance.isAutoDeAESC == true ? AESC_PASSWORD : nil, isTipInfo: true, responseProgress: {_ in}, responseSuccess: { (responseObject) in
            let result = WebResultModel<MerchantModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(result as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /// 获取商家的交易流水列表
    ///
    /// - Parameters:
    ///   - income: true:收入， false:支出， nil：不筛选
    ///   - startTime: 开始时间（时间戳s）， nil：不筛选
    ///   - endTime: 结束时间（时间戳s）， nil：不筛选
    ///   - pageSize: 页容量
    ///   - pageCode: 当前页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantTradeRecordList(income: Bool?, startTime: Int?, endTime: Int?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: [
            "pageSize" : String(pageSize),
            "pageCode" : String(pageCode)])
        if income != nil {
            parameters.setValue(income == true ? "true" : "false", forKey: "income")
        }
        
        if startTime != nil {
            parameters.setValue(String(startTime!), forKey: "startTime")
        }
        
        if endTime != nil {
            parameters.setValue(String(endTime!), forKey: "endTime")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantTradeRecordList, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<MerchantTradeRecordModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取商家交易流水详情
    ///
    /// - Parameters:
    ///   - tradeId: 交易流水id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantTradeRecordDetail(tradeId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : tradeId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantTradeRecordDetail, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = MerchantTradeRecordModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 今日收入
    ///
    /// - Parameters:
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantTradeRecordTodayIncome(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantTradeRecordTodayIncome, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let data = responseObject as! Double
            
            responseSuccess(data as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 提现
    ///
    /// - Parameters:
    ///   - amount: 金额
    ///   - payType: 支付方式
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetWithdraw(amount: Double, payType: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["amount" : String(amount),
                          "payType" : payType]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetWithdraw, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = WithdrawModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 查看提现详情
    ///
    /// - Parameters:
    ///   - withDrawId: 金额
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetWithdrawDetail(withDrawId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : withDrawId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetWithdrawDetail, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = WithdrawModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取商家的类型列表
    ///
    /// - Parameters:
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantTypeList(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantTypeList, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [MerchantTypeModel] = []
            for object in dataSourceArray {
                
                let objectModel = MerchantTypeModel.init(json: JSON.init(object as Any))
                dataSourceModelArray.append(objectModel)
            }
            
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 验证今日是否可以提现
    ///
    /// - Parameters:
    ///   - responseSuccess: 返回成功Block
    ///   - responseFailed: 返回失败block
    func responseWebTodayCanWithDraw(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_TodayCanWithDraw, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            responseSuccess(responseObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
}
