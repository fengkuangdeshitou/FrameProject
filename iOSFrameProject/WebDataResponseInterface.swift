//
//  WebDataResponseInterface.swift
//  EnvironmentSource
//
//  Created by jointsky on 2016/11/29.
//  Copyright © 2016年 陈帆. All rights reserved.
//

import UIKit
import AFNetworking

/**
 *  网络数据请求接口信息
 */

// 参数秘钥
let ACCESS_KEY = "EPI_JOINTSKY"

// 网络请求时间 单位：s
let REQUEST_TIMEOUT_VALUE = 10

// 每页显示的cell个数
let DEFAULT_IMAGE_CELL_PAGESIZE = "20"


// 请求ip 端口   自建平台数据请求地址
let WEBBASEURL = "https://mobile.jointsky.com/EcoCity" // App Store
//let WEBBASEURL = "http://115.159.156.24/EcoCity" // 正式
//let WEBBASEURL = "http://192.168.4.10:8180/EcoCity"  // 测试内网
//let WEBBASEURL = "http://115.159.156.24:8180/EcoCity"  // 测试外网
//let WEBBASEURL = "http://115.159.156.24:8280/EcoCity"  // 开发测试

// 图片地址
//let WEBBASEURL_IAMGE = "http://115.159.156.24:8180/attachment/ecocity"  // 测试外网
let WEBBASEURL_IAMGE = "https://mobile.jointsky.com/attachment/ecocity"  // 正式
//let WEBBASEURL_IAMGE = "http://115.159.156.24:8280/attachment/ecocity"  // 开发测试

// 解密密码
let AESC_PASSWORD = "JOINT_MOBILE_APP"    // 加密
//let AESC_PASSWORD = ""                      // 未加密


// accessToken
let ACCESS_TOKEN = "accessToken"


/*/////////////// ***********   接口信息  ***********  ////////////////////////
 ********************************************************************/
///////////////// 用户 //////////////////////////
// 登录-设备id，不存在则自动注册临时用户
let WEBREQUEST_INTERFACE_UserLoginByDeviceId = "/user/loginByDeviceId"
// 根据AccessToken获取用户信息
let WEBREQUEST_INTERFACE_AccessTokenGetUserInfo = "/user/info"
// 正式用户登录
let WEBREQUEST_INTERFACE_UserLoginByUsername = "/user/loginByUsername"
// 用户注册
let WEBREQUEST_INTERFACE_UserRegister = "/user/register"
// 退出登录
let WEBREQUEST_INTERFACE_UserLogout = "/user/logout"
// 判断手机号是否已注册
let WEBREQUEST_INTERFACE_UPhoneNumIsExist = "/user/checkPhoneNumber"
// 发送短信验证码
let WEBREQUEST_INTERFACE_UserSenSmsCode = "/verifyCode/sendSmsCode"
// 升级正式用户
let WEBREQUEST_INTERFACE_UserUpgrade = "/user/upgrade"
// 忘记密码
let WEBREQUEST_INTERFACE_UserForgetPassword = "/user/forgetPassword"
// 获取指定用户详情
let WEBREQUEST_INTERFACE_UserDetail = "/user/detail"
// 修改昵称
let WEBREQUEST_INTERFACE_UserUpdateNickname = "/user/updateNickname"
// 修改手机号
let WEBREQUEST_INTERFACE_UserUpdatePhoneNumber = "/user/updatePhoneNumber"
// 发表说说
let WEBREQUEST_INTERFACE_UserSpeek = "/user/speak"
// 修改密码
let WEBREQUEST_INTERFACE_UserUpdatePassword = "/user/updatePassword"
// 上传用户头像
let WEBREQUEST_INTERFACE_UserUploadAvatar = "/user/uploadAvatar"
// 获取指定用户的"粉丝"用户分页
let WEBREQUEST_INTERFACE_UserGetFollowPage = "/user/getFollowPage"
// 获取指定用户的"关注"用户分页
let WEBREQUEST_INTERFACE_UserGetAttentionPage = "/user/getAttentionPage"
// 关注指定用户
let WEBREQUEST_INTERFACE_UserAttention = "/userAttention/attention"
// 关键字搜索用户
let WEBREQUEST_INTERFACE_UserSearchByKeyword = "/user/searchByKeyword"


