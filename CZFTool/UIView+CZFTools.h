//
//  UIView+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CZFTools)


/**
 *  隐藏控件，效果为是否是半透明不可点击
 *
 *  @param hiden 是否隐藏
 *  @param sView 要被设置的view
 */

+ (void)hideViewHalfAlphaNoActionWithYesOrNo:(BOOL)hiden andView:(id)sView;


/**
 *  删除view中所有的subview
 *
 *  @param view  要删除的子view的view
 */
+ (void)removeSubviews:(UIView *)view;


/*
 *  自定排版view中subview
 */
+ (UIView *)autoComposingSubViewWithView:(UIView *)fatherView andGapX:(float)gapx;


/**
 设置View的圆角以及边框
 
 @param cornerRadius 圆角大小
 @param borderColor 边框颜色
 @param borderWidth 边框宽度
 */
- (void)cornerRadius:(CGFloat)cornerRadius
         borderColor:(CGColorRef)borderColor
         borderWidth:(CGFloat)borderWidth;


@end
