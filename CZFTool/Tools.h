//
//  tools.h
//  250
//
//  Created by 周强 on 15/12/24.
//  Copyright © 2015年 com.jointsky.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// 获取屏幕的尺寸
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width        // 宽
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height      // 高

#define App_RootCtr  [UIApplication sharedApplication].keyWindow.rootViewController

// 导航栏的高度    建议：导航栏中的按钮图片的大小一般为26  26@2x   26@3x
#define NAVIGATION_AND_STATUS_HEIGHT (44+20)                        // 导航栏和状态栏的高度
#define TOOL_BAR_HEIGHT 49                                          // 工具栏的高度
#define ITEM_IMAGE_CGSZE CGSizeMake(26, 26)                         // tabBar和navBar上的图标的标准大小

#define STATUS_BAR_HEIGHT 20                                        // 状态栏的高度
#define NAVIGATION_BAR_HEIGHT 44                                    // 导航栏的高度


/**
 *  使用（0-255）方式的RGB设置设置颜色
 *
 *  @param r 0-255
 *  @param g 0-255
 *  @param b 0-255
 *  @param a 0.0-1.0
 *
 *  @return UIColor
 */
#define UIColorRGBA_Selft(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


/**
 *  16进制的方式设置颜色（eg. 0xff1122）
 *
 *  @param rgbValue 16进制色值
 *
 *  @return UIColor
 */

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// 日期的标准格式
#define DATE_STANDARD_FORMATTER   @"yyyy-MM-dd HH:mm:ss"  //yyyy-MM-dd HH:mm:ss

// 获取本地沙盒的documents路径
#define DOCUMENTS_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


/**
 *  定义打印信息
 */
#ifdef DEBUG            // 调试阶段

//#define MYLOG(...) NSLog(__VA_ARGS__)
#define MYLOG(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

#define MYLog(...) NSLog(__VA_ARGS__)

#else

#define MYLOG(...) // 非调试阶段不打印log
#endif


@interface Tools : NSObject



@end