///////////////// 图片相关接口 //////////////////////////
// 发布照片
let WEBREQUEST_INTERFACE_PhotoPublish = "/photo/publish"
// 查询照片列表分页
let WEBREQUEST_INTERFACE_PhotoSearch = "/photo/search"
// 获取自己点赞过的照片分页
let WEBREQUEST_INTERFACE_PhotoGetPageByLike = "/photo/getPageByLike"
// 获取自己关注用户发布的照片分页
let WEBREQUEST_INTERFACE_PhotoGetPageByAttention = "/photo/getPageByAttention"
// 获取指定用户发布的照片分页
let WEBREQUEST_INTERFACE_PhotoGetPageByUserId = "/photo/getPageByUserId"
// 获取照片详情
let WEBREQUEST_INTERFACE_PhotoDetail = "/photo/detail"
// 照片点赞
let WEBREQUEST_INTERFACE_PhotoLike = "/photoLike/like"
// 照片举报
let WEBREQUEST_INTERFACE_PhotoReport = "/photoReport/report"
// 获取照片点赞分页
let WEBREQUEST_INTERFACE_PhotoGetLikePage = "/photoLike/getLikePage"
// 获取照片评论分页
let WEBREQUEST_INTERFACE_PhotoCommentPage = "/photoComment/page"
// 照片添加评论
let WEBREQUEST_INTERFACE_PhotoComment = "/photoComment/comment"
// 照片删除评论
let WEBREQUEST_INTERFACE_PhotoCommentDelete = "/photoComment/delete"
// 获取视觉故事列表
let WEBREQUEST_INTERFACE_SenseStoryPage = "/senseStory/page"
// 获取视觉故事详情
let WEBREQUEST_INTERFACE_SenseStoryDetial = "/senseStory/detail"


///////////////// 商家相关接口 //////////////////////////
// 获取商家列表
let WEBREQUEST_INTERFACE_GetMerchantList = "/merchant/search"
// 获取商家详情
let WEBREQUEST_INTERFACE_GetMerchantDetail = "/merchant/detail"
// 二维码字符串获取商家详情
let WEBREQUEST_INTERFACE_GetMerchantDetailByQR = "/merchant/detailByQR"
// 获取商家交易流水列表
let WEBREQUEST_INTERFACE_GetMerchantTradeRecordList = "/merchantAmountChangeLog/page"
// 查询交易流水详情
let WEBREQUEST_INTERFACE_GetMerchantTradeRecordDetail = "/merchantAmountChangeLog/detail"
// 今日收入
let WEBREQUEST_INTERFACE_GetMerchantTradeRecordTodayIncome = "/merchantAmountChangeLog/todayIncome"
// 提现
let WEBREQUEST_INTERFACE_GetWithdraw = "/withdraw/withdraw"
// 提现详情
let WEBREQUEST_INTERFACE_GetWithdrawDetail = "/withdraw/detail"
// 获取商家类型列表
let WEBREQUEST_INTERFACE_GetMerchantTypeList = "/dictionary/getMerchantTypeList"
// 上传商家入驻信息
let WEBREQUEST_INTERFACE_UploadMerchantRegisterInfo = "/merchant/join"
// 验证商家今日是否可以提现
let WEBREQUEST_INTERFACE_TodayCanWithDraw = "/withdraw/todayCanWithdraw"



