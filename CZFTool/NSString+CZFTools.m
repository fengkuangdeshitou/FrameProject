//
//  NSString+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "NSString+CZFTools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CZFTools)

/**
 *  获取当前时间戳 - return转字符串
 */
+ (NSString *)getTimestamp {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%.f",timeInterval];
    return timestamp;
}


/**
 *  获取唯一字符串 设备id+时间戳的字符串
 *
 *  @return 唯一字符串
 */

+ (NSString *)getUniqueID {
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *uniqueID = [identifier stringByAppendingString:[NSString stringWithFormat:@"%.f",timeInterval]];
    return uniqueID;
}


/**
 *  获取本地时间  （标准格式：yyyy-MM-dd HH:mm:ss）
 *
 *  @return 本地时间字符串
 */

+ (NSString *)getLocalTime {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *localTime = [formatter stringFromDate:date];
    return localTime;
}


/**
 *  将数字的字符串转成随机的pm2.5
 *
 *  @param string 源字符串
 *
 *  @return 目标字符串
 */

+ (NSString *)randomStringWithString:(NSString *) string {
    
    int pm2_5 = [string intValue];
    
    if (pm2_5 < 20) {
        int i = arc4random() % 4 - 2;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 30){
        int i = arc4random() % 10 - 5;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if (pm2_5< 40){
        int i = arc4random() % 12 - 6;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 60){
        int i = arc4random() % 16 - 8;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 70){
        int i = arc4random() % 16 - 8;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else if(pm2_5 < 80){
        int i = arc4random() % 18 - 9;
        return [self formats:[NSString stringWithFormat:@"%d",pm2_5 + i]];
    }else {
        int i = arc4random() % 20 - 10;
        return [NSString stringWithFormat:@"%d",pm2_5 + i] ;
        
    }
}


+ (NSString *)formats:(NSString *)obj {
    
    NSRange foundObj=[obj rangeOfString:@"-" options:NSCaseInsensitiveSearch];
    
    if (foundObj.length > 0) {
        NSLog(@"%@", [obj substringFromIndex:1]);
        return [obj substringFromIndex:1];
    }else {
        return obj;
    }
}


/**
 *  可读格式化存储大小
 *
 *  @param size 存储大小   单位：B
 *
 *  @return B, K, M, G 为单位
 */
+ (NSString *)fileSizeWithInterge:(NSInteger)size {
    // 1k = 1024, 1m = 1024k
    if (size < 1024) {// 小于1k
        return [NSString stringWithFormat:@"%ldB",(long)size];
    }else if (size < 1024 * 1024){// 小于1m
        CGFloat aFloat = size/1024.0f;
        return [NSString stringWithFormat:@"%.1fK",aFloat];
    }else if (size < 1024 * 1024 * 1024){// 小于1G
        CGFloat aFloat = size/(1024.0f * 1024.0f);
        return [NSString stringWithFormat:@"%.1fM",aFloat];
    }else{
        CGFloat aFloat = size/(1024.0f*1024.0f*1024.0f);
        return [NSString stringWithFormat:@"%.2fG",aFloat];
    }
}


/**
 *  验证是否为手机号
 *
 *  @param phoneNum 要验证的手机号码
 *
 *  @return 是否为手机号
 */

+(BOOL)checkPhoneNumInputWithPhoneNum:(NSString *)phoneNum {
    NSString *pattern = @"1[3578]\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:phoneNum];
    return isMatch;
    
}


/**
 验证邮箱
 
 @param email email
 @return 是否是邮箱
 */
+ (BOOL)checkEmailInputWithEmail:(NSString *)email
{
    NSString *emailRegex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


/**
 * 字母、数字、中文正则判断（不包括空格）
 */
+ (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
/**
 * 字母、数字、中文正则判断（包括空格）【注意3】
 */
+ (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}


/**
 *  获得 kMaxLength长度的字符
 */
+ (NSString *)getSubCharString:(NSString*)string andMaxLength:(int)mexLength
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* data = [string dataUsingEncoding:encoding];
    NSInteger length = [data length];
    if (length > mexLength) {
        NSData *data1 = [data subdataWithRange:NSMakeRange(0, mexLength)];
        NSString *content = [[NSString alloc] initWithData:data1 encoding:encoding];//【注意4】：当截取kMaxLength长度字符时把中文字符截断返回的content会是nil
        if (!content || content.length == 0) {
            data1 = [data subdataWithRange:NSMakeRange(0, mexLength - 1)];
            content =  [[NSString alloc] initWithData:data1 encoding:encoding];
        }
        return content;
    }
    return nil;
}

/**
 *  获得 kMaxLength长度的字
 */
+ (NSString *)getSubWordString:(NSString*)string andMaxLength:(int)mexLength
{
    if (string.length > mexLength) {
        NSString *content = [string substringToIndex:mexLength];
        return content;
    }
    return nil;
}

/**
 *  过滤字符串中的emoji
 */
+ (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍‍‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"‍" withString:@""];
    modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"•" withString:@""];
    //modifiedString = [modifiedString stringByReplacingOccurrencesOfString:@"?" withString:@""];
    return modifiedString;
}


/*
 *第二种方法，利用Emoji表情最终会被编码成Unicode，因此，
 *只要知道Emoji表情的Unicode编码的范围，
 *就可以判断用户是否输入了Emoji表情。
 */
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    // 过滤所有表情。returnValue为NO表示不含有表情，YES表示含有表情
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x2022 || hs == 0xd83e) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}


