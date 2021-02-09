//
//  GlobalPrefixHeader.swift
//  EnvironmentSource
//
//  Created by jointsky on 2016/11/28.
//  Copyright © 2016年 陈帆. All rights reserved.
//

import UIKit
import Foundation


/*******************   SCREEN  屏幕的尺寸     ******************/
let SCREEN_WIDTH = UIScreen.main.bounds.size.width              // 宽
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height            // 高


/********************    application Delegate  *************/
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate


/*****************     VIEW 界面视图设置     *****************/
// MARK:     建议：导航栏中的按钮图片的大小一般为26  26@2x   26@3x
// 导航栏和状态栏的高度
let NAVIGATION_AND_STATUS_HEIGHT: CGFloat = (44.0+20.0)
 // 工具栏的高度
let TOOL_BAR_HEIGHT: CGFloat = 49.0
// tabBar和navBar上的图标的标准大小
let ITEM_IMAGE_CGSZE = CGSize.init(width: 26, height: 26)
// 状态栏的高度
let STATUS_BAR_HEIGHT: CGFloat = 20.0
// 导航栏的高度
let NAVIGATION_BAR_HEIGHT: CGFloat = 44.0
// 一般cell的高度
let CELL_NORMAL_HEIGHT: CGFloat = 44.0


/*********************   COLOR  - 颜色      **************************/
// 系统普通颜色
let COLOR_NORMAL_SYSTEM = UIColorRGBA_Selft(r: 255, g: 255, b: 255, a: 1.0)
// 系统高亮颜色
let COLOR_HIGHT_LIGHT_SYSTEM = UIColorRGBA_Selft(r: 252, g: 81, b: 81, a: 1.0)
// 分割线的颜色
let COLOR_SEPARATOR_LINE = UIColorFromRGB(rgbValue: 0xd9d9d9)
// tableView 的背景色
let BG_COLOR_TABLE_OR_COLLECTION = UIColorFromRGB(rgbValue: 0xf1f0f0)
// light Gay color
let COLOR_LIGHT_GAY = UIColorFromRGB(rgbValue: 0x999999)
// Gay color
let COLOR_GAY = UIColorFromRGB(rgbValue: 0x666666)
// dark Gay color
let COLOR_DARK_GAY = UIColorFromRGB(rgbValue: 0x333333)

// carbon coin color
let COLOR_CARBON_COIN = UIColorFromRGB(rgbValue: 0xe59c1e)

// user name color
let COLOR_USER_NAME_HIGHLIGHT = UIColorFromRGB(rgbValue: 0x45aced)

// pay success
let COLOR_PAY_SUCCESS = UIColorFromRGB(rgbValue: 0x19d462)

// pay failed
let COLOR_PAY_FAILED = UIColorFromRGB(rgbValue: 0xfc5151)

// coupon BG discount Color
let COLOR_BG_DISCOUNT_COUPON = UIColorFromRGB(rgbValue: 0xf7941d)
// coupon BG money Color
let COLOR_BG_MONEY_COUPON = UIColorFromRGB(rgbValue: 0x7accc8)


/*********************    FONT  - 字体样式     **********************/
//正常系统显示的字体
let FONT_NORMAL_FAMILY = "Helvetica-Light"


/*********************   FONTSIZE  - 字体大小     ********************/
// MARK: 导航栏上的字体大小
let NAVIGATION_TITLE_FONT_SIZE:CGFloat = 18.0
// MARK: 大字体
let FONT_BIG_SIZE:CGFloat = 16.0
// MARK: 大字体
let FONT_SYSTEM_SIZE:CGFloat = 15.0
// MARK: 标准字体
let FONT_STANDARD_SIZE:CGFloat = 14.0
// mark: 小字体
let FONT_SMART_SIZE:CGFloat = 12.0
// mark: 非常小字体
let FONT_VERY_SMART_SIZE:CGFloat = 9.0



