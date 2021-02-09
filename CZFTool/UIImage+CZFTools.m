//
//  UIImage+CZFTools.m
//  CZFToolDemo
//
//  Created by 陈帆 on 2018/2/9.
//  Copyright © 2018年 陈帆. All rights reserved.
//

#import "UIImage+CZFTools.h"

@implementation UIImage (CZFTools)


/**
 *  给图片中写入文字
 *
 *  @param image    写入文字前的图片
 *  @param str      字符串
 *  @param fontSize 字体大小
 *
 *  @return 写入文字后的图片
 */

+ (UIImage *)createShareImage:(UIImage *)image :(NSString *)str :(CGFloat )fontSize {
    
    CGSize sizes= CGSizeMake (image. size . width , image. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (sizes, NO , 0.0 );
    
    [image drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextDrawPath (context, kCGPathStroke );
    
    // 画
    
    [str drawAtPoint : CGPointMake ( 0 , image. size . height * 0.65 ) withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : fontSize ], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    //画自己想画的内容。。。。。
    
    // 返回绘制的新图形
    
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}



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
+ (UIImage *)createShareImaga:(UIImage *)image :(NSString *)strA :(NSString *)strB :(NSString *)strC :(NSString *)strD :(CGFloat )fontSize{
    
    CGSize sizes= CGSizeMake (image. size . width , image. size . height ); // 画布大小
    
    UIGraphicsBeginImageContextWithOptions (sizes, NO , 0.0 );
    
    [image drawAtPoint : CGPointMake ( 0 , 0 )];
    
    // 获得一个位图图形上下文
    
    CGContextRef context= UIGraphicsGetCurrentContext ();
    
    CGContextDrawPath (context, kCGPathStroke );
    
    // 画
    
    [strA drawAtPoint : CGPointMake ( 2 , image. size . height * 0.83 ) withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : 14 ], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    [strB drawAtPoint : CGPointMake ( 2 , image. size . height * 0.89 ) withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : 14 ], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    
    [strC drawAtPoint : CGPointMake ( 2 , image. size . height * 0.53 ) withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : fontSize ], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    [strD drawAtPoint : CGPointMake ( strC.length*37 , image. size . height * 0.695 ) withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : 12 ], NSForegroundColorAttributeName :[ UIColor whiteColor ] } ];
    
    //画自己想画的内容。。。。。
    
    // 返回绘制的新图形
    
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
}


/**
 *  图片上下拼接
 *
 *  @param topImage    上面图片
 *  @param bottomImage 下面图片
 *
 *  @return 合并后图片
 */

+ (UIImage *) combineSX:(UIImage*)topImage :(UIImage*)bottomImage {
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    CGSize size = CGSizeMake(SCREEN_WIDTH*2, (SCREEN_HEIGHT - 64)*2);
    UIGraphicsBeginImageContext(size);
    
    [topImage drawInRect:CGRectMake(0, 0, size.width, size.height/2)];
    
    [bottomImage drawInRect:CGRectMake(0, size.height/2, size.width, size.height/2)];
    
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return togetherImage;
}


/**
 *  图片左右拼接
 *
 *  @param leftImage  左边图片
 *  @param rightImage 右边图片
 *
 *  @return 合并图片
 */

