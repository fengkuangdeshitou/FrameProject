//
//  CouponBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class CouponBusiness: NSObject {
    // 单例
    static let shareIntance: CouponBusiness = {
        let coupon = CouponBusiness()
        
        return coupon
    }()
}

extension CouponBusiness {
    /****************** 优惠券相关 接口    **************************/
    
    /// 获取指定商家发布的优惠券组
    ///
    /// - Parameters:
    ///   - merchantId: 商家id
    ///   - isExpired: 是否过期，无=不筛选
    ///   - isFinished: 是否已兑换完，无=不筛选
    ///   - pageSize: 页容量
    ///   - pageCode: 当前页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMerchantCouponGroupList(merchantId: String, isExpired: Bool?, isFinished: Bool?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: ["merchantId" : merchantId,
                                                               "pageSize" : String(pageSize),
                                                               "pageCode" : String(pageCode)])
        if isExpired != nil {
            parameters.setValue(isExpired == true ? "true" : "false", forKey: "isExpired")
        }
        
        if isFinished != nil {
            parameters.setValue(isFinished == true ? "true" : "false", forKey: "isFinished")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMerchantCouponGroup, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<CouponGroupModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 兑换优惠券
    ///
    /// - Parameters:
    ///   - couponGroupId: 优惠券组id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetCouponBuy(couponGroupId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["couponGroupId" : couponGroupId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_BuyCoupon, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = CouponModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 查看自己获取的优惠券
    ///
    /// - Parameters:
    ///   - merchantId: 商家id
    ///   - status: 优惠券状态
    ///   - pageSize: 页容量
    ///   - pageCode: 当前页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetMyCouponList(merchantId: String?, status: String?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: ["pageSize" : String(pageSize),
                                                               "pageCode" : String(pageCode)])
        if status != nil {
            parameters.setValue(status!, forKey: "status")
        }
        
        if merchantId != nil {
            parameters.setValue(merchantId!, forKey: "merchantId")
        }
        
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetMyCoupon, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<CouponModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    

    
    /// 商家发布优惠券组
    ///
    /// - Parameters:
    ///   - name: 名称
    ///   - description: 描述
    ///   - couponTypeCode: 优惠券类型编码
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - limitAmount: 最低订单金额，nil=不限制
    ///   - cointPrice: 碳币价格
    ///   - discount: 折扣值
    ///   - total: 总量
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebPublishCouponGroup(name: String, description: String, couponTypeCode: String, startTime: String, endTime: String, limitAmount: Double?, cointPrice: Int, discount: Double, total: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        
        let parameters = NSMutableDictionary.init(dictionary: [
            "name" : name,
            "description" : description,
            "couponTypeCode" : couponTypeCode,
            "startTime" : startTime,
            "endTime" : endTime,
            "coinPrice" : String(cointPrice),
            "discount" : String(format: "%.2f", discount),
            "total" : String(total)])
        if limitAmount != nil {
            parameters.setValue(String(format: "%.2f", limitAmount!), forKey: "limitAmount")
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PublishCouponGroup, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = CouponGroupModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 查看优惠券组下的优惠券
    ///
    /// - Parameters:
    ///   - couponGroupId: 优惠券组id
    ///   - status: 优惠券状态  0：未领取，1：已领取， nil:全部
    ///   - pageSize: 页容量
    ///   - pageCode: 页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetCouponGroupCouponList(couponGroupId: String, status: Int?, pageSize: Int, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = NSMutableDictionary.init(dictionary: [
            "couponGroupId" : couponGroupId,
            "pageSize" : String(pageSize),
            "pageCode" : String(pageCode)])
        
        if status != nil {
            parameters.setValue(String(status!), forKey: "status")
        }
        
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_GetCouponGroupCoupon, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<CouponModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
