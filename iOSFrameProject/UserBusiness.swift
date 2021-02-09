//
//  UserBusiness.swift
//  iOSFrameProject
//
//  Created by 陈帆 on 2018/4/16.
//  Copyright © 2018年 陈帆. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserBusiness: NSObject {

    // 单例
    static let shareIntance: UserBusiness = {
        let userBus = UserBusiness()
        
        return userBus
    }()
}

// 扩展类
extension UserBusiness {
    //// **********    User 相关   *****************////
    // 根据设备id登录用户获取用户信息
    func responseWebLoginByDeviceId(deviceId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["deviceId" : deviceId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserLoginByDeviceId, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    // MARK: 根据accessToken获取用户信息
    func responseWebAccessTokenGetUserInfo(responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_AccessTokenGetUserInfo, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // 根据UserId 获取用户信息
    func responseWebGetUserInfo(userId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        if userId == "" {
            return
        }
        let paramters = ["userId" : userId]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserDetail, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            if APP_DELEGATE.currentUserInfo?.id == userInfo.id {
                APP_DELEGATE.currentUserInfo = userInfo
                UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
                UserDefaults.standard.synchronize()
            }
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /// 更新用户头像
    ///
    /// - Parameters:
    ///   - userImage: 用户头像
    ///   - responseSuccess: 返回成功Block
    func responseWebUploadUserAvatar(userImage: UIImage, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        WebDataResponseInterface.shareInstance.SessionManagerWebDataUpload(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserUploadAvatar, formData: { (formData) in
            let imageData = userImage.jpegData(compressionQuality: 0.4)
            formData.appendPart(withFileData: imageData!, name: "avatarFile", fileName: "avatarFile" + ".jpg", mimeType: "image/jpg")
        }, parameters: nil, resquestType: .POST, responseProgress: {_ in}, responseSuccess: { (responseObject) in
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 更新用户昵称
    ///
    /// - Parameters:
    ///   - nickName: 用户nickName
    ///   - responseSuccess: 返回成功Block
    func responseWebUpdateUserNickName(nickName: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["nickname" : nickName]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserUpdateNickname, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 更新用户手机号
    ///
    /// - Parameters:
    ///   - phoneNum: 用户手机号
    ///   - responseSuccess: 返回成功Block
    func responseWebUpdateUserPhoneNum(phoneNum: String, smsCode: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["phoneNumber" : phoneNum,
                         "smsCode" : smsCode]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserUpdatePhoneNumber, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    /// 更新用户说说
    ///
    /// - Parameters:
    ///   - userSpeek: 用户说说
    ///   - responseSuccess: 返回成功Block
    func responseWebUpdateUserSpeek(userSpeek: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["speak" : userSpeek]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserSpeek, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 发送手机验证码
    ///
    /// - Parameters:
    ///   - phoneNumStr: 手机号
    ///   - responseSuccess: 返回成功Block
    func responseWebSendUserPhoneNumCode(phoneNumStr: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["phoneNumber" : phoneNumStr]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserSenSmsCode, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            responseSuccess(responseObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    //    /// 更新手机号
    //    ///
    //    /// - Parameters:
    //    ///   - userSpeek: 用户说说
    //    ///   - responseSuccess: 返回成功Block
    //    func responseWebUpdateUserSpeek(, userSpeek: String, responseSuccess: @escaping WebDataResponseSuccess) {
    //        let paramters = ["speak" : userSpeek]
    //
    //        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserUpdate, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
    //
    //            // 数据转model
    //            let dataSourceDict = responseObject as! NSDictionary
    //            let userInfo = JSONDeserializer<UserInfoModel>.deserializeFrom(dict: dataSourceDict)
    //
    //            // 更新本地用户信息
    //            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
    //            UserDefaults.standard.synchronize()
    //
    //            responseSuccess(userInfo as AnyObject)
    //        }) { (error) in
    //            myPrint(message: error)
    //        }
    //    }
    
    
    
    /// 用户升级
    ///
    /// - Parameters:
    ///   - phoneNumStr: 手机号
    ///   - smsCodeStr: 验证码
    ///   - newPassword: 密码
    ///   - responseSuccess: 成功返回的Block
    func responseWebUpdateUserPhoneOrPassword(phoneNumStr: String, smsCodeStr: String, newPassword: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["phoneNumber" : phoneNumStr,
                         "smsCode" : smsCodeStr,
                         "password" : newPassword]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserUpgrade, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 忘记密码
    ///
    /// - Parameters:
    ///   - phoneNumStr: 手机号
    ///   - smsCodeStr: 验证码
    ///   - newPassword: 密码
    ///   - responseSuccess: 成功返回的Block
    func responseWebUpdateUserForgetPassword(phoneNumStr: String, smsCodeStr: String, newPassword: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["phoneNumber" : phoneNumStr,
                         "smsCode" : smsCodeStr,
                         "newPassword" : newPassword]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserForgetPassword, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    
    /// 获取指定用户的关注用户列表接口
    func responseWebGetUserAtteionUserList(pageIndex: Int, userId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["userId" : userId,
                         "pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserGetAttentionPage, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<UserInfoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取指定用户的粉丝用户列表接口
    func responseWebGetUserFollowUserList(pageIndex: Int, userId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["userId" : userId,
                         "pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserGetFollowPage, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<UserInfoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取用户昵称搜索相关用户的列表接口
    func responseWebGetUserNameSearchUsersList(pageIndex: Int, nickName: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["keyword" : nickName,
                         "pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserSearchByKeyword, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<UserInfoModel>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 获取点赞用户的列表接口
    func responseWebGetPhotoSupportUsersList(pageIndex: Int, photoId: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let parameter = ["photoId" : photoId,
                         "pageCode" : String(pageIndex),
                         "pageSize" : DEFAULT_IMAGE_CELL_PAGESIZE]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_PhotoGetLikePage, parameters: parameter as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            // 数据转 泛型model
            let pageResult = PageResultModel<PhotoLike>.init(json: JSON.init(responseObject as Any))
            responseSuccess(pageResult as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    
    // MARK: 用户关注接口
    func responseWebUserAttention(userId: String, isLike: Bool, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        
        
        let opIsLike = isLike ? "true" : "false"
        
        let paramters = ["userId" : userId, "op" : opIsLike]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserAttention, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let photoLike = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新当前用户信息
            self.responseWebGetUserInfo(userId: (APP_DELEGATE.currentUserInfo?.id)!, responseSuccess: { (userSuccess) in
                APP_DELEGATE.currentUserInfo = userSuccess as? UserInfoModel
            }, responseFailed: {(error) in
                
            })
            
            responseSuccess(photoLike as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    // MARK: 用户登录接口
    func responseWebUserLogin(nickName: String, password: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["username" : nickName, "password" : password]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserLoginByUsername, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let dataSourceDict = responseObject as! NSDictionary
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            // 更新本地用户信息
            UserDefaults.standard.set(dataSourceDict, forKey: DICT_USER_INFO)
            UserDefaults.standard.synchronize()
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    /// 用户注册接口
    ///
    /// - Parameters:
    ///   - nickName: 用户昵称
    ///   - password: 用户密码
    ///   - phoneNum: 手机号
    ///   - sendCode: 发送验证码
    ///   - responseSuccess: 返回成功block
    ///   - responseFailed: 返回失败block
    func responseWebUserRegister(nickName: String, password: String, phoneNum: String, sendCode:String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["nickname" : nickName,
                         "password" : password,
                         "phoneNumber" : phoneNum,
                         "smsCode" : sendCode,]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserRegister, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据转model
            let userInfo = UserInfoModel.init(json: JSON.init(responseObject as Any))
            
            responseSuccess(userInfo as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
    
    
    
    // MARK: 用户退出接口
    func responseWebExitCurrentUserLogin() {
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UserLogout, parameters: nil, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            myPrint(message: "退出用户登录：\(String(describing: responseObject))")
        }) { (error) in
            myPrint(message: error)
        }
    }
    
    
    
    /// 检查手机号是否已注册
    ///
    /// - Parameters:
    ///   - phoneNum: 手机号
    ///   - responseSuccess: 返回成功block
    ///   - responseFailed: 返回失败block
    func responseWebUserPhoneNumIsExist(phoneNum: String, responseSuccess: @escaping WebDataResponseSuccess, responseFailed: @escaping WebDataResponseFailure) {
        let paramters = ["phoneNumber" : phoneNum]
        
        WebDataResponseInterface.shareInstance.SessionManagerWebData(strUrl: WEBBASEURL, strApi: WEBREQUEST_INTERFACE_UPhoneNumIsExist, parameters: paramters as NSDictionary, resquestType: .POST, responseProgress: {_ in }, responseSuccess: { (responseObject) in
            
            // 数据
            let isExist = responseObject as! Bool
            responseSuccess(isExist as AnyObject)
        }) { (error) in
            myPrint(message: error)
            responseFailed(error)
        }
    }
}