///////////////// 优惠券相关接口 //////////////////////////
// 获取指定商家发布的优惠券组
let WEBREQUEST_INTERFACE_GetMerchantCouponGroup = "/coupon/getMerchantCouponGroup"
// 兑换优惠券
let WEBREQUEST_INTERFACE_BuyCoupon = "/coupon/buyCoupon"
// 查询自己领取的优惠券
let WEBREQUEST_INTERFACE_GetMyCoupon = "/coupon/getMyCoupon"
// 商家发布优惠券组
let WEBREQUEST_INTERFACE_PublishCouponGroup = "/coupon/publishCouponGroup"
// 查看优惠券组下的优惠券
let WEBREQUEST_INTERFACE_GetCouponGroupCoupon = "/coupon/getCouponGroupCoupon"



///////////////// 支付相关接口 //////////////////////////
// 下单
let WEBREQUEST_INTERFACE_PaymentPrepay = "/payment/prepay"
// 我的订单列表
let WEBREQUEST_INTERFACE_PaymentMy = "/payment/my"
// 查询订单详情
let WEBREQUEST_INTERFACE_PaymentDetail = "/payment/detail"
// 查询订单-序列号
let WEBREQUEST_INTERFACE_PaymentGetBySerialNumber = "/payment/getBySerialNumber"



///////////////// 消息相关接口 //////////////////////////
// 获取消息分页
let WEBREQUEST_INTERFACE_MessagePage = "/message/page"
// 标记已读
let WEBREQUEST_INTERFACE_MessageRead = "/message/read"
// 全部标记已读
let WEBREQUEST_INTERFACE_MessageReadAll = "/message/readAll"
// 设置消息
let WEBREQUEST_INTERFACE_PushMessageSetting = "/message/setting"
// 获取设置消息
let WEBREQUEST_INTERFACE_PushMessageGetSetting = "/message/getSetting"



///////////////// 排行榜相关接口 //////////////////////////
// 获取排行榜列表
let WEBREQUEST_INTERFACE_CityHourDataGetGRank = "/cityHourData/getRank"



///////////////// PM2.5相关接口 //////////////////////////
// 获取附近pm2.5
let WEBREQUEST_INTERFACE_StationHourDataGetNearbyPm25 = "/stationHourData/getNearbyPm25"



///////////////// 反馈相关接口 //////////////////////////
// 意见反馈
let WEBREQUEST_INTERFACE_Feedback = "/feedback/feedback"



///////////////// 区划相关接口 //////////////////////////
// 获取区划树
let WEBREQUEST_INTERFACE_RegionGetTree = "/region/getTree"



///////////////// 主题相关接口 //////////////////////////
// 获取主题列表
let WEBREQUEST_INTERFACE_SubjectGetSubject = "/subject/getSubject"


///////////////// 碳币相关接口 //////////////////////////
// 获取登录用户碳币变更记录
let WEBREQUEST_INTERFACE_CoinChangeLogList = "/coinChangeLog/getLog"


///////////////// 任务相关接口 //////////////////////////
// 获取任务规则列表
let WEBREQUEST_INTERFACE_TaskGetTaskList = "/task/getTaskList"
// 分享任务成功通知
let WEBREQUEST_INTERFACE_TaskShareTaskNotify = "/task/shareTaskNotify"


///////////////// 校验验证码相关接口 //////////////////////////
// 校验验证码接口
let WEBREQUEST_INTERFACE_VerfiyCodeVerify = "/verifyCode/verify"



/////////////////  返回数据正确判断   ///////////////////
let RESULT_RIGHT = 1      // 成功
let RESULT_ERROR = 0      // 错误


////////////////   数据返回   ////////////////
let  RESULT_CODE = "ResultCode"       //  数据返回时，校验码
let  RESULT_MESSAGE = "ResultMessage" //  数据返回体
let  RESULT_MSG = "msg"               //  消息提示语
let  RESULT_STATUS = "status"         // 状态 code
let  RESULT_DATA = "data"             //  数据json块



// 上传进度
typealias WebDataResponseProgress = (_ progress: Float) -> ()
// 请求成功的包
typealias WebDataResponseSuccess = (_ result : AnyObject?) -> ()
// 请求失败的包
typealias WebDataResponseFailure = (_ error: NSError) -> ()
// 请求formData包
typealias WebDataResponseFormData = (_ formData: AFMultipartFormData) -> ()