/********************     layout 布局设置    ****************/
// 标准的圆角弧度
let CORNER_NORMAL:CGFloat = 5.0
// 标准的圆角弧度
let CORNER_SMART:CGFloat = 3.0
// 标准的圆角弧度
let BORDER_WIDTH: CGFloat = 0.5


/*******************    DATE 日期时间设置     *********************/
// 日期的标准格式
let DATE_STANDARD_FORMATTER = "yyyy-MM-dd HH:mm:ss"
// 验证码重新获取描述（单位：s）
let RUN_LOOP_VALUE = 60


/************************     DICT_KEY 自定义         ********************/
let DICT_TITLE = "title"             // 标题
let DICT_SUB_TITLE = "subTitle"      // 标题
let DICT_IMAGE_PATH = "imagePath"    // 本地图片地址
let DICT_IDENTIFIER = "identifier"   // ID
let DICT_IS_NEXT = "isNext"          // 是否有跳转
let DICT_USER_INFO  = "userInfo"     // 用户信息字典key
let DICT_USER_RECENT  = "userRecent" // 用户信息字典key
let DICT_SUB_VALUE1  = "value1"      // value1的key
let DICT_SUB_VALUE2  = "value2"      // value2的key
let DICT_SUB_VALUE3  = "value3"      // value3的key
let DICT_IS_SHOW_COIN_TASK = "isShowCoinTask"   // 是否显示过碳币任务列表
let DICT_IS_MESSAGE_ALL_READED = "isMessageAllReaded"   // 是否所有消息已读
let DICT_SAVE_PHOTO_DESCIPTION = "SAVE_PHOTO_DESCIPTION"   // 保存照片描述


/*********************     LOCATION  定位设置     **********************/
/// 默认 未定位成功的城市 和 code
let DEFAULT_LOCATIONFAILED_CITY = "北京市"
let DEFAULT_LOCATIONFAILED_CODE = "110000000"
let DEFAULT_CITY_CENTER_LONGITUDE = "116.403406"
let DEFAULT_CITY_CENTER_LATITUDE = "39.91582"
/// 定位保存值
let LOCATION_ADDRESS = "locationAddress"        // 定位地址
let LOCATION_LATITUDE = "locationLatitude"      // 定位维度
let LOCATION_LONGTITUDE = "locationLongitude"   // 定位经度


/*****************     IMAGE_DEFAULT  默认图片     ********************/
// 默认返回键的图片地址
let DEFAULT_BACK_IMAGE_PATH = "default_back_icon.png"
// 默认的用户头像
let DEFAULT_USER_ICON = UIImage(named: "defaultUserImage.png")
// 默认App图标
let DEFUALT_APP_ICON = UIImage(named: "default_app_icon.png")



/****************    AIR_QUALITY - 空气质量设置    **********************/
let PHOTO_PM_25 = "pm25"                        // Pm2.5


/****************  NOTIFICATION - 消息通知机制    *********************/
let NOTIFICATION_UPDATE_UserInfo = "NotificationUpdateUserInfo"     // 用户消息通知
let NOTIFICATION_UPDATE_UserInfo_Merchant = "NotificationUpdateUserInfoMerchant"     // 用户消息通知
let NOTIFICATION_UPDATE_PhotoInfo = "NotificationUpdatePhotoInfo"   // 图片消息通知
let NOTIFICATION_UPDATE_UserOtherLogin = "NotificationUserOtherLogin"   // 用户其它地方登录通知
let NOTIFICATION_UPDATE_UserRegister = "NotificationUserRegister"       // 用户注册成功通知
let NOTIFICATION_UPDATE_CoinTaskUpdate = "NotificationCoinTaskupdate"   // 碳币任务更新
let NOTIFICATION_UPDATE_MessageAllRead = "NotificationMessageAllRead"   // 消息全部已读通知
let NOTIFICATION_UPDATE_SystemPushMessage = "NotificationSystemPushMessage"   // 接收系统的推送消息通知
let NOTIFICATION_UPDATE_PayStatus = "NotificationUpdatePayStatus"   // 接收支付信息状态


