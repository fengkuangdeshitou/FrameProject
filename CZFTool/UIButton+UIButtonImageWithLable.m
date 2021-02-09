//
//  UIButton.m
//  EnquiryGreens-v1.0
//
//  Created by mac on 15/9/1.
//  Copyright (c) 2015年 感知. All rights reserved.
//

#import "UIButton+UIButtonImageWithLable.h"

@implementation UIButton (UIButtonImageWithLable)


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
- (void) setTopAndBottomImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andTintColor:(UIColor *)tintColor withTextFont:(UIFont *)textFont AndImageTitleGap:(float)imageTitleGap {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)

    int gapX = (self.frame.size.width- image.size.width)/2;
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0,
                                              gapX,
                                              imageTitleGap,
                                              gapX)];
    [self setImage:image forState:stateType];
    //[self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:textFont];
    [self.titleLabel setTextColor:[UIColor darkGrayColor]];
    [self setTintColor:tintColor];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height,
                                              -image.size.height,
                                              0.0,
                                              0.0)];
    [self setTitleColor:tintColor forState:stateType];
    
    [self setTitle:title forState:stateType];
}


/**
 *  上面图片，底部文字 button
 *
 *  @param image     Picture
 *  @param title     Title Text
 *  @param stateType UIControlState
 *  @param tintColor tintColor
 *  @param textFont textFont
 *  @param titleHeight titleHeight
 */
- (void) setTopAndBottomImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andTintColor:(UIColor *)tintColor withTextFont:(UIFont *)textFont andTitleTextHeight:(float)titleHeight {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    int gapX = (self.frame.size.width- image.size.width)/2;
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0,
                                              gapX,
                                              titleHeight,
                                              gapX)];
    [self setImage:image forState:stateType];
    //[self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:textFont];
    [self.titleLabel setTextColor:[UIColor darkGrayColor]];
    [self setTintColor:tintColor];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height,
                                              -image.size.height,
                                              0.0,
                                              0.0)];
    [self setTitleColor:tintColor forState:stateType];
    
    [self setTitle:title forState:stateType];
}



#pragma mark  备注：如果不需要上下显示，只需要横向排列的时候，就不需要设置左右偏移量了，代码如下
/**
 *  左边图片右边文字
 *
 *  @param image     图片
 *  @param title     title
 *  @param stateType UIControlState
 *  @param textFont  titleLabel Font Size
 *  @param align     对齐方式
 */
- (void) setLeftAndRightTextWithImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType withTextFont:(float)textFont andAlignment:(UIControlContentHorizontalAlignment)align {
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0,
                                              0.0,
                                              0.0,
                                              0.0)];
    [self setImage:image forState:stateType];
    
    self.contentHorizontalAlignment = align;
    int labelLeftGapX = image == nil ? 0 : 6;
    [self.titleLabel setFont:[UIFont systemFontOfSize:textFont]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              labelLeftGapX,
                                              0.0,
                                              0.0)];
    
    [self setTitle:title forState:stateType];
}


/**
 *  左边文字，右边图片 左对齐
 *
 *  @param image      Picture
 *  @param title      Title
 *  @param stateType  UIControlState
 *  @param imageFontV ImageFont
 *  @param titleFontV Title Font
 */
- (void) setRightAndleftTextWithImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType andImageFontValue:(float)imageFontV andTitleFontValue:(float)titleFontV andTextAlignment:(UIControlContentHorizontalAlignment)textAlign {
    
    self.contentHorizontalAlignment = textAlign; //使得button中titleLabel 居中 左对齐，右对齐
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.titleLabel setFont:[UIFont systemFontOfSize:titleFontV]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              -image.size.width,
                                              0.0,
                                              image.size.width)]; // 设置边距
    [self setTitle:title forState:stateType];
    
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    [self setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0,
                                              self.titleLabel.bounds.size.width+3,
                                              0.0,
                                              0.0)];
    //self.frame.size.width- image.size.width
    [self setImage:image forState:stateType];

    
}


@end