/**
 *  校验字符串防止nil字符串操作
 *
 *  @param stringText 字符串
 *
 *  @return 校验后的字符串
 */
+ (NSString *)verifyString:(id)stringText {
    if ([stringText isKindOfClass:[NSNull class]]) {
        return @"";
    } else if ([stringText isEqual:NULL]) {
        return @"";
    } else if ([stringText isEqual:@"null"]) {
        return @"";
    } else if ([stringText isEqual:@"<null>"]) {
        return @"";
    }
    
    
    return stringText == nil ? @"" : stringText;
}


/**
 过滤字符串中HTML标签的方法
 
 @param html 含HTML标签的字符串
 @return    过滤后的字符串
 */
+ (NSString *)flattenHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    } // while //
    
    return html;
}


/**
 判断本地是否存在该文件
 
 @param fileName 文件名称或者路径
 @return 存在的文件路径，不存在则返回nil
 */
+ (NSString *)checkFilePathExistWithFileName:(NSString *)fileName {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *fileNameArray = [fileName componentsSeparatedByString:@"/"];
    NSString *exitFilePath = [cachesPath stringByAppendingPathComponent:fileNameArray[fileNameArray.count-1]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:exitFilePath]) {
        return exitFilePath;
    }
    return nil;
}


/**
 统计目录文件下文件的总大小
 
 @param folderPath 目录地址
 @return 总大小
 */
+ (long long)folderSizeWithPath:(NSString *)folderPath {
    // 获取默认的文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断文件是否存在
    if (![fileManager fileExistsAtPath:folderPath]) return 0;
    
    //文件的枚举器
    NSEnumerator *fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    long long filesAllSize = 0;
    while ((fileName = [fileEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        if ([fileAbsolutePath hasSuffix:@"doc"] || [fileAbsolutePath hasSuffix:@"DOC"]  || [fileAbsolutePath hasSuffix:@"docx"] || [fileAbsolutePath hasSuffix:@"DOCX"] || [fileAbsolutePath hasSuffix:@"pdf"] || [fileAbsolutePath hasSuffix:@"PDF"] || [fileAbsolutePath hasSuffix:@"ppt"] || [fileAbsolutePath hasSuffix:@"PPT"] || [fileAbsolutePath hasSuffix:@"xls"] || [fileAbsolutePath hasSuffix:@"XLS"] || [fileAbsolutePath hasSuffix:@"txt"] || [fileAbsolutePath hasSuffix:@"TXT"] || [fileAbsolutePath hasSuffix:@"wav"] || [fileAbsolutePath hasSuffix:@"WAV"] || [fileAbsolutePath hasSuffix:@"amr"] || [fileAbsolutePath hasSuffix:@"AMR"]) {
            // 计算某个文件的大小
            filesAllSize += [self fileSizeWithPath:fileAbsolutePath];
        }
    }
    
    return filesAllSize;
}


/**
 计算指定文件的大小
 
 @param filePath 文件地址
 @return 大小
 */
+ (long long)fileSizeWithPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    
    return 0;
}



/**
 删除指定目录下的所有文件
 
 @param folderPath 目录地址
 */
+ (void)removeFolderPathAndFileWithPath:(NSString *)folderPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 目录是否存在
    if (![fileManager fileExistsAtPath:folderPath]) return;
    
    // 文件枚举器
    NSEnumerator *fileEnumerator = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString *fileName = nil;
    while ((fileName = [fileEnumerator nextObject]) != nil) {
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([fileAbsolutePath hasSuffix:@"doc"] || [fileAbsolutePath hasSuffix:@"DOC"]  || [fileAbsolutePath hasSuffix:@"docx"] || [fileAbsolutePath hasSuffix:@"DOCX"] || [fileAbsolutePath hasSuffix:@"pdf"] || [fileAbsolutePath hasSuffix:@"PDF"] || [fileAbsolutePath hasSuffix:@"ppt"] || [fileAbsolutePath hasSuffix:@"PPT"] || [fileAbsolutePath hasSuffix:@"xls"] || [fileAbsolutePath hasSuffix:@"XLS"] || [fileAbsolutePath hasSuffix:@"txt"] || [fileAbsolutePath hasSuffix:@"TXT"] || [fileAbsolutePath hasSuffix:@"wav"] || [fileAbsolutePath hasSuffix:@"WAV"] || [fileAbsolutePath hasSuffix:@"amr"] || [fileAbsolutePath hasSuffix:@"AMR"]) {
            // 删除指定的文件
            NSError *error = nil;
            [fileManager removeItemAtPath:fileAbsolutePath error:&error];
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
        }
    }
}


