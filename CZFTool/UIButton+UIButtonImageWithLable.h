//
//  UIButton.h
//  EnquiryGreens-v1.0
//
//  Created by mac on 15/9/1.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UIButtonImageWithLable)

/**
 *  上面图片，底部文字 button
 *
 *  @param image     Picture
 *  @param title     Title Text
 *  @param stateType UIControlState
 *  @param tintColor tintColor
 *  @param textFont textFont
 *  @param imageTitleGap imageTitleGap
 */
- (void) setTopAndBottomImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andTintColor:(UIColor *)tintColor withTextFont:(UIFont *)textFont AndImageTitleGap:(float)imageTitleGap;


/**
 *  上面图片，底部文字 button
 *
 *  @param image     Picture
 *  @param title     Title Text
 *  @param stateType UIControlState
 *  @param tintColor tintColor
 *  @param textFont TextFont
 *  @param titleHeight titleHeight
 */
- (void) setTopAndBottomImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andTintColor:(UIColor *)tintColor withTextFont:(UIFont *)textFont andTitleTextHeight:(float)titleHeight;


/**
 *  左边图片右边文字
 *
 *  @param image     图片
 *  @param title     title
 *  @param stateType UIControlState
 *  @param textFont  titleLabel Font Size
 *  @param align     对齐方式
 */
- (void) setLeftAndRightTextWithImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType withTextFont:(float)textFont andAlignment:(UIControlContentHorizontalAlignment)align;

/**
 *  左边文字，右边图片 左对齐
 *
 *  @param image      Picture
 *  @param title      Title
 *  @param stateType  UIControlState
 *  @param imageFontV ImageFont
 *  @param titleFontV Title Font
 */
- (void) setRightAndleftTextWithImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andImageFontValue:(float)imageFontV andTitleFontValue:(float)titleFontV andTextAlignment:(UIControlContentHorizontalAlignment)textAlign;

@end
