//
//  UIView+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "UIView+CZFTools.h"

@implementation UIView (CZFTools)

/**
 *  隐藏控件，效果为是否是半透明不可点击
 *
 *  @param hiden 是否隐藏
 *  @param sView 要被设置的view
 */

+ (void)hideViewHalfAlphaNoActionWithYesOrNo:(BOOL)hiden andView:(id)sView {
    if (hiden) {
        if ([sView isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *barBtmItem = sView;
            barBtmItem.enabled = NO;
        } else {
            UIView *myTempView = sView;
            myTempView.alpha = 0.5;
            myTempView.userInteractionEnabled = NO;
        }
    } else {
        if ([sView isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *barBtmItem = sView;
            barBtmItem.enabled = YES;
        } else {
            UIView *myTempView = sView;
            myTempView.alpha = 1.0;
            myTempView.userInteractionEnabled = YES;
        }
    }
}


/**
 *  删除view中所有的subview
 *
 *  @param view  要删除的子view的view
 */
+ (void)removeSubviews:(UIView *)view {
    for (UIView *subView in view.subviews) {
        [subView removeFromSuperview];
    }
}


/*
 *  自定排版view中subview
 */
+ (UIView *)autoComposingSubViewWithView:(UIView *)fatherView andGapX:(float)gapx {
    NSArray *subViews = fatherView.subviews;
    
    for (int i = 0; i < subViews.count; i++) {
        UIView *subview = subViews[i];
        
        CGRect rectFrame = subview.frame;
        if (i == 0) {
            rectFrame.origin.x = gapx;
            rectFrame.origin.y = (fatherView.bounds.size.height - subview.bounds.size.height)/2;
        } else {
            UIView *previousView = subViews[i-1];
            rectFrame.origin.x = previousView.frame.origin.x + previousView.frame.size.width + gapx;
            rectFrame.origin.y =  (fatherView.bounds.size.height - subview.bounds.size.height)/2;
        }
        subview.frame = rectFrame;
    }
    
    return fatherView;
}



/**
 设置View的圆角以及边框

 @param cornerRadius 圆角大小
 @param borderColor 边框颜色
 @param borderWidth 边框宽度
 */
- (void)cornerRadius:(CGFloat)cornerRadius
         borderColor:(CGColorRef)borderColor
         borderWidth:(CGFloat)borderWidth
{
    self.clipsToBounds = YES;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderColor = borderColor;
    self.layer.borderWidth = borderWidth;
    
}


@end
