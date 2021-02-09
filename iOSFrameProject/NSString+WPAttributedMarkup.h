//
//  NSString+WPAttributedMarkup.h
//  SonoRoute
//
//  Created by Nigel Grange on 07/06/2014.
//  Copyright (c) 2014 Nigel Grange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WPAttributedMarkup)

-(NSAttributedString*)attributedStringWithStyleBook:(NSDictionary*)styleBook;

/// 带有行间距的text属性设置
-(NSAttributedString*)attributedStringWithStyleBook:(NSDictionary*)fontbook andSpaceLine:(float)spaceLine;

/// 给指定的文字加横线
-(NSAttributedString*)attributedStringWithStyleBook:(NSDictionary*)fontbook andSpaceLine:(float)spaceLine andTextIndex:(NSRange)textRange;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