/**************   ACCOUNT - 账户信息    ****************/
/// App Store id信息
let APP_ID = "1070816677"   // Appid
let URL_APPSTORE_APP = "itms-apps://itunes.apple.com/app/id"        // App在App Store的下载地址
/// 蒲公英账号为：851327579@qq.com 的相关信息
let PGY_API_KEY = "6fb379590470d1446e4142fe9d2ea15e"
let PGY_UKEY = "9c45df7e6a46bbcdc03693a9bd54bb17"
/// 高德地图ApiKey
let AMAP_API_KEY = "f2b0626afaa35e7882e48da6c9fb937a"   // 正式："f2b0626afaa35e7882e48da6c9fb937a"    测试："5697595edb009314cacfa4300bd148f6"
let INSIDE_UPDATE_APP_ID = "297ebe0e6078129a0161464c97570008"

/// **** 友盟相关  ******///
// 微信分享AppID
let WEIXIN_APPID = "wx21d9c4d0d13b26a7"
let WEIXIN_APP_SECRET = "1068da29df77d352526ab82d33cc7628"
// QQ分享AppID
let QQ_APPID = "1105529515"
let QQ_APP_SECRET = "pDTu4kM88ekLQ4J4"
// 微博分享AppID
let Weibo_APPID = "2092239034"
let Weibo_APP_SECRET = "47dc0e3ab02cc64367c898fa0708aeab"
// 友盟APPKey
let UM_SHARE_APP_KEY = "577c80b5e0f55a6664002d76"
let UM_SHARE_APP_SECRET = "edrqyabuv4n9y2zwavbxvdohzc8kgqxh"
let UM_ALIAS_TYPE = "userId"

// 支付宝APPID
let ALIPAY_appID = "2018011201795917"
let ALIPAY_ReturnCheckStr = "safepay"

// 腾讯信鸽推送
let XG_ACCESS_ID: UInt32 = 2200293493
let XG_ACCESS_KEY = "IZJB7JL5766M"
let XG_SECRET_KEY = "9130ea535197328cd7a41635e299062a"


/*****************   CHARACTER 文字长度个数     ******************/
let PHOTO_DESCRIPTION_LENGTH = 250 // 图片描述（字）
let SUGGEST_INFO_LENGTH = 250 //  意见反馈(字）
let WORDCOUNT_USERNAME = 20   // 用户昵称（字）
let WORDCOUNT_USER_SPEAK = 50 // 用户说说长度（字）
let WORDCOUNT_USER_PASSWORD = 20    // 用户密码长度（字）
let WORDCOUNT_USER_PASSWORD_MIN = 6 // 用户密码长度（字）
let WORDCOUNT_USER_PHONE = 11   // 手机号长度（字）
let WORDCOUNT_USER_EMAIL = 50   // 邮箱最大长度（字）
let WORDCOUNT_CHECK_CODE = 6    // 手机验证码长度（字）
let WORDCOUNT_WATER_MARK_SHORT = 20    // 水印短字体长度（字）
let WORDCOUNT_WATER_MARK_LONG = 140    // 水印长字体长度（字）
let WORDCOUNT_ADD_COUPON_SENDCOUNT_MAX = 10000  // 添加优惠券- 发放数量为1万张
let WORDCOUNT_ADD_COUPON_COSTCARBON_MAX = 100000  // 添加优惠券- 价值碳币数为10万枚
let WORDCOUNT_ADD_COUPON_FULLMONEY_MAX = 100000  // 添加优惠券- 满减金额最大为10万元
let WORDCOUNT_ADD_COUPON_DISCOUNT_PRICE_MAX = 100000  // 添加优惠券- 优惠金额最大为10万元
let WORDCOUNT_ADD_COUPON_DISCOUNT_DISCOUNT_MAX = 9.9  // 添加优惠券- 优惠折扣最大为9.9折
let WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_NAME_MAX = 50  // 商家入驻- 商家名称最大50个字
let WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_ADDRESS_MAX = 100  // 商家入驻- 商家地址最大字数
let WORDCOUNT_MERCHNAT_REGISTER_MERCHANT_DESCRIPTION_MAX = 1000  // 商家入驻- 商家描述最大字数