/**
 url参数字符串转字典
 
 @param urlStr url参数字符串
 @return 结果字典
 */
+(NSDictionary *)dictionaryWithUrlString:(NSString *)urlStr
{
    urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (urlStr.length > 0) {
        NSArray *array = [urlStr componentsSeparatedByString:@"&"];
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
        for (NSString *param in array) {
            if (param.length > 0) {
                NSArray *parArr = [param componentsSeparatedByString:@"="];
                if (parArr.count == 2) {
                    [paramsDict setValue:parArr[1] forKey:parArr[0]];
                }
            }
        }
        return paramsDict;
    }else{
        return nil;
    }
}


/**
 json 字符串转字典的方法
 
 @param jsonString json字符串
 @return 转换后的字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


/**
 改变字符start 和 end 之间的字符的颜色 和 字体大小
 
 @param theTextView UITextView
 @param start 开始字符串
 @param end 结束字符串
 @param allColor 整体颜色
 @param markColor 想要标注的颜色
 @param fontSize 字体大小
 */
+ (void)messageAction:(UITextView *)theTextView startString:(NSString *)start endString:(NSString *)end andAllColor:(UIColor *)allColor andMarkColor:(UIColor *)markColor andMarkFondSize:(float)fontSize {
    NSString *tempStr = theTextView.text;
    NSMutableAttributedString *strAtt = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [strAtt addAttribute:NSForegroundColorAttributeName value:allColor range:NSMakeRange(0, [strAtt length])];
    // 'x''y'字符的范围
    NSRange tempRange = NSMakeRange(0, 0);
    if ([NSString judgeStringIsNull:start]) {
        tempRange = [tempStr rangeOfString:start];
    }
    NSRange tempRangeOne = NSMakeRange([strAtt length], 0);
    if ([NSString judgeStringIsNull:end]) {
        tempRangeOne =  [tempStr rangeOfString:end];
    }
    // 更改字符颜色
    NSRange markRange = NSMakeRange(tempRange.location+tempRange.length, tempRangeOne.location-(tempRange.location+tempRange.length));
    [strAtt addAttribute:NSForegroundColorAttributeName value:markColor range:markRange];
    // 更改字体
    // [strAtt addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20] range:NSMakeRange(0, [strAtt length])];
    [strAtt addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:fontSize] range:markRange];
    theTextView.attributedText = strAtt;
}


/**
 *判断字符串是否不全为空
 */
+ (BOOL)judgeStringIsNull:(NSString *)string {
    if ([[string class] isSubclassOfClass:[NSNumber class]]) {
        return YES;
    }
    BOOL result = NO;
    if (string != nil && string.length > 0) {
        for (int i = 0; i < string.length; i ++) {
            NSString *subStr = [string substringWithRange:NSMakeRange(i, 1)];
            if (![subStr isEqualToString:@" "] && ![subStr isEqualToString:@""]) {
                result = YES;
            }
        }
    }
    return result;
}


