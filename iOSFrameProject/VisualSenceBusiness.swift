//
//  VisualSenceBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/5/10.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class VisualSenceBusiness: NSObject {
    // 单例
    static let shareIntance: VisualSenceBusiness = {
        let visual = VisualSenceBusiness()
        
        return visual
    }()
}


extension VisualSenceBusiness {
    /****************** 视觉相关 接口    **************************/
    
    
    /// 获取视觉故事列表接口
    ///
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetSenseStoryList(pageIndex: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_SenseStoryPage, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<SenceStoryModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取视觉故事详情
    ///
    /// - Parameters:
    ///   - visualId: 视觉故事id
    ///   - responseSuccess: 响应成功，返回block
    ///   - responseFailed: 响应失败，返回block
    func responseWebGetSenseStoryDetial(visualId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["id" : visualId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_SenseStoryDetial, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let merchant = SenceStoryModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(merchant as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