/*****************    WORD_TIP 文字提示     ******************/
let RESPONSE_DATA_NIL = "请求到的数据为空"
let RESULT_WEB_ERROR = "网络异常，请稍后重试"
let OTHER_LOGING_TIP = "该用户已在其它地方登录"
let GLOBAL_USERINFO_NIL_TIP = "未获取到当前用户信息, 请重新登录"
let GLOBAL_CHECK_PHONE_NOT_SEND_TIP = "该手机号未发送验证码"
let GLOBAL_CHECK_PHONE_CHECK_CODE_TIP = "验证码不正确"
let GLOBAL_CHECK_PASSWORD_LENGTH_TIP = "密码长度6~20个字符"


/*****************    文件目录     ******************/
let DOCUMENTS_PATH = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
let SEARCH_HISTORY_PATH = "searchHistory.plist"  // search history 的记录文件地址


/// 设置rgb颜色的方法
///
/// - parameter r: red
/// - parameter g: green
/// - parameter b: blue
/// - parameter a: alpha
///
/// - returns: UIColor
func UIColorRGBA_Selft(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}



/// 获取随机颜色值
///
/// - Returns: 颜色对象
func getRandomColor() -> UIColor {
    return UIColor(red: CGFloat(Double(arc4random_uniform(256))/255.0), green: CGFloat(Double(arc4random_uniform(256))/255.0), blue: CGFloat(Double(arc4random_uniform(256))/255.0), alpha: 1.0)
}

/// 根据开始位置和长度截取字符串
///
/// - Parameters:
///   - textStr: 要截取的字符串
///   - start: 开始位置
///   - length: 截取长度
/// - Returns: 截取后的字符串
func CUTString(textStr: String, start:Int, length:Int = -1) -> String {
    var len = length
    if len == -1 {
        len = textStr.count - start
    }
    let st = textStr.index(textStr.startIndex, offsetBy:start)
    let en = textStr.index(st, offsetBy:len)
    return String(textStr[st ..< en])
}


/// 16进制的方式设置颜色（eg. 0xff1122）
///
/// - Parameter rgbValue: 16进制颜色值
/// - Returns: UIColor
func UIColorFromRGB(rgbValue:Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
}



/// 字体样式设置  1
///
/// - parameter maxFont: maxFont description
/// - parameter minFont: minFont description
/// - parameter color:   color description
/// - parameter action:  action description
///
/// - returns: return value description
func PRICE_ANDFONT_ANDCOLOR(maxFont: CGFloat, minFont: CGFloat, color : UIColor, action: @escaping (() -> Void)) -> NSDictionary {
    
    let setDictType = ["FontMax" : UIFont.boldSystemFont(ofSize: maxFont),
                   "FontMin": UIFont.systemFont(ofSize: minFont),
                   "help": WPAttributedStyleAction.styledAction(action: {
                    action()
                   }),
    "link" : color] as [String : Any]
    
    return setDictType as NSDictionary
}


/// 获取默认的图片对象
///
/// - Returns: 默认占位图片
func DEFAULT_IMAGE() -> UIImage {
    let defaultImagePath = "default_image\((arc4random() % 5)+1)"
    return UIImage.init(named: defaultImagePath)!
}