/**
 判断字符串是否为纯数字
 
 @param checkedNumString 字符串
 @return 结果Bool类型
 */
+ (BOOL)isNum:(NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}


/**
 判断字符串是否为格式字符串中的字符

 @param string 要匹配的字符串
 @param formatStr 字符串格式 (字母数字：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789，
 字母：ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz，
 数字：0123456789，
 数字与小数点：.0123456789)
 @return yes,no
 */
+(BOOL)isOnlyhasNumberAndpointWithString:(NSString *)string andFormat:(NSString *)formatStr {
    
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:formatStr] invertedSet];
    
    NSString *filter=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filter];
}


/**
 根据字符串中后缀的格式类型返回对应的本地文件类型图标
 
 @param checkString 判断字符串
 @return 本地文件类型的图标地址
 */
+ (NSString *)getLocalImageWithCheckString:(NSString *)checkString {
    if ([checkString hasSuffix:@"doc"] || [checkString hasSuffix:@"DOC"]) {
        return @"findcase_file_icon.jpg";     // word 格式
    } else if ([checkString hasSuffix:@"docx"] || [checkString hasSuffix:@"DOCX"]) {
        return @"findcase_file_icon.jpg";     // word 格式
    } else if ([checkString hasSuffix:@"pdf"] || [checkString hasSuffix:@"PDF"]) {
        return @"findcase_file2_icon.jpg";
    } else if ([checkString hasSuffix:@"ppt"] || [checkString hasSuffix:@"PPT"]) {
        return @"case_filetype001.jpg";
    }else if ([checkString hasSuffix:@"xls"] || [checkString hasSuffix:@"XLS"]) {
        return @"findcase_file3_icon.jpg";
    }else if ([checkString hasSuffix:@"txt"] || [checkString hasSuffix:@"TXT"]) {
        return @"findcase_file4_icon.jpg";
    }else {
        return @"findcase_file5_icon.jpg";  // 位置格式
    }
}


