//
//  UILabel+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CZFTools)


/**
 *  给UILabel设置行间距和字间距
 */
+(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font andLineSpaceing:(float)lineSpace;


/**
 *  计算UILabel的高度(带有行间距的情况)
 */
+ (CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width andLineSpaceing:(float)lineSpace;


/**
 获取label 的宽度
 
 @param label Label
 @return 宽度
 */
+ (CGFloat)getLabelWidthWithLabel:(UILabel *)label;

@end
