//
//  UILabel+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/11.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "UILabel+CZFTools.h"

@implementation UILabel (CZFTools)


/**
 *  给UILabel设置行间距和字间距
 */
+(void)setLabelSpace:(UILabel*)label withValue:(NSString*)str withFont:(UIFont*)font andLineSpaceing:(float)lineSpace {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = lineSpace; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f
                          };
    
    // 排除空
    if ([str isKindOfClass:[NSNull class]] || [str isEqualToString:@""] || str == nil) {
        return;
    }
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:dic];
    label.attributedText = attributeStr;
}


/**
 *  计算UILabel的高度(带有行间距的情况)
 */
+ (CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width andLineSpaceing:(float)lineSpace {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = lineSpace;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    // 排除空
    if ([str isKindOfClass:[NSNull class]] || [str isEqualToString:@""] || str == nil) {
        return 15;
    }
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}


/**
 获取label 的宽度
 
 @param label Label
 @return 宽度
 */
+ (CGFloat)getLabelWidthWithLabel:(UILabel *)label {
    //这个frame是初设的，没关系，后面还会重新设置其size。  //lbDetailInformation1
    NSDictionary *attributes1 = @{NSFontAttributeName:label.font,};
    NSString *str1 = label.text;
    CGSize textSize1 = [str1 boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 100) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes1 context:nil].size;
    
    return textSize1.width;
}

@end