/// PM2.5值对应的颜色获取方法
///
/// - Parameter pm25Value: PM2.5值
/// - Returns: UIColor
func colorPm25WithValue(pm25Value: Int) -> UIColor {
    if pm25Value >= 0 && pm25Value < 50 {
        return UIColorFromRGB(rgbValue: 0x67cf00)
    } else if pm25Value >= 50 && pm25Value < 100 {
        return UIColorFromRGB(rgbValue: 0xfdd100)
    } else if pm25Value >= 100 && pm25Value < 150 {
        return UIColorFromRGB(rgbValue: 0xff8901)
    } else if pm25Value >= 150 && pm25Value < 200 {
        return UIColorFromRGB(rgbValue: 0xff2500)
    } else if pm25Value >= 200 && pm25Value < 300 {
        return UIColorFromRGB(rgbValue: 0x991753)
    } else if pm25Value >= 300 && pm25Value < 500 {
        return UIColorFromRGB(rgbValue: 0x62091d)
    } else if pm25Value >= 500 {
        return UIColor.black
    } else {
        return UIColor.white
    }
}



/// 计算字符串长度
///
/// - Parameters:
///   - text: 字符串
///   - font: 字体大小
///   - size: 字符串长宽最大值
/// - Returns: 计算字符串的合理长宽
func sizeWithText(text: NSString, font: UIFont, size: CGSize) -> CGSize {
    let attributes = [NSAttributedString.Key.font: font]
    let option = NSStringDrawingOptions.usesLineFragmentOrigin
    let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
    return rect.size;
}



/// 获取随机的cell高度
///
/// - Parameter cellWidth: cell Width
/// - Parameter randomNumber: 随机整数
/// - Returns: cell Height
func getRandomCellHeight(cellWidth: Float, randomNumber: Int) -> Float {
    var randomIndex = 0
    if 48 <= randomNumber && randomNumber < 53 {
        randomIndex = 0
    } else if 53 <= randomNumber && randomNumber < 60 {
        randomIndex = 1
    } else if 60 <= randomNumber && randomNumber < 65 {
        randomIndex = 2
    } else if 65 <= randomNumber && randomNumber < 70 {
        randomIndex = 3
    } else if 70 <= randomNumber && randomNumber < 80 {
        randomIndex = 4
    } else if 80 <= randomNumber && randomNumber < 90 {
        randomIndex = 5
    } else if 90 <= randomNumber && randomNumber < 120 {
        randomIndex = 6
    } else if 120 <= randomNumber && randomNumber < 170 {
        randomIndex = 7
    } else if 170 <= randomNumber && randomNumber < 210 {
        randomIndex = 8
    } else if 210 <= randomNumber && randomNumber < 255 {
        randomIndex = 9
    }
    
    switch randomIndex {
    case 0:
        return cellWidth * 4.0 / 3.0
    case 1:
        return cellWidth * 3.0 / 4.0
    case 2:
        return cellWidth * 9.0 / 6.0
    case 3:
        return cellWidth * 6.0 / 9.0
    case 4:
        return cellWidth * 15.0 / 10.0
    case 5:
        return cellWidth * 10.0 / 15.0
    case 6:
        return cellWidth * 16.0 / 9.0
    case 7:
        return cellWidth * 9.0 / 16.0
    default:
        return cellWidth
    }
}


///// 自定义简单的打印
/////
///// - parameter message: message
//func myPrint<T>(message: T) {
//    #if DEBUG
//        print("info:\(message)")
//    #endif
//}


/// 自定义带方法名和行号的打印方法
///
/// - parameter message:    message
/// - parameter methodName: 方法名
/// - parameter lineNumber: 行号
func myPrint<T>(message: T, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
        print("\(methodName)[\(lineNumber)]:\(message)")
    #endif
}



/// 格式化显示浮点数字符串（有小数值，则显示；没有就不显示）
///
/// - Parameter testNumber: 源字符串
/// - Returns: 格式后字符串
func formatterDoubleStringShow(testNumber:String) -> String{
    
    var outNumber = String(format: "%@", testNumber)
    var i = 1
    
    if testNumber.contains("."){
        while i < testNumber.count {
            if outNumber.hasSuffix("0"){
                outNumber.remove(at: outNumber.endIndex)
                i = i + 1
            }else{
                break
            }
        }
        if outNumber.hasSuffix("."){
            outNumber.remove(at: outNumber.endIndex)
        }
        return outNumber
    }
    else{
        return testNumber
    }
}






