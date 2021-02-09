//
//  UIImage+CZFTools.h
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CZFTools)

/**
 *  给图片中写入文字
 *
 *  @param image    写入文字前的图片
 *  @param str      字符串
 *  @param fontSize 字体大小
 *
 *  @return 写入文字后的图片
 */

+ (UIImage *)createShareImage:(UIImage *)image :(NSString *)str :(CGFloat )fontSize;


/**
 *  向图片中写文字之后转成image
 *
 *  @param image    没有加入文字的图片
 *  @param strA      拍照时间/地址第一段
 *  @param strB      地址第二段
 *  @param strC      PM2.5数值
 *  @param strD      (PM2.5)
 *  @param fontSize 字体大小
 *
 *  @return 加入文字后的图片
 */
+ (UIImage *)createShareImaga:(UIImage *)image :(NSString *)strA :(NSString *)strB :(NSString *)strC :(NSString *)strD :(CGFloat )fontSize;


/**
 *  图片上下拼接
 *
 *  @param topImage    上面图片
 *  @param bottomImage 下面图片
 *
 *  @return 合并后图片
 */

+ (UIImage *) combineSX:(UIImage*)topImage :(UIImage*)bottomImage;


/**
 *  图片左右拼接
 *
 *  @param leftImage  左边图片
 *  @param rightImage 右边图片
 *
 *  @return 合并图片
 */

+ (UIImage *) combineZY:(UIImage*)leftImage :(UIImage*)rightImage;


/**
 *  图片去雾的方法
 *
 *  @param image      要处理的图片
 *  @param light      亮度    -1：表示不调节
 *  @param contrast   对比度  -1：表示不调节
 *  @param saturation 饱和度  -1：表示不调节
 *
 *  @return 目标图片
 */

+ (UIImage *)dealHBSImage:(UIImage *)image andLight:(double)light andContrast:(double)contrast andsaturation:(double)saturation;


/**
 *  对目标图片指定大小进行压缩
 *
 *  @param image 目标图片
 *  @param size  指定的大小
 *
 *  @return 返回压缩后的图片
 */

+ (UIImage *)scalToSize:(UIImage *)image size:(CGSize)size;


/**
 *  等比例缩小图片
 *
 *  @param image 源图片
 *  @param scale 缩放系数
 *
 *  @return 目标图片
 */

+(UIImage*)imageCompressWithSimple:(UIImage*)image scale:(float)scale;


/**
 根据最长的一边，等比例缩小图片
 
 @param maxwidthOrHeight 最长的一边的像素值
 @param image 要处理的图片对象
 @return 处理后的图片
 */
+ (UIImage *)scalToMaxWidthOrHeight:(int)maxwidthOrHeight andImage:(UIImage *)image;


/**
 该函数用来修正 imageOrientation 值
 
 @param aImage aImage
 @return Image
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;


/**
 *  根据图片的的高度或者宽度，等比例求取与之相对应的宽度或高度
 *
 *  @param sourceImg 源图片
 *  @param width     目标宽度  0:表示根据高度固定，宽度是可变的
 *  @param height    目标高度  0:表示根据宽度固定，高度是可变的
 *
 *  @return 与之相对应的目标宽度或者高度
 */

+ (float)getImageWithOrHeightWithImage:(UIImage *)sourceImg andWidht:(float)width andHeight:(float)height;


/**
 *  图片旋转的方法
 *
 *  @param image 源图片
 *  @param angle 旋转角度  上北方向为 0度起始点
 *
 *  @return 目标图片
 */
+ (UIImage *)imageTurnSpinDirection:(UIImage *)image andTurnAngle:(int)angle;


/**
 截取圆形图片的方法
 
 @param image 源图片
 @param inset 边距
 
 @return 目标图片
 */
+(UIImage*)circleImage:(UIImage*) image withParam:(CGFloat) inset;


/**
 由颜色值生成图片的方法
 
 @param color 颜色值
 @return 图片对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


/**
 将View转成图片
 
 @param view view
 @return 图片
 */
+ (UIImage *)imageWithView:(UIView *)view;


/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect;


//裁剪正方
/**
 *  剪切图片为正方形
 *
 *  @param image   原始图片比如size大小为(400x200)pixels
 *  @param newSize 正方形的size比如400pixels
 *
 *  @return 返回正方形图片(400x400)pixels
 */
+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;

@end