+ (UIImage *) combineZY:(UIImage*)leftImage :(UIImage*)rightImage {
    CGFloat SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat SCREEN_HEIGHT = [UIScreen mainScreen].bounds.size.height;
    
    CGSize size = CGSizeMake(SCREEN_WIDTH*2, (SCREEN_HEIGHT - 64)/2 *2);
    UIGraphicsBeginImageContext(size);
    // 左图片
    if (leftImage.size.width >= leftImage.size.height) {
        float imgNewLeftHeight = [self getImageWithOrHeightWithImage:leftImage andWidht:size.width/2 andHeight:0.0];
        
        [leftImage drawInRect:CGRectMake(0, (size.height - imgNewLeftHeight)/2, size.width/2, imgNewLeftHeight)];
    } else {
        float imgNewLeftWidth = [self getImageWithOrHeightWithImage:leftImage andWidht:0.0 andHeight:size.height];
        
        [leftImage drawInRect:CGRectMake(0, 0, imgNewLeftWidth, size.height)];
    }
    
    // 右图片
    if (rightImage.size.width >= rightImage.size.height) {
        float imgNewRightHeight = [self getImageWithOrHeightWithImage:rightImage andWidht:size.width/2 andHeight:0.0];
        
        [rightImage drawInRect:CGRectMake(size.width/2, (size.height - imgNewRightHeight)/2, size.width/2, imgNewRightHeight)];
    } else {
        float imgNewRightWidth = [self getImageWithOrHeightWithImage:rightImage andWidht:0.0 andHeight:size.height];
        
        [rightImage drawInRect:CGRectMake(size.width/2, 0, imgNewRightWidth, size.height)];
    }
    
    
    
    UIImage *togetherImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return togetherImage;
}


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

+ (UIImage *)dealHBSImage:(UIImage *)image andLight:(double)light andContrast:(double)contrast andsaturation:(double)saturation {
    //0.倒入image
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    //1.创建出filter滤镜
    CIFilter *filterControls = [CIFilter filterWithName:@"CIColorControls"];
    [filterControls setValue:ciImage
                      forKey:kCIInputImageKey];
    [filterControls setDefaults];           // 0.f  1.05f  2.f
    
    if (-1 != light) {
        [filterControls setValue:@(light) forKey:@"inputBrightness"];       //亮度
    }
    if (-1 != contrast) {
        [filterControls setValue:@(contrast) forKey:@"inputContrast"];      //对比度
    }
    if (-1 != saturation) {
        [filterControls setValue:@(saturation) forKey:@"inputSaturation"];  //饱和度
    }
    
    CIImage *outImage = [filterControls valueForKey:kCIOutputImageKey];
    CIFilter *filterTone = [CIFilter filterWithName:@"CISepiaTone"];
    [filterTone setValue:outImage
                  forKey:kCIInputImageKey];
    [filterTone setDefaults];
    [filterTone setValue:@(0.1f)
                  forKey:kCIInputIntensityKey];
    
    CIImage *outputImage = [filterTone valueForKey:kCIOutputImageKey];
    
    //2.用CIContext将滤镜中的图片渲染出来
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outImage extent]];
    
    //3.导出图片
    
    UIImage *showImage = [UIImage imageWithCGImage:cgImage];
    //self.uploadImage_1 = showImage;
    CGImageRelease(cgImage);
    return showImage;
    
    
    //4.加载
    //[_dealImage setImage:showImage];
    
    //    //添加处理后图片对比按钮显示
    //    _contrastBtn.hidden = NO;
    //    //原图隐藏，展示处理后照片
    //    _originalImage.hidden = YES;
}


/**
 *  对目标图片指定大小进行压缩
 *
 *  @param image 目标图片
 *  @param size  指定的大小
 *
 *  @return 返回压缩后的图片
 */