/// 请求类型
///
/// - GET:  GET 方式
/// - POST: POST 方式
enum RequestType : String {
    case GET = "GET"
    case POST = "POST"
}



/// 返回状态码
///
/// - success: 操作成功
/// - failure: 服务器错误
/// - noAuthority: 没有访问权限
/// - noLogin: 没有登录
/// - operatorFail: 操作失败
enum ResponseCodeType : String {
    case success = "101"
    case failure = "001"
    case noAuthority = "002"
    case noLogin = "003"
    case operatorFail = "004"
}



/// 网络请求封装类
class WebDataResponseInterface : AFHTTPSessionManager {
    public let isAutoDeAESC = AESC_PASSWORD == "" ? false : true    // 是否自动解密
    
    // 单例
    static let shareInstance :  WebDataResponseInterface = {
        let responseInterface = WebDataResponseInterface()
        
        responseInterface.responseSerializer.acceptableContentTypes?.insert("text/xml")
        responseInterface.requestSerializer = AFHTTPRequestSerializer()
        responseInterface.responseSerializer = AFHTTPResponseSerializer()
        responseInterface.requestSerializer.timeoutInterval = TimeInterval(REQUEST_TIMEOUT_VALUE)
        
        return responseInterface
    }()

}


// MARK: 封装请求方法
extension WebDataResponseInterface {
    
    
    /// 返回数据处理的总接口方法
    ///
    /// - Parameters:
    ///   - strUrl: URL
    ///   - strApi: API
    ///   - parameters: 参数
    ///   - resquestType: 请求类型（RequestType.GET || RequestType.POST）
    ///   - responseProgress: progress Block
    ///   - responseSuccess: success Block
    ///   - responseFailure: Failure Block
    func SessionManagerWebData(strUrl: String, strApi: String, parameters: NSDictionary?, resquestType: RequestType, responseProgress: @escaping WebDataResponseProgress, responseSuccess: @escaping WebDataResponseSuccess, responseFailure: @escaping WebDataResponseFailure) {
        
        // 定义上传进度闭包
        let progressCallBack = {(progress: Progress) -> Void in
            let progressValue = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            responseProgress(progressValue)
        }
        
        // 定义成功回调的闭包
        let successCallBack = {(stak : URLSessionDataTask , result : Any?) -> Void in
            //把闭包传出去
            if result ==  nil {
                return;
            }
        
            // 获取 http 数据返回头数据
            let allHeaderFieldsDict = (stak.response as! HTTPURLResponse).allHeaderFields
            self.saveAccessTokenWithHeaderFieldsDict(headerDict: allHeaderFieldsDict as! [String : String])
            
            let stringData: NSString = NSString.init(data: result as! Data, encoding:String.Encoding.utf8.rawValue)!
            
            var responseObject: Any?
            if self.isAutoDeAESC {
                // 解密
                let stringData2 = AESCryptJointSky.decrypt(stringData as String?, password: AESC_PASSWORD)
                responseObject = stringData2?.mj_JSONObject()
            } else {
                // 不解密
                responseObject = stringData.mj_JSONObject()
            }
            
            responseObject = NSDictionary.processDictionaryIsNSNull(responseObject)
//            responseObject = tools.processDictionaryIsNSNull(responseObject)
            if responseObject == nil {
                MBProgressHUD.showBottom(RESPONSE_DATA_NIL, icon: nil, view: nil)
                let error = NSError.init(domain: "data error", code: -1, userInfo: [ NSLocalizedDescriptionKey : "decrypt error" ])
                responseFailure(error as NSError)
                return
            }
            let dataDict = responseObject as! NSDictionary;
            let resultCode = dataDict[RESULT_STATUS] as! String
            if resultCode == ResponseCodeType.success.rawValue {
                // 操作成功
                responseSuccess(dataDict[RESULT_DATA] as AnyObject?)
            } else {
                let resultMsg = dataDict[RESULT_MSG] as? String
                if resultCode == ResponseCodeType.noLogin.rawValue || (resultMsg?.contains("登录已过期"))! {
                    // 发送用户在其它地方登录的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
                }
                
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(resultMsg, icon: nil, view: nil)
                let error = NSError.init(domain: "place try again", code: -1, userInfo: [ NSLocalizedDescriptionKey : "interface error" ])
                responseFailure(error)
            }
        }
        
        // 定义错误回调的闭包
        let failureCallBack = {(task: URLSessionDataTask, error: Error) -> Void in
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(RESULT_WEB_ERROR, icon: nil, view: nil)
            responseFailure(error as NSError)
        }
        
        // 设置请求时间
        self.requestSerializer.timeoutInterval = TimeInterval(REQUEST_TIMEOUT_VALUE)
        
        // 设置请求头中 AccessToken
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
        if accessToken != nil {
//             self.requestSerializer.setValue("accessToken=\(String(describing: accessToken!))", forHTTPHeaderField: "Set-Cookie")
            self.requestSerializer.setValue("\(String(describing: accessToken!))", forHTTPHeaderField: ACCESS_TOKEN)
        }
        
        // GET 请求方式
        if resquestType == .GET {
            var requestUrl = strUrl+strApi
            requestUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
            get(requestUrl, parameters: parameters, headers: [:], progress: { (progress) in
                progressCallBack(progress)
                }, success: { (sessionDataTask, resultObject) in
                    successCallBack(sessionDataTask, resultObject)
                }, failure: { (sessionDataTask, error) in
                    failureCallBack(sessionDataTask!, error)
            })
        }
        
        // POST 请求方式
        if resquestType == .POST {
            let requestUrl = strUrl+strApi
            post(requestUrl, parameters: parameters,headers: [:], progress: { (progress) in
                progressCallBack(progress)
                }, success: { (sessionDataTask, resultObject) in
                    successCallBack(sessionDataTask, resultObject)
                }, failure: { (sessionDataTask, error) in
                    failureCallBack(sessionDataTask!, error)
            })
        }
    }
    
    
    
