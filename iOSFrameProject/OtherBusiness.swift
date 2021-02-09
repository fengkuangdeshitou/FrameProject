//
//  OtherBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

/// app 适用系统的类型
///
/// - iosSystem: iOS 操作系统
/// - androidSystem: android 操作系统
enum APPSystemType: Int {
    case iosSystem = 1
    case androidSystem = 2
}



/// 分享任务的Code
///
/// - sharePhoto: 分享照片
/// - shareYearReport: 分享年报
enum TaskCodeType: String {
    case sharePhoto = "003"
    case shareYearReport = "004"
}



/// 碳币任务更新类型
///
/// - homeVC: 首页控制器更新
/// - mineVC: 我的界面更新
/// - updateCoinCount: 更新碳币数
enum CoinTaskUpdateType: String {
    case homeVC
    case mineVC
    case updateCoinCount
}


/// 碳币记录中的收支类型查询枚举
///
/// - income: 收入
/// - payOut: 支出
/// - all: 全部
enum CoinChangeLogIncomeType: String {
    case income = "true"
    case payOut = "false"
    case all = ""
}


class OtherBusiness: NSObject {
    // 单例
    static let shareIntance: OtherBusiness = {
        let regionBus = OtherBusiness()
        
        return regionBus
    }()
}


extension OtherBusiness {
    
    
    
    /****************** 区划相关 接口    **************************/
    
