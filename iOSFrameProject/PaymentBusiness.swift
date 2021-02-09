//
//  PaymentBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class PaymentBusiness: NSObject {
    // 单例
    static let shareIntance: PaymentBusiness = {
        let payment = PaymentBusiness()
        
        return payment
    }()
}


extension PaymentBusiness {
    /****************** 支付相关 接口    **************************/
    
    /// 下单
    ///
    /// - Parameters:
    ///   - merchantId: 商户id
    ///   - amount: 总金额
    ///   - couponId: 优惠券id
    ///   - payType: 支付方式
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebPaymentPrepay(merchantId: String, amount: Double, couponId: String?, payType: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: [
            "merchantId" : merchantId,
            "amount" : String(amount),
            "payType" : payType,])

        if couponId != nil {
            parameters.setValue(couponId!, forKey: "couponId")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PaymentPrepay, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = PaymentModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 我的订单列表
    ///
    /// - Parameters:
    ///   - startTime: 开始时间 nil=不筛选
    ///   - endTime: 结束时间 nil=不筛选
    ///   - pageSize: 页容量
    ///   - pageCode: 当前页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetPaymentMyOrderList(startTime: Int?, endTime: Int?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: ["pageSize" : String(pageSize),
                                                               "pageCode" : String(pageCode)])
        if startTime != nil {
            parameters.setValue(String(startTime!), forKey: "startTime")
        }
        
        if endTime != nil {
            parameters.setValue(String(endTime!), forKey: "endTime")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PaymentMy, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转 泛型model
            let pageResult = PageResultModel<PaymentModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 查询订单详情
    ///
    /// - Parameters:
    ///   - orderId: 订单id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetPaymentDetail(orderId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : orderId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PaymentDetail, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = PaymentModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 查询订单-序列号
    ///
    /// - Parameters:
    ///   - serialNumber: 订单序列号
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebCheckOrderStatus(serialNumber: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["serialNumber" : serialNumber]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PaymentGetBySerialNumber, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let object = PaymentModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(object as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