    /// 带有超时时间参数的总接口方法
    ///
    /// - Parameters:
    ///   - strUrl: URL
    ///   - strApi: API接口
    ///   - parameters: 参数
    ///   - resquestType: 请求类型（RequestType.GET || RequestType.POST）
    ///   - outRequestTime: 请求超时时间（单位：s）
    ///   - responseProgress: progress Block
    ///   - responseSuccess: Success Block
    ///   - responseFailure: Failure Block
    func SessionManagerWebDataALLParamters(strUrl: String, strApi: String, parameters: NSDictionary?, resquestType: RequestType, outRequestTime: Int, responseProgress: @escaping WebDataResponseProgress, responseSuccess: @escaping WebDataResponseSuccess, responseFailure: @escaping WebDataResponseFailure) {
        
        // 定义上传进度闭包
        let progressCallBack = {(progress: Progress) -> Void in
            let progressValue = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            responseProgress(progressValue)
        }
        
        
        // 定义成功回调的闭包
        let successCallBack = {(stak : URLSessionDataTask , result : Any?) -> Void in
            //把闭包传出去
            if result ==  nil {
                return;
            }
            
            // 获取 http 数据返回头数据
            let allHeaderFieldsDict = (stak.response as! HTTPURLResponse).allHeaderFields
            self.saveAccessTokenWithHeaderFieldsDict(headerDict: allHeaderFieldsDict as! [String : String])
            
            let stringData: NSString = NSString.init(data: result as! Data, encoding:String.Encoding.utf8.rawValue)!
            
            var responseObject: Any?
            if self.isAutoDeAESC {
                // 解密
                let stringData2 = AESCryptJointSky.decrypt(stringData as String?, password: AESC_PASSWORD)
                responseObject = stringData2?.mj_JSONObject()
            } else {
                // 不解密
                responseObject = stringData.mj_JSONObject()
            }
            
            responseObject = NSDictionary.processDictionaryIsNSNull(responseObject)
//            responseObject = tools.processDictionaryIsNSNull(responseObject)
            if responseObject == nil {
                MBProgressHUD.showBottom(RESPONSE_DATA_NIL, icon: nil, view: nil)
                let error = NSError.init(domain: "data error", code: -1, userInfo: [ NSLocalizedDescriptionKey : "decrypt error" ])
                responseFailure(error as NSError)
                return
            }
            let dataDict = responseObject as! NSDictionary;
            let resultCode = dataDict[RESULT_STATUS] as! String
            if resultCode == ResponseCodeType.success.rawValue {
                // 操作成功
                responseSuccess(dataDict[RESULT_DATA] as AnyObject?)
            } else {
                if resultCode == ResponseCodeType.noLogin.rawValue {
                    // 发送用户在其它地方登录的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
                }
                
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(dataDict[RESULT_MSG] as? String, icon: nil, view: nil)
                let error = NSError.init(domain: "place try again", code: -1, userInfo: [ NSLocalizedDescriptionKey : "interface error" ])
                responseFailure(error)
            }
        }
        
        // 定义错误回调的闭包
        let failureCallBack = {(task: URLSessionDataTask, error: Error) -> Void in
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(RESULT_WEB_ERROR, icon: nil, view: nil)
            responseFailure(error as NSError)
        }
        
        // 设置请求时间
        self.requestSerializer.timeoutInterval = TimeInterval(outRequestTime)
        // 设置请求头中 AccessToken
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
        if accessToken != nil {
            //             self.requestSerializer.setValue("accessToken=\(String(describing: accessToken!))", forHTTPHeaderField: "Set-Cookie")
            self.requestSerializer.setValue("\(String(describing: accessToken!))", forHTTPHeaderField: ACCESS_TOKEN)
        }
        
        // GET 请求方式
        if resquestType == .GET {
            var requestUrl = strUrl+strApi
            requestUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
            get(requestUrl, parameters: parameters,headers: [:], progress: { (progress) in
                progressCallBack(progress)
            }, success: { (sessionDataTask, resultObject) in
                successCallBack(sessionDataTask, resultObject)
            }, failure: { (sessionDataTask, error) in
                failureCallBack(sessionDataTask!, error)
            })
        }
        
        // POST 请求方式
        if resquestType == .POST {
            let requestUrl = strUrl+strApi
            post(requestUrl, parameters: parameters,headers: [:], progress: { (progress) in
                progressCallBack(progress)
            }, success: { (sessionDataTask, resultObject) in
                successCallBack(sessionDataTask, resultObject)
            }, failure: { (sessionDataTask, error) in
                failureCallBack(sessionDataTask!, error)
            })
        }
    }
    
    
    /// 返回原始数据请求方法
    ///
    /// - Parameters:
    ///   - strUrl: URL
    ///   - strApi: API接口
    ///   - parameters: 参数
    ///   - resquestType: 请求类型（RequestType.GET || RequestType.POST）
    ///   - outRequestTime: 请求超时时间（单位：s）
    ///   - AESCPwd: 解密秘钥
    ///   - isTipInfo: 是否有提示信息
    ///   - responseProgress: progress Block
    ///   - responseSuccess: Success Block
    ///   - responseFailure: Failure Block
    func sessionManagerOriginWebData(strUrl: String, strApi: String, parameters: NSDictionary?, resquestType: RequestType, outRequestTime: Int, AESCPwd: String?, isTipInfo:Bool?, responseProgress: @escaping WebDataResponseProgress, responseSuccess: @escaping WebDataResponseSuccess, responseFailure: @escaping WebDataResponseFailure) {
        
        // 定义上传进度闭包
        let progressCallBack = {(progress: Progress) -> Void in
            let progressValue = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            responseProgress(progressValue)
        }
        
        
        // 定义成功回调的闭包
        let successCallBack = {(stak : URLSessionDataTask , result : Any?) -> Void in
            //把闭包传出去
            if result ==  nil {
                return;
            }
            
            // 获取 http 数据返回头数据
            let allHeaderFieldsDict = (stak.response as! HTTPURLResponse).allHeaderFields
            self.saveAccessTokenWithHeaderFieldsDict(headerDict: allHeaderFieldsDict as! [String : String])
            
            let stringData: NSString = NSString.init(data: result as! Data, encoding:String.Encoding.utf8.rawValue)!
            
            var responseObject = stringData.mj_JSONObject()
            if AESCPwd != nil {
                // 解密
                let stringData2 = AESCryptJointSky.decrypt(stringData as String?, password: AESC_PASSWORD)
                responseObject = stringData2?.mj_JSONObject()
            }
            
            // 判断是否为空
            if responseObject == nil {
                if isTipInfo != nil && isTipInfo! {
                    MBProgressHUD.showBottom(RESPONSE_DATA_NIL, icon: nil, view: nil)
                }
                
                let error = NSError.init(domain: "data error", code: -1, userInfo: [ NSLocalizedDescriptionKey : "decrypt error" ])
                responseFailure(error as NSError)
                return
            }
            
            // 去除里面的的nil，null等值
            responseObject = NSDictionary.processDictionaryIsNSNull(responseObject)
//            responseObject = tools.processDictionaryIsNSNull(responseObject)
            let dataDict = responseObject as! NSDictionary;
            responseSuccess(dataDict as AnyObject?)
        }
        
        // 定义错误回调的闭包
        let failureCallBack = {(task: URLSessionDataTask, error: Error) -> Void in
            MBProgressHUD.hide()
            if isTipInfo != nil && isTipInfo! {
                MBProgressHUD.showBottom(RESULT_WEB_ERROR, icon: nil, view: nil)
            }
            responseFailure(error as NSError)
        }
        
        // 设置请求时间
        self.requestSerializer.timeoutInterval = TimeInterval(outRequestTime)
        // GET 请求方式
        if resquestType == .GET {
            var requestUrl = strUrl+strApi
            requestUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
            get(requestUrl, parameters: parameters,headers:[:], progress: { (progress) in
                progressCallBack(progress)
            }, success: { (sessionDataTask, resultObject) in
                successCallBack(sessionDataTask, resultObject)
            }, failure: { (sessionDataTask, error) in
                failureCallBack(sessionDataTask!, error)
            })
        }
        
        // POST 请求方式
        if resquestType == .POST {
            let requestUrl = strUrl+strApi
            post(requestUrl, parameters: parameters,headers:[:], progress: { (progress) in
                progressCallBack(progress)
            }, success: { (sessionDataTask, resultObject) in
                successCallBack(sessionDataTask, resultObject)
            }, failure: { (sessionDataTask, error) in
                failureCallBack(sessionDataTask!, error)
            })
        }
    }
    
    
    
    
    // 上传文件的总方法
    func SessionManagerWebDataUpload(strUrl: String, strApi: String, formData: @escaping WebDataResponseFormData, parameters: NSDictionary?, resquestType: RequestType, responseProgress: @escaping WebDataResponseProgress, responseSuccess: @escaping WebDataResponseSuccess, responseFailure: @escaping WebDataResponseFailure) {
        
        // 定义上传进度闭包
        let progressCallBack = {(progress: Progress) -> Void in
            let progressValue = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            responseProgress(progressValue)
        }
        
        
        // 定义成功回调的闭包
        let successCallBack = {(stak : URLSessionDataTask , result : Any?) -> Void in
            //把闭包传出去
            if result ==  nil {
                return;
            }
            
            // 获取 http 数据返回头数据
            let allHeaderFieldsDict = (stak.response as! HTTPURLResponse).allHeaderFields
            self.saveAccessTokenWithHeaderFieldsDict(headerDict: allHeaderFieldsDict as! [String : String])
            
            let stringData: NSString = NSString.init(data: result as! Data, encoding:String.Encoding.utf8.rawValue)!
            
            var responseObject: Any?
            if self.isAutoDeAESC {
                // 解密
                let stringData2 = AESCryptJointSky.decrypt(stringData as String?, password: AESC_PASSWORD)
                responseObject = stringData2?.mj_JSONObject()
            } else {
                // 不解密
                responseObject = stringData.mj_JSONObject()
            }
            
            responseObject = NSDictionary.processDictionaryIsNSNull(responseObject)
//            responseObject = tools.processDictionaryIsNSNull(responseObject)
            if responseObject == nil {
                MBProgressHUD.showBottom(RESPONSE_DATA_NIL, icon: nil, view: nil)
                let error = NSError.init(domain: "data error", code: -1, userInfo: [ NSLocalizedDescriptionKey : "decrypt error" ])
                responseFailure(error as NSError)
                return
            }
            let dataDict = responseObject as! NSDictionary;
            let resultCode = dataDict[RESULT_STATUS] as! String
            if resultCode == ResponseCodeType.success.rawValue {
                // 操作成功
                responseSuccess(dataDict[RESULT_DATA] as AnyObject?)
            } else {
                let resultMsg = dataDict[RESULT_MSG] as? String
                if resultCode == ResponseCodeType.noLogin.rawValue || (resultMsg?.contains("登录已过期"))! {
                    // 发送用户在其它地方登录的广播
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_UPDATE_UserOtherLogin), object: nil)
                }
                
                MBProgressHUD.hide()
                MBProgressHUD.showBottom(dataDict[RESULT_MSG] as? String, icon: nil, view: nil)
                let error = NSError.init(domain: "place try again", code: -1, userInfo: [ NSLocalizedDescriptionKey : "interface error" ])
                responseFailure(error)
            }
        }
        
        // 定义错误回调的闭包
        let failureCallBack = {(task: URLSessionDataTask, error: Error) -> Void in
            MBProgressHUD.hide()
            MBProgressHUD.showBottom(RESULT_WEB_ERROR, icon: nil, view: nil)
            responseFailure(error as NSError)
        }
        
        var requestUrl = strUrl+strApi
        requestUrl = requestUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
        
        // 设置请求时间
        self.requestSerializer.timeoutInterval = TimeInterval(1000)
        // 设置请求头中 AccessToken
        let accessToken = UserDefaults.standard.string(forKey: ACCESS_TOKEN)
        if accessToken != nil {
            //             self.requestSerializer.setValue("accessToken=\(String(describing: accessToken!))", forHTTPHeaderField: "Set-Cookie")
            self.requestSerializer.setValue("\(String(describing: accessToken!))", forHTTPHeaderField: ACCESS_TOKEN)
        }
        
        post(requestUrl, parameters: parameters,headers: [:], constructingBodyWith: formData, progress: { (progress) in
            progressCallBack(progress)
        }, success: { (sessionDataTask, resultObject) in
            successCallBack(sessionDataTask, resultObject)
        }) { (sessionDataTask, error) in
            failureCallBack(sessionDataTask!, error)
        }
    }
    
    
    // MARK: 保存 HeaderDict中的AccessToken
    func saveAccessTokenWithHeaderFieldsDict(headerDict: [String : String]) {
        let accessToken = headerDict[ACCESS_TOKEN]
        if accessToken == nil || accessToken == "" {
            return
        }
        
        UserDefaults.standard.set(accessToken, forKey: ACCESS_TOKEN)
        UserDefaults.standard.synchronize()
    }
    
    
    /**
     字典转换为JSONString
     
     - parameter dictionary: 字典参数
     
     - returns: JSONString
     */
    func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try! JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
    
    
    /// JSONString转换为字典
    ///
    /// - Parameter jsonString: jsonStr
    /// - Returns: JsonDict
    func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{
        
        let jsonData:Data = jsonString.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
}