// 字符串进行UTF8编码
+ (NSString *)stringAddEncodeWithString:(NSString *)str {
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// 字符串进行UTF8解码
+ (NSString *)stringReplaceEncodeWithString:(NSString *)str {
    return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

// MARK: 隐藏手机中间4位为*号
+ (NSString *)stringPhoneNumEncodeStartWithString:(NSString *)str {
    return  [str stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}



/**
 根据PM2.5值获取污染程度描述

 @param pm25Value pm2.5值
 @return pm2.5描述
 */
+ (NSString *)stringPm25LevelDescription:(NSInteger)pm25Value {
    if (pm25Value >= 0 && pm25Value < 50) {
        return @"优";
    } else if (pm25Value >= 50 && pm25Value < 100) {
        return @"良";
    } else if (pm25Value >= 100 && pm25Value < 150) {
        return @"轻度污染";
    } else if (pm25Value >= 150 && pm25Value < 200) {
        return @"中度污染";
    } else if (pm25Value >= 200 && pm25Value < 300) {
        return @"重度污染";
    } else if (pm25Value >= 300) {
        return @"严重污染";
    } else {
        return @"未知";
    }
}



/**
 将距离变成可读的格式

 @param distance 距离
 @return 可读字符串
 */
+ (NSString *)stringReadDistanceWith:(CGFloat)distance {
    if (distance < 1.0) {
        return @"<1米";
    } else if (distance < 1000) {
        return [NSString stringWithFormat:@"%.0f米", distance];
    } else if (distance < 10000) {
        return [NSString stringWithFormat:@"%.1f千米", distance / 1000];
    } else if (distance < 10000000) {
        return [NSString stringWithFormat:@"%.0f千米", distance / 1000];
    } else {
        return [NSString stringWithFormat:@"%.1f千公里", distance / 1000000];
    }
}



/**
 调用系统的MD5加密

 @param input 源字符串
 @return 目标字符串
 */
+ (NSString *)md5:(NSString *)input {
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (int)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}



/**
 获取指定开始和结束的字符串

 @param startStr 开始的字符串
 @param endStr 结束的字符串
 @param string 待处理字符串
 @return 目标字符串
 */
+ (NSString *)stringRangeOfStringWithStart:(NSString *)startStr andEnd:(NSString *)endStr andDealStr:(NSString *)string {
    NSRange startRange = [string rangeOfString:startStr];
    if ([startStr isEqual:@""]) {
        startRange = NSMakeRange(0, 0);
    }
    
    NSRange endRange = [string rangeOfString:endStr];
    
    NSRange range = NSMakeRange(startRange.location
                        + startRange.length,
                        endRange.location
                        - startRange.location
                        - startRange.length);
    
    return [string substringWithRange:range];
}



/**
 根据详细地址字符串获取城市名称

 @param addressStr 地址字符串
 @return 城市名
 */
+ (NSString *)getCityNameWithAddressStr:(NSString *)addressStr {
    NSString *cityName = @"";
    if ([addressStr rangeOfString:@"省"].location != NSNotFound) {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            cityName = [self stringRangeOfStringWithStart:@"省" andEnd:@"市" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@市", cityName];
        } else {
            cityName = [self stringRangeOfStringWithStart:@"" andEnd:@"省" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@省", cityName];
        }
    } else {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            cityName = [self stringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@市", cityName];
            return cityName;
        }
        
        if ([addressStr rangeOfString:@"自治州"].location != NSNotFound) {
            cityName = [self stringRangeOfStringWithStart:@"" andEnd:@"自治州" andDealStr:addressStr];
            cityName = [NSString stringWithFormat:@"%@自治州", cityName];
        } else {
            if ([addressStr rangeOfString:@"地区"].location != NSNotFound) {
                cityName = [self stringRangeOfStringWithStart:@"" andEnd:@"地区" andDealStr:addressStr];
                cityName = [NSString stringWithFormat:@"%@地区", cityName];
            }
        }
    }
    
    return cityName;
}


/**
 根据详细地址字符串获取省和城市名称
 
 @param addressStr 地址字符串
 @return 省和城市名
 */
+ (NSString *)getCityAndProinceNameWithAddressStr:(NSString *)addressStr {
    NSString *pcityName = @"";
    if ([addressStr rangeOfString:@"省"].location != NSNotFound) {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            pcityName = [self stringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@市", pcityName];
        } else {
            pcityName = [self stringRangeOfStringWithStart:@"" andEnd:@"省" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@省", pcityName];
        }
    } else {
        if ([addressStr rangeOfString:@"市"].location != NSNotFound) {
            pcityName = [self stringRangeOfStringWithStart:@"" andEnd:@"市" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@市", pcityName];
            return pcityName;
        }
        
        if ([addressStr rangeOfString:@"自治州"].location != NSNotFound) {
            pcityName = [self stringRangeOfStringWithStart:@"" andEnd:@"自治州" andDealStr:addressStr];
            pcityName = [NSString stringWithFormat:@"%@自治州", pcityName];
        } else {
            if ([addressStr rangeOfString:@"地区"].location != NSNotFound) {
                pcityName = [self stringRangeOfStringWithStart:@"" andEnd:@"地区" andDealStr:addressStr];
                pcityName = [NSString stringWithFormat:@"%@地区", pcityName];
            }
        }
    }
    
    return pcityName;
}




/**
 去掉小数点后边多余的0

 @param string 源字符串
 @return 目标字符串
 */
+(NSString*)removeFloatAllZero:(NSString*)string
{
    
    NSString * testNumber = string;
    NSString * outNumber = [NSString stringWithFormat:@"%@",@(testNumber.floatValue)];
    
    //    价格格式化显示
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    NSString *formatterString = [formatter stringFromNumber:[NSNumber numberWithFloat:[outNumber doubleValue]]];
    
    NSRange range = [formatterString rangeOfString:@"."]; //现获取要截取的字符串位置
    NSLog(@"--------%lu",(unsigned long)range.length);
    
    if (range.length>0) {
        
        NSString * result = [formatterString substringFromIndex:range.location]; //截取字符串
        
        if (result.length>=4) {
            
            formatterString=[formatterString substringToIndex:formatterString.length-1];
        }
        
    }
    
    NSLog(@"Formatted number string:%@",formatterString);
    
    NSLog(@"Formatted number string:%@",outNumber);
    //    输出结果为：[1223:403] Formatted number string:123,456,789
    
    return formatterString;
}


@end