    /// 获取区划树
    ///
    /// - Parameter responseSuccess: responseSuccess Block
    func responseWebGetRegionTreeList(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_RegionGetTree, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            let dataSourceDict = responseObject as! NSDictionary
            responseSuccess(dataSourceDict as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /****************** 意见反馈相关 接口    **************************/
    
    /// 意见反馈接口
    ///
    /// - Parameters:
    ///   - linkStr: 联系方式
    ///   - content: 反馈内容
    ///   - responseSuccess: 返回成功的Block
    func responseWebSendUserFeedBack(linkStr: String, content: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_Feedback, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let feedBack = FeedBackModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(feedBack as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /****************** 排行榜相关 接口    **************************/
    
    /// 获取排行榜列表的接口
    ///
    /// - Parameter responseSuccess: 返回成功数据的Block
    func responseWebGetRankList(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_CityHourDataGetGRank, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [CityHourDataModel] = []
            for dataDict in dataSourceArray {
                let citysInfo = CityHourDataModel.init(json: JSON.init(dataDict as Any))
                dataSourceModelArray.append(citysInfo)
            }
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /****************** 碳币相关 接口    **************************/
    
    
    /// 获取登录用户碳币变更记录
    ///
    /// - Parameters:
    ///   - incomeType: 收支查询类型
    ///   - startTime: 开始时间
    ///   - endTime: 结束时间
    ///   - pageCode: 页索引
    ///   - responseSuccess: 返回成功block
    ///   - responseFailed: 返回失败block
    func responseWebGetCoinChangeLogList(incomeType: CoinChangeLogIncomeType, startTime: String, endTime: String, pageCode: Int, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameters = ["income" : incomeType.rawValue,
                          "startTime" : startTime,
                          "endTime" : endTime,
                          "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE,
                          "pageCode" : String(pageCode)]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_CoinChangeLogList, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<CoinChangeLogModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    
    
    
    /****************** 任务相关 接口    **************************/
    
    /// 获取任务规则列表
    ///
    /// - Parameter responseSuccess: 返回成功数据的Block
    func responseWebGetTaskList(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_TaskGetTaskList, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceArray = responseObject as! [AnyObject?]
            var dataSourceModelArray: [TaskModel] = []
            for dataDict in dataSourceArray {
                let taskInfo = TaskModel.init(json: JSON.init(dataDict as Any))
                dataSourceModelArray.append(taskInfo)
            }
            responseSuccess(dataSourceModelArray as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 分享任务成功通知
    ///
    /// - Parameters:
    ///   - taskShareCode: 分享任务的编码
    ///   - responseSuccess: 返回成功Block
    ///   - responseFailed: 返回失败block
    func responseWebShareTaskNotify(taskShareCode: TaskCodeType, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["taskTypeCode" : taskShareCode.rawValue]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_TaskShareTaskNotify, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            if (responseObject is NSDictionary) {
                let userTask = UserTaskModel.init(json: JSON.init(responseObject as Any))
                responseSuccess(userTask as AnyObject)
            }
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    
    /****************** 更新相关 接口    **************************/
    
    /// 获取应用详情（可判断App更新状态）
    ///
    /// - Parameter responseSuccess: 返回成功数据的Block
    func responseWebGetAppDetail(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["id" : INSIDE_UPDATE_APP_ID]
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "http://mobile.jointsky.com/MEPStore/", strApi: "app/detail", parameters: paramters as NSDictionary, resquestType: RequestType.GET, outRequestTime: REQUEST_TIMEOUT_VALUE, AESCPwd: nil, isTipInfo: true, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            let dataDict = responseObject as! NSDictionary;
            let resultCode = dataDict[RESULT_STATUS] as! String
            if resultCode == ResponseCodeType.success.rawValue {
                // 操作成功
                let appInfo = AppInfoModel.init(json:JSON.init(dataDict[RESULT_DATA] as Any))
                responseSuccess(appInfo as AnyObject)
            } else {
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(dataDict[RESULT_MSG] as? String, icon: nil, view: nil)
                let error = NSError.init(domain: "place try again", code: -1, userInfo: [ NSLocalizedDescriptionKey : "interface error" ])
                responseFailed(error)
            }
        }) { (error) in
            responseFailed(error)
        }
    }

    
    
    /****************** 发布通知相关 接口    **************************/
    
    
    /// 请求发布登录过期通知的接口   REST API
    ///
    /// - Parameters:
    ///   - newToken: 新用户的TOKEN
    ///   - userId: 用户Id
    ///   - isProduct:  true: 生产模式， false：开发模式
    ///   - responseSuccess: 返回成功的block
    ///   - responseFailed: 返回失败的block
    func responseWebRequestPublishLoginExpirePush(newToken: String, userId: String?, isProduct: Bool, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        if userId == nil {
            return
        }
        
        let timeStamp = String(format: "%.0f", Date.init().timeIntervalSince1970)
        
        // 消息体
        let messageDict = NSDictionary.init(dictionary: ["type" : MessageTypeCode.loginExpire.rawValue,
                                                         "aps" : ["alert" : ["title" : "登录异常", "body" : "您的账户已在其他地方登录", "new_token" : newToken]]])
        let paramters = ["appkey" : UM_SHARE_APP_KEY,
                         "timestamp" : timeStamp,
                         "type" : "customizedcast",
                         "alias" : userId!,
                         "alias_type" : UM_ALIAS_TYPE,
                         "payload" : messageDict,
                         "production_mode" : isProduct == true ? "true" : "false"] as [String : Any]
        
        let postBody = WebDataResponseInterface.shareInstance.getJSONStringFromDictionary(dictionary: paramters as NSDictionary)
        let sign = NSString.md5("POSThttp://msg.umeng.com/api/send" + postBody + UM_SHARE_APP_SECRET)
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "http://msg.umeng.com", strApi: "/api/send" + "?sign=" + sign!, parameters: paramters as NSDictionary, resquestType: RequestType.POST, outRequestTime: REQUEST_TIMEOUT_VALUE, AESCPwd: nil, isTipInfo: true, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            let dataDict = responseObject as! NSDictionary;
            let res_code = dataDict["ret_code"] as! Int
            if res_code == 0 {
                myPrint(message: "发送成功")
            } else {
                // error
                myPrint(message: "error: \(String(describing: dataDict["err_msg"]))")
            }
            
        }) { (error) in
            responseFailed(error)
        }
    }
    
    
    /****************** 应用数据统计相关 接口    **************************/
    
    
    /// 发布应用内部数据
    ///
    /// - Parameters:
    ///   - chargeMoney: 充值金额
    ///   - responseSuccess: 返回成功的block
    ///   - responseFailed: 返回失败的block
    func responseWebPublishAppInCommonData(userId: String?, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let appBoundleName = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
        let versionNo = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionBuildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        var isDebug = "false"
        #if DEBUG
            isDebug = "true"
        #endif
        
        let openUDID = OpenUDID.value()
        myPrint(message: "openUDID:\(String(describing: openUDID!))")
        let paramters = ["imei" : String(describing: openUDID!),
                         "systemTypeCode" : "1",
                         "brand" : "苹果",
                         "model" : DeviceTool.getDeviceName(),
                         "userId" : userId == nil ? "" : userId,
                         "appId" : APP_ID,
                         "applicationIdentity" : appBoundleName,
                         "appVersion" : versionNo,
                         "appBuildVersion" : versionBuildNo,
                         "systemVersionCode" : UIDevice.current.systemVersion,
                         "ip" : DeviceTool.getDeviceIPAddresses(),
                         "debug" : isDebug]
        WebDataResponseInterface.shareInstance.sessionManagerOriginWebData(strUrl: "http://115.159.156.24/MEPStore", strApi: "/appStatistics/useApp", parameters: paramters as NSDictionary, resquestType: RequestType.POST, outRequestTime: REQUEST_TIMEOUT_VALUE, AESCPwd: nil, isTipInfo: true, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            let dataDict = responseObject as! NSDictionary;
            let resultCode = dataDict[RESULT_STATUS] as! String
            if resultCode == ResponseCodeType.success.rawValue {
                // 操作成功
                responseSuccess(dataDict as AnyObject)
            } else {
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(dataDict[RESULT_MSG] as? String, icon: nil, view: nil)
                let error = NSError.init(domain: "place try again", code: -1, userInfo: [ NSLocalizedDescriptionKey : "interface error" ])
                responseFailed(error)
            }
        }) { (error) in
            responseFailed(error)
        }
    }
    
    
    
    /****************** 统一验证验证码 接口    **************************/
    
    /// 验证验证码是否相等
    ///
    /// - Parameters:
    ///   - phoneNumber: 手机号验证
    ///   - code: 验证码
    ///   - responseSuccess: 返回成功Block
    ///   - responseFailed: 返回失败block
    func responseWebVerfiyCodeVerify(phoneNumber: String, code: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        let parameters = ["phoneNumber" : phoneNumber,
                          "code" : code]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_VerfiyCodeVerify, parameters: parameters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
                responseSuccess(responseObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
}
