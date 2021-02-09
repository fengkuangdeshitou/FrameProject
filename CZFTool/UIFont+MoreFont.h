//
//  UIFont+MoreFont.h
//  iOSFontsDemo
//
//  Created by 陈帆 on 2018/4/19.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 响应进度

 @param fontName 字体名称
 */
typedef void (^FontCallBack) (NSString *fontName);

@interface UIFont (MoreFont)

+ (void)asynchronouslySetFontName:(NSString *)fontName AndCallBack:(FontCallBack)callBackFunc;


@end