+ (UIImage *)scalToSize:(UIImage *)image size:(CGSize)size {
    // 去除锯齿
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


/**
 *  等比例缩小图片
 *
 *  @param image 源图片
 *  @param scale 缩放系数
 *
 *  @return 目标图片
 */

+(UIImage*)imageCompressWithSimple:(UIImage*)image scale:(float)scale
{
    CGSize size=image.size;
    CGFloat width=size.width;
    CGFloat height=size.height;
    CGFloat scaledWidth=width*scale;
    CGFloat scaledHeight=height*scale;
    
    UIGraphicsBeginImageContext(size);//thiswillcrop
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage*newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


/**
 根据最长的一边，等比例缩小图片
 
 @param maxwidthOrHeight 最长的一边的像素值
 @param image 要处理的图片对象
 @return 处理后的图片
 */
+ (UIImage *)scalToMaxWidthOrHeight:(int)maxwidthOrHeight andImage:(UIImage *)image {
    // 缩小image的尺寸
    int maxSizeWH = maxwidthOrHeight/2;
    CGSize imgeSize;
    if (image.size.width >= image.size.height) {
        float imgNewHeight = [self getImageWithOrHeightWithImage:image andWidht:maxSizeWH andHeight:0.0];
        imgeSize = CGSizeMake(maxSizeWH, imgNewHeight);
    } else {
        float imgNewWidth = [self getImageWithOrHeightWithImage:image andWidht:0.0 andHeight:maxSizeWH];
        imgeSize = CGSizeMake(imgNewWidth, maxSizeWH);
    }
    
    return [self scalToSize:image size:imgeSize];
}


/**
 该函数用来修正 imageOrientation 值
 
 @param aImage aImage
 @return Image
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


/**
 *  根据图片的的高度或者宽度，等比例求取与之相对应的宽度或高度
 *
 *  @param sourceImg 源图片
 *  @param width     目标宽度  0:表示根据高度固定，宽度是可变的
 *  @param height    目标高度  0:表示根据宽度固定，高度是可变的
 *
 *  @return 与之相对应的目标宽度或者高度
 */

+ (float)getImageWithOrHeightWithImage:(UIImage *)sourceImg andWidht:(float)width andHeight:(float)height {
    float imgWith = sourceImg.size.width, imgHeight = sourceImg.size.height, ratioWH = imgWith/imgHeight, goalImgWRH = 0.0;
    
    if (width == 0.0 && height != 0.0) {  // 根据高度求宽度
        goalImgWRH = ratioWH * height;
    } else if (width != 0.0 && height == 0.0) { // 根据宽度求高度
        goalImgWRH = width / ratioWH;
    }
    
    return goalImgWRH;
}


static inline double radians (double degrees) {return degrees * M_PI/180;}
/**
 *  图片旋转的方法
 *
 *  @param image 源图片
 *  @param angle 旋转角度  上北方向为 0度起始点
 *
 *  @return 目标图片
 */
+ (UIImage *)imageTurnSpinDirection:(UIImage *)image andTurnAngle:(int)angle {
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 做CTM变换
    CGContextRotateCTM (context, radians(130.));
    CGContextTranslateCTM (context, 0, -size.height);
    
    // 开始绘制图片
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0,0, size.width, size.height), image.CGImage);
    
    UIImage *goalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return goalImage;
}


/**
 截取圆形图片的方法
 
 @param image 源图片
 @param inset 边距
 
 @return 目标图片
 */
+(UIImage*)circleImage:(UIImage*) image withParam:(CGFloat) inset {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);  // 去除锯齿感
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
    
}


/**
 由颜色值生成图片的方法
 
 @param color 颜色值
 @return 图片对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


/**
 将View转成图片
 
 @param view view
 @return 图片
 */
+ (UIImage *)imageWithView:(UIView *)view {
    
    //    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    //    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    
    //转化成image
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);// 去除锯齿（2倍图）
    //    UIGraphicsBeginImageContext(view.bounds.size);   // 一倍图，有锯齿
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}


/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}


//裁剪正方
/**
 *  剪切图片为正方形
 *
 *  @param image   原始图片比如size大小为(400x200)pixels
 *  @param newSize 正方形的size比如400pixels
 *
 *  @return 返回正方形图片(400x400)pixels
 */
+ (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize
{
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height)
    {
        //image原始高度为200，缩放image的高度为400pixels，所以缩放比率为2
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        //设置绘制原始图片的画笔坐标为CGPoint(-100, 0)pixels
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    }
    else
    {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    //创建画板为(400x400)pixels
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    }
    else
    {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //将image原始图片(400x200)pixels缩放为(800x400)pixels
    CGContextConcatCTM(context, scaleTransform);
    //origin也会从原始(-100, 0)缩放到(-200, 0)
    [image drawAtPoint:origin];
    
    //获取缩放后剪切的image图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


@end
