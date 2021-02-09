//
//  PhotoBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class PhotoBusiness: NSObject {
    // 单例
    static let shareIntance: PhotoBusiness = {
        let photoBus = PhotoBusiness()
        
        return photoBus
    }()
}


extension PhotoBusiness {
    /****************** 图片相关 接口    **************************/
    // MARK: 实景数据列表接口
    func responseWebGetSenceList(pageIndex: Int, photoTypCode: String, regionCode: String, minPm25: Int, maxPm25: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameter: NSMutableDictionary = ["regionCode" : regionCode,
                                              "photoTypeCode" : photoTypCode,
                                              "pageCode" : String(pageIndex),
                                              "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        if !(maxPm25 == 0 && minPm25 == 0) {
            parameter.addEntries(from: ["minPm25" : String(minPm25)])
            parameter.addEntries(from: ["maxPm25" : String(maxPm25)])
        }
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoSearch, parameters: parameter, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 获取指定用户的实景列表接口
    func responseWebGetUserTakeSenceList(pageIndex: Int, userId: String,  responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameter: NSMutableDictionary = ["userId" : userId,
                                              "pageCode" : String(pageIndex),
                                              "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoGetPageByUserId, parameters: parameter, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 获取自己点赞过的实景图片列表接口
    func responseWebGetMineSupportSenceList(pageIndex: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameter: NSMutableDictionary = ["pageCode" : String(pageIndex),
                                              "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoGetPageByLike, parameters: parameter, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 获取自己关注过的用户的实景图片列表接口
    func responseWebGetMineAttentionUsersSenceList(pageIndex: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameter: NSMutableDictionary = ["pageCode" : String(pageIndex),
                                              "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoGetPageByAttention, parameters: parameter, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 获取首页主题列表接口
    func responseWebGetSubjectList(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_SubjectGetSubject, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [SubjectModel] = []
            for object in dataSourceArray {
                
                let subjectInfo = SubjectModel.init(json: JSON.init(object as Any))
                dataSourceModelArray.append(subjectInfo)
            }
            
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 获取图片详情的接口
    func responseWebGetPhotoDetail(photoId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["id" : photoId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoDetail, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let photos = PhotoModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(photos as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    // MARK: 图片点赞接口
    func responseWebPhotoSupport(photoId: String, isLike: Bool, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let opIsLike = isLike ? "true" : "false"
        
        let paramters = ["photoId" : photoId, "op" : opIsLike]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoLike, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let photoLike = PhotoLike.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(photoLike as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取照片评论的列表接口
    func responseWebGetResponseSuccessList(pageIndex: Int, photoId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["photoId" : photoId,
                         "pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoCommentPage, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoLike>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 照片添加评论接口
    func responseWebphotoComment(replyUserId: String, photoId: String, content: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["photoId" : photoId,
                         "replyUserId" : replyUserId,
                         "content" : content]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoComment, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            responseSuccess(dataSourceDict as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 照片删除评论接口
    func responseWebPhotoCommentDelete(photoId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["id" : photoId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoCommentDelete, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            responseSuccess(responseObject as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
