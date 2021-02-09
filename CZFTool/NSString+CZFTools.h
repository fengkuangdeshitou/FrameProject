//
//  NSString+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CZFTools)

/**
 *  获取当前时间戳 - return转字符串
 */
+ (NSString *)getTimestamp;

/**
 *  获取唯一字符串 设备id+时间戳的字符串
 *
 *  @return 唯一字符串
 */

+ (NSString *)getUniqueID;


/**
 *  获取本地时间  （标准格式：yyyy-MM-dd HH:mm:ss）
 *
 *  @return 本地时间字符串
 */

+ (NSString *)getLocalTime;


/**
 *  将数字的字符串转成随机的pm2.5
 *
 *  @param string 源字符串
 *
 *  @return 目标字符串
 */

+ (NSString *)randomStringWithString:(NSString *) string;


/**
 *  可读格式化存储大小
 *
 *  @param size 存储大小   单位：B
 *
 *  @return B, K, M, G 为单位
 */
+ (NSString *)fileSizeWithInterge:(NSInteger)size;


/**
 *  验证是否为手机号
 *
 *  @param phoneNum 要验证的手机号码
 *
 *  @return 是否为手机号
 */

+(BOOL)checkPhoneNumInputWithPhoneNum:(NSString *)phoneNum;


/**
 验证邮箱
 
 @param email email
 @return 是否是邮箱
 */
+ (BOOL)checkEmailInputWithEmail:(NSString *)email;


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
+ (BOOL)isInputRuleNotBlank:(NSString *)str;


/**
 * 字母、数字、中文正则判断（包括空格）【注意3】
 */
+ (BOOL)isInputRuleAndBlank:(NSString *)str;


/**
 *  获得 kMaxLength长度的字符
 */
+ (NSString *)getSubCharString:(NSString*)string andMaxLength:(int)mexLength;


/**
 *  获得 kMaxLength长度的字
 */
+ (NSString *)getSubWordString:(NSString*)string andMaxLength:(int)mexLength;


/**
 *  过滤字符串中的emoji
 */
+ (NSString *)disable_emoji:(NSString *)text;


/*
 *第二种方法，利用Emoji表情最终会被编码成Unicode，因此，
 *只要知道Emoji表情的Unicode编码的范围，
 *就可以判断用户是否输入了Emoji表情。
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;


/**
 *  校验字符串防止nil字符串操作
 *
 *  @param stringText 字符串
 *
 *  @return 校验后的字符串
 */
+ (NSString *)verifyString:(id)stringText;


/**
 过滤字符串中HTML标签的方法
 
 @param html 含HTML标签的字符串
 @return    过滤后的字符串
 */
+ (NSString *)flattenHTML:(NSString *)html;


/**
 判断本地是否存在该文件
 
 @param fileName 文件名称或者路径
 @return 存在的文件路径，不存在则返回nil
 */
+ (NSString *)checkFilePathExistWithFileName:(NSString *)fileName;


/**
 统计目录文件下文件的总大小
 
 @param folderPath 目录地址
 @return 总大小
 */
+ (long long)folderSizeWithPath:(NSString *)folderPath;


/**
 计算指定文件的大小
 
 @param filePath 文件地址
 @return 大小
 */
+ (long long)fileSizeWithPath:(NSString *)filePath;


/**
 删除指定目录下的所有文件
 
 @param folderPath 目录地址
 */
+ (void)removeFolderPathAndFileWithPath:(NSString *)folderPath;


/**
 url参数字符串转字典
 
 @param urlStr url参数字符串
 @return 结果字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr;


/**
 json 字符串转字典的方法
 
 @param jsonString json字符串
 @return 转换后的字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


/**
 改变字符start 和 end 之间的字符的颜色 和 字体大小
 
 @param theTextView UITextView
 @param start 开始字符串
 @param end 结束字符串
 @param allColor 整体颜色
 @param markColor 想要标注的颜色
 @param fontSize 字体大小
 */
+ (void)messageAction:(UITextView *)theTextView startString:(NSString *)start endString:(NSString *)end andAllColor:(UIColor *)allColor andMarkColor:(UIColor *)markColor andMarkFondSize:(float)fontSize;


/**
 *判断字符串是否不全为空
 */
+ (BOOL)judgeStringIsNull:(NSString *)string;


/**
 判断字符串是否为纯数字
 
 @param checkedNumString 字符串
 @return 结果Bool类型
 */
+ (BOOL)isNum:(NSString *)checkedNumString;


/**
 判断字符串是否为格式字符串中的字符
 
 @param string 要匹配的字符串
 @param formatStr 字符串格式 (字母数字：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789，
 字母：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz，
 数字：0123456789，
 数字与小数点：.0123456789)
 @return yes,no
 */
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string andFormat:(NSString *)formatStr;


/**
 根据字符串中后缀的格式类型返回对应的本地文件类型图标
 
 @param checkString 判断字符串
 @return 本地文件类型的图标地址
 */
+ (NSString *)getLocalImageWithCheckString:(NSString *)checkString;


// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str;


// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str;


// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str;


/**
 根据PM2.5值获取污染程度描述
 
 @param pm25Value pm2.5值
 @return pm2.5描述
 */
+ (NSString *)stringPm25LevelDescription:(NSInteger)pm25Value;


/**
 将距离变成可读的格式
 
 @param distance 距离
 @return 可读字符串
 */
+ (NSString *)stringReadDistanceWith:(CGFloat)distance;


/**
 调用系统的MD5加密
 
 @param input 源字符串
 @return 目标字符串
 */
+ (NSString *)md5:(NSString *)input;


/**
 获取指定开始和结束的字符串
 
 @param startStr 开始的字符串
 @param endStr 结束的字符串
 @param string 待处理字符串
 @return 目标字符串
 */
+ (NSString *)stringRangeOfStringWithStart:(NSString *)startStr andEnd:(NSString *)endStr andDealStr:(NSString *)string;


/**
 根据详细地址字符串获取城市名称
 
 @param addressStr 地址字符串
 @return 城市名
 */
+ (NSString *)getCityNameWithAddressStr:(NSString *)addressStr;

/**
 根据详细地址字符串获取省和城市名称
 
 @param addressStr 地址字符串
 @return 省和城市名
 */
+ (NSString *)getCityAndProinceNameWithAddressStr:(NSString *)addressStr;


/**
 去掉小数点后边多余的0
 
 @param string 源字符串
 @return 目标字符串
 */
+(NSString*)removeFloatAllZero:(NSString*)string;

@end
